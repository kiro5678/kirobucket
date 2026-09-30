param(
    [Parameter(Mandatory)]
    [string]$ProductId,

    [Parameter(Mandatory)]
    [string]$OutputPath,

    [ValidateSet('x64', 'x86', 'arm64')]
    [string]$Architecture = 'x64'
)

$ErrorActionPreference = 'Stop'

$winget = Get-Command winget.exe -ErrorAction SilentlyContinue
if (-not $winget) { throw 'winget.exe was not found.' }

& $winget.Source download `
    --id $ProductId `
    --source msstore `
    --exact `
    --architecture $Architecture `
    --platform Windows.Desktop `
    --download-directory $OutputPath `
    --skip-license `
    --accept-source-agreements `
    --accept-package-agreements `
    --disable-interactivity

if ($LASTEXITCODE -ne 0) { throw "winget download failed with exit code $LASTEXITCODE." }

$package = Get-ChildItem -LiteralPath $OutputPath -File |
    Where-Object { $_.Extension -in '.msix', '.msixbundle', '.appx', '.appxbundle' } |
    Sort-Object LastWriteTime -Descending |
    Select-Object -First 1

if (-not $package) { throw 'WinGet did not place an MSIX/AppX package in the Scoop app directory.' }

$package.FullName
