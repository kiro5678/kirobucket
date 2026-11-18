[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]$BucketPath,

    [string]$BucketName = 'kirobucket',

    [string]$ScoopRoot = $env:SCOOP,

    [string]$ReportPath
)

$ErrorActionPreference = 'Stop'

if ([string]::IsNullOrWhiteSpace($ScoopRoot)) {
    $ScoopRoot = 'D:\Scoop'
}

if (-not (Test-Path -LiteralPath $BucketPath -PathType Container)) {
    throw 'The bucket directory could not be found.'
}

if (-not (Test-Path -LiteralPath $ScoopRoot -PathType Container)) {
    throw 'The configured Scoop root could not be found.'
}

$BucketPath = (Resolve-Path -LiteralPath $BucketPath).Path
$ScoopRoot = (Resolve-Path -LiteralPath $ScoopRoot).Path

if ([string]::IsNullOrWhiteSpace($ReportPath)) {
    $ReportPath = Join-Path $ScoopRoot 'reports\kirobucket-installation-report.html'
}

function Get-ObjectProperty {
    param(
        [object]$InputObject,
        [string]$PropertyName
    )

    if ($null -eq $InputObject) {
        return $null
    }

    $property = $InputObject.PSObject.Properties[$PropertyName]
    if ($null -ne $property) {
        return $property.Value
    }

    return $null
}

function ConvertTo-HtmlSafe {
    param([AllowNull()][object]$Value)

    if ($null -eq $Value) {
        return ''
    }

    return [System.Net.WebUtility]::HtmlEncode([string]$Value)
}

# Read every JSON manifest in the repository's bucket directory.
$manifestFiles = @(
    Get-ChildItem -LiteralPath $BucketPath -File -Recurse |
        Where-Object { $_.Extension -ieq '.json' } |
        Sort-Object Name
)

if ($manifestFiles.Count -eq 0) {
    throw 'No JSON manifests were found in the bucket directory.'
}

$manifests = [System.Collections.Generic.List[object]]::new()
$manifestNames = [System.Collections.Generic.HashSet[string]]::new(
    [System.StringComparer]::OrdinalIgnoreCase
)

foreach ($file in $manifestFiles) {
    $name = [System.IO.Path]::GetFileNameWithoutExtension($file.Name)

    if (-not $manifestNames.Add($name)) {
        throw 'Duplicate manifest names were found in the bucket directory.'
    }

    try {
        $manifest = Get-Content -LiteralPath $file.FullName -Raw |
            ConvertFrom-Json -ErrorAction Stop
    }
    catch {
        throw 'A bucket manifest contains invalid JSON. Correct the manifest before running the comparison.'
    }

    $manifests.Add([PSCustomObject]@{
        Name            = $name
        ManifestVersion = [string](Get-ObjectProperty -InputObject $manifest -PropertyName 'version')
    })
}

# Use Scoop's own export command so the comparison uses Scoop's installed-app
# inventory and source metadata rather than guessing from folder names.
$env:SCOOP = $ScoopRoot
$shimDirectory = Join-Path $ScoopRoot 'shims'
if (Test-Path -LiteralPath $shimDirectory -PathType Container) {
    $env:Path = "$shimDirectory;$env:Path"
}

$scoopCommandPath = Join-Path $shimDirectory 'scoop.ps1'
if (-not (Test-Path -LiteralPath $scoopCommandPath -PathType Leaf)) {
    $scoopCommand = Get-Command scoop -ErrorAction SilentlyContinue |
        Select-Object -First 1

    if ($null -eq $scoopCommand -or [string]::IsNullOrWhiteSpace($scoopCommand.Source)) {
        throw 'The Scoop command could not be located on this runner.'
    }

    $scoopCommandPath = $scoopCommand.Source
}

try {
    $exportOutput = @(& $scoopCommandPath export 2>$null)
    $exportJson = $exportOutput -join [Environment]::NewLine

    if ([string]::IsNullOrWhiteSpace($exportJson)) {
        throw 'Scoop export returned no data.'
    }

    $scoopExport = $exportJson | ConvertFrom-Json -ErrorAction Stop
}
catch {
    throw 'Could not read the installed-app inventory from Scoop. Check the Scoop root and runner account.'
}

$installedByName = [System.Collections.Generic.Dictionary[string, object]]::new(
    [System.StringComparer]::OrdinalIgnoreCase
)

foreach ($app in @($scoopExport.apps)) {
    $installedName = [string](Get-ObjectProperty -InputObject $app -PropertyName 'Name')

    if ([string]::IsNullOrWhiteSpace($installedName)) {
        continue
    }

    if (-not $installedByName.ContainsKey($installedName)) {
        $installedByName[$installedName] = [System.Collections.Generic.List[object]]::new()
    }

    $installedByName[$installedName].Add($app)
}

$rows = [System.Collections.Generic.List[object]]::new()

