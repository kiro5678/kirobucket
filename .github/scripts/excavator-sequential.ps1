$ErrorActionPreference = 'Stop'
$ProgressPreference = 'SilentlyContinue'

$bucketPath = Join-Path $env:GITHUB_WORKSPACE 'bucket'
if (-not (Test-Path -LiteralPath $bucketPath -PathType Container)) {
    throw "Scoop bucket directory not found: $bucketPath"
}

# Use the same official Scoop installation locations as ScoopInstaller/GithubActions.
$env:SCOOP = Join-Path $env:USERPROFILE 'SCOOP'
$env:SCOOP_HOME = Join-Path $env:SCOOP 'apps\scoop\current'
$env:SCOOP_GLOBAL = Join-Path $env:SystemDrive 'SCOOP'
$shimsPath = Join-Path $env:SCOOP 'shims'

if (-not (Get-Command 'scoop' -ErrorAction SilentlyContinue)) {
    Invoke-RestMethod 'https://raw.githubusercontent.com/ScoopInstaller/Install/master/install.ps1' |
        Invoke-Expression
}

if (Test-Path -LiteralPath $shimsPath -PathType Container) {
    $env:PATH = "$shimsPath;$env:PATH"
}

if (-not (Get-Command 'scoop' -ErrorAction SilentlyContinue)) {
    throw 'The official Scoop installer completed but the scoop command is unavailable.'
}

& scoop config USE_EXTERNAL_7ZIP $true
if ($LASTEXITCODE -ne 0) {
    throw 'Could not configure Scoop to use the runner 7-Zip installation.'
}

$checkverPath = Join-Path $env:SCOOP_HOME 'bin\checkver.ps1'
if (-not (Test-Path -LiteralPath $checkverPath -PathType Leaf)) {
    throw "Official Scoop Checkver script not found: $checkverPath"
}

if ([string]::IsNullOrWhiteSpace($env:SCOOP_GH_TOKEN)) {
    throw 'SCOOP_GH_TOKEN is empty. Configure CHECKVER_GITHUB_TOKEN or allow the workflow GITHUB_TOKEN fallback.'
}

$requestedNames = @(
    [string]$env:MANIFEST_FILTER -split '[,;\r\n]+' |
        ForEach-Object { $_.Trim() } |
        Where-Object { -not [string]::IsNullOrWhiteSpace($_) }
)

if ($requestedNames.Count -gt 0) {
    $manifestFiles = [System.Collections.Generic.List[System.IO.FileInfo]]::new()
    foreach ($name in $requestedNames) {
        if ($name -notmatch '^[A-Za-z0-9][A-Za-z0-9._+-]*$') {
            throw "Invalid manifest name '$name'. Supply names without paths or .json extensions."
        }

        $path = Join-Path $bucketPath "$name.json"
        if (-not (Test-Path -LiteralPath $path -PathType Leaf)) {
            throw "Requested manifest does not exist: bucket/$name.json"
        }
        $manifestFiles.Add((Get-Item -LiteralPath $path))
    }
    $manifestFiles = @($manifestFiles | Sort-Object FullName -Unique)
} else {
    $manifestFiles = @(
        Get-ChildItem -LiteralPath $bucketPath -Filter '*.json' -File |
            Sort-Object Name
    )
}

Write-Host "Sequential Scoop Checkver scan: $($manifestFiles.Count) manifest file(s)."
Write-Host 'Each manifest is checked in a separate official Checkver invocation to avoid parallel GitHub request bursts.'

$checked = 0
$skipped = 0
$invocationErrors = 0

foreach ($manifestFile in $manifestFiles) {
    $appName = $manifestFile.BaseName

    try {
        $manifest = Get-Content -LiteralPath $manifestFile.FullName -Raw -Encoding utf8 |
            ConvertFrom-Json -ErrorAction Stop

        if (-not $manifest.checkver) {
            $skipped++
            continue
        }

        $checked++
        Write-Host ''
        Write-Host "========== Checkver: $appName =========="

        $checkOutput = @(
            & $checkverPath -App $appName -Dir $bucketPath -Update -SkipUpdated -ThrowError *>&1
        )
        foreach ($line in $checkOutput) {
            Write-Output ([string]$line)
        }

        $diagnostics = ($checkOutput | ForEach-Object { [string]$_ }) -join [Environment]::NewLine
        if ($diagnostics -match '(?i)abuse detection|secondary rate.?limit|API rate limit exceeded|rate limit exceeded|too many requests|status code.*\b(?:403|429)\b|remote server returned an error: \((?:403|429)\)') {
            Write-Warning "$appName encountered a GitHub rate-limit response. Pausing for 90 seconds before the next manifest."
            Start-Sleep -Seconds 90
        } else {
            Start-Sleep -Milliseconds 1200
        }
    } catch {
        $invocationErrors++
        $message = $_.Exception.Message -replace '[\r\n]+', ' '
        Write-Output "ERROR Could not update $($appName), sequential Checkver invocation failed: $message"

        if ($message -match '(?i)abuse detection|secondary rate.?limit|API rate limit exceeded|rate limit exceeded|too many requests|status code.*\b(?:403|429)\b') {
            Write-Warning "$appName triggered a rate-limit response. Pausing for 90 seconds before the next manifest."
            Start-Sleep -Seconds 90
        } else {
            Start-Sleep -Milliseconds 1200
        }
    }
}

Write-Host ''
Write-Host "Checkver scan completed. Checked: $checked; skipped (no checkver): $skipped; invocation errors: $invocationErrors."

# Commit only manifest changes made by Checkver. The checkout token is used for Git push;
# SCOOP_GH_TOKEN is reserved for upstream Checkver/download requests.
git config user.name 'github-actions[bot]'
if ($LASTEXITCODE -ne 0) { throw 'Could not configure the Git commit author name.' }
git config user.email '41898282+github-actions[bot]@users.noreply.github.com'
if ($LASTEXITCODE -ne 0) { throw 'Could not configure the Git commit author email.' }

git add -- bucket
if ($LASTEXITCODE -ne 0) { throw 'Could not stage updated Scoop manifests.' }

git diff --cached --quiet
$diffExit = $LASTEXITCODE
if ($diffExit -eq 0) {
    Write-Host 'No manifest changes to commit.'
    exit 0
}
if ($diffExit -ne 1) {
    throw "git diff --cached failed with exit code $diffExit."
}

$updatedFiles = @(git diff --cached --name-only -- bucket)
$updatedCount = $updatedFiles.Count
git commit -m "chore: update $updatedCount Scoop manifest(s)"
if ($LASTEXITCODE -ne 0) { throw 'Could not commit updated Scoop manifests.' }

git fetch origin master
if ($LASTEXITCODE -ne 0) { throw 'Could not fetch the latest master before pushing Excavator updates.' }

git rebase origin/master
if ($LASTEXITCODE -ne 0) {
    git rebase --abort 2>$null
    throw 'Could not rebase Excavator manifest updates onto the latest master. No updates were pushed.'
}

git push origin HEAD:master
if ($LASTEXITCODE -ne 0) {
    throw 'Could not push Excavator manifest updates to master.'
}

Write-Host "Pushed $updatedCount updated manifest(s) to master."
