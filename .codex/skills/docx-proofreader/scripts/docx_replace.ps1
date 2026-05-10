param(
  [Parameter(Mandatory=$true, Position=0)]
  [string]$Source,

  [Parameter(Mandatory=$true, Position=1)]
  [string]$Output,

  [Parameter(Mandatory=$true)]
  [string]$ReplaceJson
)

$ErrorActionPreference = 'Stop'
Add-Type -AssemblyName System.IO.Compression
Add-Type -AssemblyName System.IO.Compression.FileSystem

function Get-ParaText($p, $ns) {
  return (($p.SelectNodes('.//w:t', $ns) | ForEach-Object { $_.'#text' }) -join '')
}

function Set-ParaText($doc, $p, $ns, [string]$text) {
  $pPr = $p.SelectSingleNode('./w:pPr', $ns)
  foreach ($child in @($p.ChildNodes)) {
    if ($null -eq $pPr -or -not [object]::ReferenceEquals($child, $pPr)) { [void]$p.RemoveChild($child) }
  }
  $r = $doc.CreateElement('w','r','http://schemas.openxmlformats.org/wordprocessingml/2006/main')
  $t = $doc.CreateElement('w','t','http://schemas.openxmlformats.org/wordprocessingml/2006/main')
  $space = $doc.CreateAttribute('xml','space','http://www.w3.org/XML/1998/namespace')
  $space.Value = 'preserve'
  [void]$t.Attributes.Append($space)
  $t.InnerText = $text
  [void]$r.AppendChild($t)
  [void]$p.AppendChild($r)
}

$mapObject = Get-Content -Raw -LiteralPath $ReplaceJson | ConvertFrom-Json
$map = @{}
$trimMap = @{}
foreach ($prop in $mapObject.PSObject.Properties) {
  $map[$prop.Name] = [string]$prop.Value
  $trimMap[$prop.Name.Trim()] = [string]$prop.Value
}

Copy-Item -LiteralPath $Source -Destination $Output -Force
$zip = [System.IO.Compression.ZipFile]::Open((Resolve-Path -LiteralPath $Output).Path, [IO.Compression.ZipArchiveMode]::Update)
try {
  $entry = $zip.GetEntry('word/document.xml')
  $stream = $entry.Open()
  try {
    $reader = [IO.StreamReader]::new($stream)
    try { [xml]$xml = $reader.ReadToEnd() } finally { $reader.Dispose() }
  } finally { $stream.Dispose() }

  $ns = [Xml.XmlNamespaceManager]::new($xml.NameTable)
  $ns.AddNamespace('w','http://schemas.openxmlformats.org/wordprocessingml/2006/main')
  $changed = 0
  foreach ($p in @($xml.SelectNodes('//w:body/w:p', $ns))) {
    $text = Get-ParaText $p $ns
    if ($map.ContainsKey($text)) {
      Set-ParaText $xml $p $ns $map[$text]
      $changed++
    }
    elseif ($trimMap.ContainsKey($text.Trim())) {
      Set-ParaText $xml $p $ns $trimMap[$text.Trim()]
      $changed++
    }
  }

  $newXml = $xml.OuterXml
  $entry.Delete()
  $newEntry = $zip.CreateEntry('word/document.xml')
  $stream = $newEntry.Open()
  try {
    $writer = [IO.StreamWriter]::new($stream, [Text.UTF8Encoding]::new($false))
    try { $writer.Write($newXml) } finally { $writer.Dispose() }
  } finally { $stream.Dispose() }
} finally { $zip.Dispose() }

"Applied $changed replacements to $Output"

