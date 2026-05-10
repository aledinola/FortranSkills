param(
  [Parameter(Mandatory=$true, Position=0)]
  [ValidateSet('extract','count','pptx')]
  [string]$Action,

  [Parameter(Mandatory=$true, Position=1)]
  [string]$Path,

  [string]$Ranges
)

$ErrorActionPreference = 'Stop'
Add-Type -AssemblyName System.IO.Compression.FileSystem

function Get-XmlFromZipEntry([string]$FilePath, [string]$EntryName) {
  $resolved = (Resolve-Path -LiteralPath $FilePath).Path
  $zip = [System.IO.Compression.ZipFile]::OpenRead($resolved)
  try {
    $entry = $zip.GetEntry($EntryName)
    if ($null -eq $entry) { throw "Entry '$EntryName' not found in $FilePath" }
    $stream = $entry.Open()
    try {
      $reader = [IO.StreamReader]::new($stream)
      try { return [xml]$reader.ReadToEnd() } finally { $reader.Dispose() }
    } finally { $stream.Dispose() }
  } finally { $zip.Dispose() }
}

function Get-DocxParagraphs([string]$FilePath) {
  $xml = Get-XmlFromZipEntry $FilePath 'word/document.xml'
  $ns = [Xml.XmlNamespaceManager]::new($xml.NameTable)
  $ns.AddNamespace('w','http://schemas.openxmlformats.org/wordprocessingml/2006/main')
  $items = @()
  $i = 0
  foreach ($p in $xml.SelectNodes('//w:body/w:p', $ns)) {
    $line = (($p.SelectNodes('.//w:t', $ns) | ForEach-Object { $_.'#text' }) -join '')
    if ($line.Trim().Length -gt 0) {
      $i++
      $items += [pscustomobject]@{ Number = $i; Text = $line.Trim() }
    }
  }
  return $items
}

function Count-Words([string]$Text) {
  return [regex]::Matches($Text, "[\p{L}\p{N}]+(?:[-'][\p{L}\p{N}]+)*").Count
}

function Get-PptxText([string]$FilePath) {
  $resolved = (Resolve-Path -LiteralPath $FilePath).Path
  $zip = [System.IO.Compression.ZipFile]::OpenRead($resolved)
  try {
    $entries = $zip.Entries | Where-Object { $_.FullName -like 'ppt/slides/slide*.xml' } | Sort-Object FullName
    foreach ($entry in $entries) {
      $stream = $entry.Open()
      try {
        $reader = [IO.StreamReader]::new($stream)
        try { [xml]$xml = $reader.ReadToEnd() } finally { $reader.Dispose() }
      } finally { $stream.Dispose() }
      $ns = [Xml.XmlNamespaceManager]::new($xml.NameTable)
      $ns.AddNamespace('a','http://schemas.openxmlformats.org/drawingml/2006/main')
      [pscustomobject]@{
        Slide = $entry.FullName
        Text = (($xml.SelectNodes('//a:t', $ns) | ForEach-Object { $_.'#text' }) -join "`n")
      }
    }
  } finally { $zip.Dispose() }
}

if ($Action -eq 'extract') {
  Get-DocxParagraphs $Path | ForEach-Object { '{0:D3}: {1}' -f $_.Number, $_.Text }
}
elseif ($Action -eq 'count') {
  if (-not $Ranges) { throw 'Provide --% -Ranges "Name=1-3;Other=4,6-8" or -Ranges with paragraph ranges.' }
  $paras = Get-DocxParagraphs $Path
  foreach ($spec in ($Ranges -split ';')) {
    if ($spec.Trim().Length -eq 0) { continue }
    $parts = $spec -split '=', 2
    if ($parts.Count -ne 2) { throw "Bad range spec: $spec" }
    $name = $parts[0].Trim()
    $nums = @()
    foreach ($piece in ($parts[1] -split ',')) {
      $piece = $piece.Trim()
      if ($piece -match '^(\d+)-(\d+)$') { $nums += [int]$Matches[1]..[int]$Matches[2] }
      elseif ($piece -match '^\d+$') { $nums += [int]$piece }
      else { throw "Bad paragraph range: $piece" }
    }
    $text = (($paras | Where-Object { $nums -contains $_.Number } | ForEach-Object { $_.Text }) -join "`n")
    [pscustomobject]@{ Section = $name; Words = Count-Words $text; Characters = $text.Length }
  }
}
elseif ($Action -eq 'pptx') {
  Get-PptxText $Path | ForEach-Object { "## $($_.Slide)`n$($_.Text)`n" }
}
