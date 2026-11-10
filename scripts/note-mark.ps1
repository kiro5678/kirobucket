[CmdletBinding()]
param(
    [ValidateSet('start', 'stop', 'restart', 'status', 'logs', 'open', 'update', 'remove', 'help')]
    [string]$Action = 'start'
)

$ErrorActionPreference = 'Stop'

$ContainerName = 'scoop-note-mark'
$Port = 8181
$AppUrl = "http://localhost:$Port"
$VersionFile = Join-Path $PSScriptRoot 'image-tag.txt'
$DataDirectory = Join-Path $PSScriptRoot 'data'
$SecretFile = Join-Path $DataDirectory 'auth-token-secret.txt'

if (-not (Test-Path -LiteralPath $VersionFile -PathType Leaf)) {
    throw 'The image-tag.txt file is missing. Reinstall the Scoop package.'
}
$ImageTag = (Get-Content -LiteralPath $VersionFile -Raw).Trim()
if ($ImageTag -notmatch '^\d+\.\d+\.\d+$') {
    throw "Invalid Note Mark image tag: $ImageTag"
}
$Image = "ghcr.io/enchant97/note-mark:$ImageTag"

function Assert-Docker {
    if (-not (Get-Command 'docker.exe' -ErrorAction SilentlyContinue)) {
        throw 'Docker CLI was not found. Install Docker Desktop and enable Linux containers first.'
    }

    $engineType = (& docker.exe info --format '{{.OSType}}' 2>$null | Out-String).Trim()
    if ($LASTEXITCODE -ne 0 -or $engineType -ne 'linux') {
        throw 'Docker Engine is not running in Linux-container mode. Start Docker Desktop and switch to Linux containers.'
    }
}

function Get-ContainerImageId {
    $value = & docker.exe container inspect --format '{{.Image}}' $ContainerName 2>$null
    if ($LASTEXITCODE -ne 0) { return $null }
    return ([string]($value | Select-Object -First 1)).Trim()
}

function Get-OrCreateAuthSecret {
    New-Item -ItemType Directory -Path $DataDirectory -Force | Out-Null

    if (Test-Path -LiteralPath $SecretFile -PathType Leaf) {
        $secret = (Get-Content -LiteralPath $SecretFile -Raw).Trim()
        if ($secret.Length -ge 64) { return $secret }
        throw 'The saved Note Mark authentication secret is invalid. Back up the data folder before repairing it.'
    }

    $bytes = [byte[]]::new(32)
    $rng = [System.Security.Cryptography.RandomNumberGenerator]::Create()
    try { $rng.GetBytes($bytes) } finally { $rng.Dispose() }
    $secret = [BitConverter]::ToString($bytes).Replace('-', '').ToLowerInvariant()
    Set-Content -LiteralPath $SecretFile -Value $secret -NoNewline -Encoding ascii
    return $secret
}

function Start-Container {
    param([switch]$Refresh)

    Assert-Docker
    $secret = Get-OrCreateAuthSecret

    Write-Host "Pulling $Image ..."
    & docker.exe pull $Image
    if ($LASTEXITCODE -ne 0) { throw "Could not pull Docker image $Image." }

    $imageId = (& docker.exe image inspect --format '{{.Id}}' $Image | Select-Object -First 1)
    if ($LASTEXITCODE -ne 0 -or [string]::IsNullOrWhiteSpace([string]$imageId)) {
        throw "Could not inspect Docker image $Image."
    }
    $imageId = ([string]$imageId).Trim()

    $containerImageId = Get-ContainerImageId
    if ($null -ne $containerImageId) {
        $running = (& docker.exe container inspect --format '{{.State.Running}}' $ContainerName | Select-Object -First 1)
        if ($Refresh -or $containerImageId -ne $imageId) {
            & docker.exe container rm --force $ContainerName
            if ($LASTEXITCODE -ne 0) { throw "Could not replace container $ContainerName." }
        } elseif ([string]$running -eq 'true') {
            Write-Host "Note Mark is already running at $AppUrl"
            return
        } else {
            & docker.exe container start $ContainerName
            if ($LASTEXITCODE -ne 0) { throw "Could not start container $ContainerName." }
            Write-Host "Note Mark is running at $AppUrl"
            return
        }
    }

    $dockerArgs = @(
        'run', '--detach',
        '--name', $ContainerName,
        '--restart', 'unless-stopped',
        '--publish', "127.0.0.1:$($Port):8080",
        '--env', "AUTH_TOKEN__SECRET=$secret",
        '--env', "PUBLIC_URL=$AppUrl",
        '--volume', 'scoop-note-mark-data:/data',
        $Image
    )
    & docker.exe @dockerArgs
    if ($LASTEXITCODE -ne 0) { throw 'Docker could not create the Note Mark container.' }

    Write-Host "Note Mark is running at $AppUrl"
    Write-Host 'Note Mark data is stored in the Docker named volume scoop-note-mark-data.'
    Write-Host 'Its generated authentication secret is stored in the Scoop persist folder.'
}

function Stop-Container {
    Assert-Docker
    $containerImageId = Get-ContainerImageId
    if ($null -eq $containerImageId) {
        Write-Host 'Note Mark container does not exist.'
        return
    }

    $running = (& docker.exe container inspect --format '{{.State.Running}}' $ContainerName | Select-Object -First 1)
    if ([string]$running -eq 'true') {
        & docker.exe container stop $ContainerName
        if ($LASTEXITCODE -ne 0) { throw "Could not stop container $ContainerName." }
    }
    Write-Host 'Note Mark is stopped.'
}

function Show-Status {
    Assert-Docker
    $containerImageId = Get-ContainerImageId
    if ($null -eq $containerImageId) {
        Write-Host 'Note Mark container is not installed.'
        return
    }
    & docker.exe container ps --all --filter "name=^/$ContainerName$" --format 'table {{.Names}}\t{{.Status}}\t{{.Ports}}'
    if ($LASTEXITCODE -ne 0) { throw 'Could not read Note Mark container status.' }
}

function Remove-ContainerAndKeepData {
    Assert-Docker
    $containerImageId = Get-ContainerImageId
    if ($null -eq $containerImageId) {
        Write-Host 'Note Mark container does not exist.'
        return
    }
    & docker.exe container rm --force $ContainerName
    if ($LASTEXITCODE -ne 0) { throw "Could not remove container $ContainerName." }
    Write-Host 'Container removed. Docker data volume and Scoop authentication secret were intentionally retained.'
}

switch ($Action) {
    'start'   { Start-Container }
    'restart' { Start-Container -Refresh }
    'update'  { Start-Container -Refresh }
    'stop'    { Stop-Container }
    'status'  { Show-Status }
    'logs' {
        Assert-Docker
        if ($null -eq (Get-ContainerImageId)) { throw 'Note Mark container does not exist yet. Run: note-mark start' }
        & docker.exe container logs --follow $ContainerName
        if ($LASTEXITCODE -ne 0) { throw 'Could not read Note Mark logs.' }
    }
    'open' {
        Start-Container
        Start-Process $AppUrl
    }
    'remove'  { Remove-ContainerAndKeepData }
    'help' {
        Write-Host 'note-mark [start|stop|restart|status|logs|open|update|remove]'
        Write-Host "Local URL: $AppUrl"
        Write-Host 'Requires Docker Desktop with Linux containers.'
        Write-Host 'Upstream does not officially support Windows hosts.'
    }
}