foreach ($manifest in $manifests) {
    $installedVersion = ''
    $source = ''
    $status = 'Not installed'
    $statusClass = 'missing'

    if ($installedByName.ContainsKey($manifest.Name)) {
        $matches = $installedByName[$manifest.Name]
        $matchingBucketInstall = $null

        foreach ($candidate in $matches) {
            $candidateSource = [string](Get-ObjectProperty -InputObject $candidate -PropertyName 'Source')
            $sourceLeaf = $candidateSource.TrimEnd([char[]]@('\', '/'))
            if (
                $candidateSource -ieq $BucketName -or
                [System.IO.Path]::GetFileName($sourceLeaf) -ieq $BucketName
            ) {
                $matchingBucketInstall = $candidate
                break
            }
        }

        $selectedInstall = if ($null -ne $matchingBucketInstall) {
            $matchingBucketInstall
        }
        else {
            $matches[0]
        }

        $installedVersion = [string](Get-ObjectProperty -InputObject $selectedInstall -PropertyName 'Version')
        $source = [string](Get-ObjectProperty -InputObject $selectedInstall -PropertyName 'Source')

        if ($null -ne $matchingBucketInstall) {
            $status = "Installed from $BucketName"
            $statusClass = 'installed'
        }
        else {
            $status = 'Installed from another source'
            $statusClass = 'other-source'
        }
    }

    $rows.Add([PSCustomObject]@{
        Name            = $manifest.Name
        ManifestVersion = $manifest.ManifestVersion
        InstalledVersion = $installedVersion
        Source          = $source
        Status          = $status
        StatusClass     = $statusClass
    })
}

$totalCount = $rows.Count
$installedCount = @($rows | Where-Object { $_.StatusClass -ne 'missing' }).Count
$sameBucketCount = @($rows | Where-Object { $_.StatusClass -eq 'installed' }).Count
$otherSourceCount = @($rows | Where-Object { $_.StatusClass -eq 'other-source' }).Count
$missingCount = @($rows | Where-Object { $_.StatusClass -eq 'missing' }).Count
$coverage = if ($totalCount -gt 0) {
    [math]::Round(($installedCount / $totalCount) * 100, 1)
}
else {
    0
}

$tableRows = foreach ($row in $rows) {
    $nameHtml = ConvertTo-HtmlSafe $row.Name
    $manifestVersionHtml = ConvertTo-HtmlSafe $row.ManifestVersion
    $installedVersionHtml = ConvertTo-HtmlSafe $row.InstalledVersion
    $sourceHtml = ConvertTo-HtmlSafe $row.Source
    $statusHtml = ConvertTo-HtmlSafe $row.Status

    "<tr><td>$nameHtml</td><td>$manifestVersionHtml</td><td>$installedVersionHtml</td><td>$sourceHtml</td><td><span class=""status $($row.StatusClass)"">$statusHtml</span></td></tr>"
}

$generatedAt = (Get-Date).ToString('yyyy-MM-dd HH:mm:ss')
$bucketNameHtml = ConvertTo-HtmlSafe $BucketName
$progressWidth = [math]::Max(0, [math]::Min(100, $coverage))

$html = @"
<!doctype html>
<html lang="en">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>$bucketNameHtml - Scoop installation comparison</title>
<style>
:root { color-scheme: light dark; font-family: Segoe UI, Arial, sans-serif; }
body { max-width: 1180px; margin: 32px auto; padding: 0 20px; line-height: 1.5; }
h1 { margin-bottom: 4px; }
.muted { opacity: .7; }
.summary { display: grid; grid-template-columns: repeat(auto-fit, minmax(150px, 1fr)); gap: 12px; margin: 24px 0 14px; }
.card { border: 1px solid #8885; border-radius: 10px; padding: 14px; }
.value { display: block; font-size: 1.8rem; font-weight: 700; }
.progress { height: 10px; background: #8884; border-radius: 99px; overflow: hidden; margin: 14px 0 24px; }
.progress span { display: block; height: 100%; width: $progressWidth%; background: #16a34a; }
table { width: 100%; border-collapse: collapse; }
th, td { text-align: left; padding: 10px 12px; border-bottom: 1px solid #8884; }
th { position: sticky; top: 0; background: Canvas; }
.status { display: inline-block; border-radius: 6px; padding: 3px 8px; font-size: .88rem; white-space: nowrap; }
.installed { color: #15803d; background: #16a34a22; }
.other-source { color: #b7791f; background: #d69e1822; }
.missing { color: #b45309; background: #f59e0b22; }
footer { margin-top: 24px; opacity: .7; font-size: .9rem; }
@media (max-width: 700px) { .table-wrap { overflow-x: auto; } th, td { white-space: nowrap; } }
</style>
</head>
<body>
<h1>$bucketNameHtml</h1>
<div class="muted">Scoop manifest installation coverage · Generated locally: $generatedAt</div>
<div class="summary">
  <div class="card"><span class="value">$totalCount</span><span>Total manifests</span></div>
  <div class="card"><span class="value">$installedCount</span><span>Installed (any source)</span></div>
  <div class="card"><span class="value">$sameBucketCount</span><span>Installed from this bucket</span></div>
  <div class="card"><span class="value">$otherSourceCount</span><span>Installed from another source</span></div>
  <div class="card"><span class="value">$missingCount</span><span>Not installed</span></div>
</div>
<div><strong>Installation coverage:</strong> $coverage%</div>
<div class="progress" role="img" aria-label="Installation coverage $coverage percent"><span></span></div>
<div class="table-wrap">
<table>
<thead><tr><th>Manifest</th><th>Bucket version</th><th>Installed version</th><th>Installed source</th><th>Status</th></tr></thead>
<tbody>
$($tableRows -join [Environment]::NewLine)
</tbody>
</table>
</div>
<footer>The detailed inventory is stored on this machine. It is not uploaded as a workflow artifact or written to the GitHub Actions log.</footer>
</body>
</html>
"@

$reportDirectory = Split-Path -Parent $ReportPath
if (-not [string]::IsNullOrWhiteSpace($reportDirectory)) {
    New-Item -ItemType Directory -Path $reportDirectory -Force | Out-Null
}

Set-Content -LiteralPath $ReportPath -Value $html -Encoding utf8NoBOM

Write-Output 'Local comparison completed. The detailed inventory and report remain on this machine.'
Write-Output "Local report: $ReportPath"
