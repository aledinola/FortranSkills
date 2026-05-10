param(
  [Parameter(Mandatory=$true, Position=0)]
  [string]$Path
)

$ErrorActionPreference = 'Stop'
Add-Type -AssemblyName System.IO.Compression.FileSystem

function Get-DocxParagraphs([string]$FilePath) {
  $zip = [System.IO.Compression.ZipFile]::OpenRead((Resolve-Path -LiteralPath $FilePath).Path)
  try {
    $entry = $zip.GetEntry('word/document.xml')
    $stream = $entry.Open()
    try {
      $reader = [IO.StreamReader]::new($stream)
      try { [xml]$xml = $reader.ReadToEnd() } finally { $reader.Dispose() }
    } finally { $stream.Dispose() }
  } finally { $zip.Dispose() }
  $ns = [Xml.XmlNamespaceManager]::new($xml.NameTable)
  $ns.AddNamespace('w','http://schemas.openxmlformats.org/wordprocessingml/2006/main')
  $items = @()
  foreach ($p in $xml.SelectNodes('//w:body/w:p', $ns)) {
    $line = (($p.SelectNodes('.//w:t', $ns) | ForEach-Object { $_.'#text' }) -join '')
    if ($line.Trim().Length -gt 0) { $items += $line.Trim() }
  }
  return $items
}

function Get-KeyName([string]$Name) {
  $particles = @('van','von','de','da','del','der','den','la','le')
  $tokens = @([regex]::Matches($Name, "[A-Za-z]+") | ForEach-Object { $_.Value })
  if ($tokens.Count -eq 0) { return '' }
  if ($tokens[0].ToLowerInvariant() -in @('university','department','school','college')) { return $tokens[0] }
  for ($i = 0; $i -lt $tokens.Count; $i++) {
    if ($tokens[$i].ToLowerInvariant() -notin $particles) { return $tokens[$i] }
  }
  return $tokens[-1]
}

function Normalize-Key([string]$Name, [string]$Year) {
  $keyName = Get-KeyName $Name
  return (($keyName.ToLowerInvariant() -replace '[^a-z0-9]', '') + ':' + $Year)
}

$paras = Get-DocxParagraphs $Path
$refStart = -1
for ($i = 0; $i -lt $paras.Count; $i++) {
  if ($paras[$i] -match '^References\s*:?$') { $refStart = $i; break }
}
$body = if ($refStart -gt 0) { ($paras[0..($refStart-1)] -join ' ') } else { ($paras -join ' ') }
$refs = if ($refStart -ge 0 -and $refStart + 1 -lt $paras.Count) { $paras[($refStart+1)..($paras.Count-1)] } else { @() }

$refKeys = @{}
$refMeta = @{}
foreach ($ref in $refs) {
  if ($ref -match "^\s*(.+?)\s*\(((?:19|20)\d{2})\)") {
    $name = $Matches[1]
    $year = $Matches[2]
    $keyName = Get-KeyName $name
    $key = (($keyName.ToLowerInvariant() -replace '[^a-z0-9]', '') + ':' + $year)
    $refKeys[$key] = $ref
    $refMeta[$key] = [pscustomobject]@{ KeyName = $keyName; Year = $year; Reference = $ref }
  }
}

$citeKeys = @{}
foreach ($m in [regex]::Matches($body, "([A-Z][A-Za-z''’-]+)\s+et al\.\s*\(((?:19|20)\d{2})\)")) {
  $key = Normalize-Key $m.Groups[1].Value $m.Groups[2].Value
  $citeKeys[$key] = $m.Value
}
foreach ($m in [regex]::Matches($body, "\(([^)]*(?:19|20)\d{2}[^)]*)\)")) {
  $inside = $m.Groups[1].Value
  foreach ($part in ($inside -split ';')) {
    if ($part -match "([A-Z][A-Za-z''’-]+).*?((?:19|20)\d{2})") {
      $key = Normalize-Key $Matches[1] $Matches[2]
      $citeKeys[$key] = '(' + $part.Trim() + ')'
    }
  }
}

# Confirm narrative citations only for known bibliography keys. This avoids treating words like
# "This" or "The" before a year as author names.
foreach ($key in $refMeta.Keys) {
  $meta = $refMeta[$key]
  $namePattern = [regex]::Escape($meta.KeyName)
  $yearPattern = [regex]::Escape($meta.Year)
  $patterns = @(
    "\b$namePattern\b.{0,80}\($yearPattern\)",
    "\b$namePattern\b.{0,80}$yearPattern"
  )
  foreach ($pattern in $patterns) {
    $match = [regex]::Match($body, $pattern, [Text.RegularExpressions.RegexOptions]::IgnoreCase)
    if ($match.Success) { $citeKeys[$key] = $match.Value.Trim(); break }
  }
}

'In-text citation keys:'
$citeKeys.GetEnumerator() | Sort-Object Name | ForEach-Object { "  $($_.Name) <= $($_.Value)" }
'Bibliography keys:'
$refKeys.GetEnumerator() | Sort-Object Name | ForEach-Object { "  $($_.Name) <= $($_.Value)" }
'Missing bibliography entries for citations:'
$missing = @($citeKeys.Keys | Where-Object { -not $refKeys.ContainsKey($_) } | Sort-Object)
if ($missing.Count -eq 0) { '  none' } else { $missing | ForEach-Object { "  $_ <= $($citeKeys[$_])" } }
'Uncited bibliography entries:'
$uncited = @($refKeys.Keys | Where-Object { -not $citeKeys.ContainsKey($_) } | Sort-Object)
if ($uncited.Count -eq 0) { '  none' } else { $uncited | ForEach-Object { "  $_ <= $($refKeys[$_])" } }
