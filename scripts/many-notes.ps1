[CmdletBinding()]
param(
    [ValidateSet('start', 'stop', 'restart', 'status', 'logs', 'open', 'update', 'remove', 'help')]
    [string]$Action = 'start'
)

$ErrorActionPreference = 'Stop'

$ContainerName = 'scoop-many-notes'
$Image = 'brufdev/many-notes:latest'
$Port = 8180
$AppUrl = "http://localhost:$Port"

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

function Start-Container {
    param([switch]$Refresh)

    Assert-Docker

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
            Write-Host "Many Notes is already running at $AppUrl"
            return
        } else {
            & docker.exe container start $ContainerName
            if ($LASTEXITCODE -ne 0) { throw "Could not start container $ContainerName." }
            Write-Host "Many Notes is running at $AppUrl"
            return
        }
    }

    $dockerArgs = @(
        'run', '--detach',
        '--name', $ContainerName,
        '--restart', 'unless-stopped',
        '--publish', "127.0.0.1:$($Port):8080",
        '--env', "APP_URL=$AppUrl",
        '--volume', 'scoop-many-notes-database:/var/www/html/database/sqlite',
        '--volume', 'scoop-many-notes-logs:/var/www/html/storage/logs',
        '--volume', 'scoop-many-notes-private:/var/www/html/storage/app/private',
        '--volume', 'scoop-many-notes-typesense:/var/www/html/typesense',
        $Image
    )
    & docker.exe @dockerArgs
    if ($LASTEXITCODE -ne 0) { throw 'Docker could not create the Many Notes container.' }

    Write-Host "Many Notes is running at $AppUrl"
    Write-Host 'Data is stored in Docker named volumes and is retained when this Scoop package is removed.'
}

function Stop-Container {
    Assert-Docker
    $containerImageId = Get-ContainerImageId
    if ($null -eq $containerImageId) {
        Write-Host 'Many Notes container does not exist.'
        return
    }

    $running = (& docker.exe container inspect --format '{{.State.Running}}' $ContainerName | Select-Object -First 1)
    if ([string]$running -eq 'true') {
        & docker.exe container stop $ContainerName
        if ($LASTEXITCODE -ne 0) { throw "Could not stop container $ContainerName." }
    }
    Write-Host 'Many Notes is stopped.'
}

function Show-Status {
    Assert-Docker
    $containerImageId = Get-ContainerImageId
    if ($null -eq $containerImageId) {
        Write-Host 'Many Notes container is not installed.'
        return
    }
    & docker.exe container ps --all --filter "name=^/$ContainerName$" --format 'table {{.Names}}\t{{.Status}}\t{{.Ports}}'
    if ($LASTEXITCODE -ne 0) { throw 'Could not read Many Notes container status.' }
}

function Remove-ContainerAndKeepData {
    Assert-Docker
    $containerImageId = Get-ContainerImageId
    if ($null -eq $containerImageId) {
        Write-Host 'Many Notes container does not exist.'
        return
    }
    & docker.exe container rm --force $ContainerName
    if ($LASTEXITCODE -ne 0) { throw "Could not remove container $ContainerName." }
    Write-Host 'Container removed. Docker data volumes were intentionally retained.'
}

switch ($Action) {
    'start'   { Start-Container }
    'restart' { Start-Container -Refresh }
    'update'  { Start-Container -Refresh }
    'stop'    { Stop-Container }
    'status'  { Show-Status }
    'logs' {
        Assert-Docker
        if ($null -eq (Get-ContainerImageId)) { throw 'Many Notes container does not exist yet. Run: many-notes start' }
        & docker.exe container logs --follow $ContainerName
        if ($LASTEXITCODE -ne 0) { throw 'Could not read Many Notes logs.' }
    }
    'open' {
        Start-Container
        Start-Process $AppUrl
    }
    'remove'  { Remove-ContainerAndKeepData }
    'help' {
        Write-Host 'many-notes [start|stop|restart|status|logs|open|update|remove]'
        Write-Host "Local URL: $AppUrl"
        Write-Host 'Requires Docker Desktop with Linux containers.'
    }
}