$ErrorActionPreference = 'Stop'
$repoRoot = Split-Path $PSScriptRoot -Parent
$manifest = Get-Content (Join-Path $repoRoot 'bucket\mumuplayer.json') -Raw | ConvertFrom-Json
$hookText = @($manifest.pre_install) -join [Environment]::NewLine
$postUninstallText = @($manifest.post_uninstall) -join [Environment]::NewLine

function Assert([bool]$ok,[string]$message) {
    if (-not $ok) { throw $message }
}
function Equal($actual,$expected,[string]$message) {
    if ([string]$actual -ine [string]$expected) {
        throw "$message Actual='$actual'; Expected='$expected'"
    }
}

$tokens = $null
$parseErrors = $null
[System.Management.Automation.Language.Parser]::ParseInput($hookText,[ref]$tokens,[ref]$parseErrors) | Out-Null
Assert ($parseErrors.Count -eq 0) 'pre_install PowerShell syntax error.'
[System.Management.Automation.Language.Parser]::ParseInput($postUninstallText,[ref]$tokens,[ref]$parseErrors) | Out-Null
Assert ($parseErrors.Count -eq 0) 'post_uninstall PowerShell syntax error.'
Assert ($manifest.architecture.'64bit'.url -match '-overseas-') 'Manifest must remain on the MuMuPlayer Global channel.'
Assert (@($manifest.persist) -contains 'configs' -and @($manifest.persist) -contains 'vms' -and @($manifest.persist) -contains 'nx_device') 'Manifest must persist configs, vms and nx_device.'
Equal $manifest.shortcuts[0][0] 'nx_main\MuMuNxMain.exe' 'Shortcut must point to the NX-main executable.'

foreach ($marker in @(
    'Get-MuMuPreviousScoopVersionRoot',
    'Update-MuMuUninstallRegistration',
    'Update-MuMuServicePath',
    'Restore-MuMuRegistryChanges',
    'MuMuPlayerRemoteService',
    'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\MuMuPlayerGlobal'
)) {
    Assert ($hookText.Contains($marker)) "Missing Registry/service handling: $marker"
}
foreach ($marker in @(
    'Move-MuMuInstallRootToVersion',
    'Move-MuMuPersistDataIntoVersion',
    'Find-MuMuPreviousVersionInstallRoot',
    '$appDataConfigPaths'
)) {
    Assert (-not $hookText.Contains($marker)) "Unexpected migration/discovery logic remains: $marker"
}
Assert ($postUninstallText.Contains('Stop-Service')) 'Uninstall cleanup must stop the MuMuPlayer service.'
Assert ($postUninstallText.Contains('sc.exe delete')) 'Uninstall cleanup must delete the MuMuPlayer service.'
Assert ($postUninstallText.Contains('Remove-Item -LiteralPath $registryPath')) 'Uninstall cleanup must remove matching Registry entries.'
Assert ($postUninstallText.Contains('Keep any unexpected files')) 'Uninstall cleanup must retain unexpected legacy files.'

$root = Join-Path $env:RUNNER_TEMP ('mumu-registry-' + [guid]::NewGuid().ToString('N'))
$appRoot = Join-Path $root 'Scoop Root\apps\mumuplayer'
$persistRoot = Join-Path $root 'Global Persist\mumuplayer'
$oldVersion = '1.8.15.6065'
$newVersion = [string]$manifest.version
$oldRoot = Join-Path $appRoot $oldVersion
$newRoot = Join-Path $appRoot $newVersion
$installerPath = Join-Path $root 'fake-mumu-installer.exe'
$registryRoot = 'HKCU:\Software\KiroBucketMuMuTests\' + [guid]::NewGuid().ToString('N')
$registryPath = Join-Path $registryRoot 'MuMuPlayerGlobal'
$legacyRoot = Join-Path $persistRoot 'install'

try {
    New-Item -ItemType Directory -Path $appRoot,$oldRoot,$persistRoot -Force | Out-Null
    New-Item -ItemType Directory -Path (Join-Path $oldRoot 'nx_main') -Force | Out-Null
    Set-Content (Join-Path $oldRoot 'nx_main\MuMuNxMain.exe') 'previous-version-main'
    New-Item -ItemType Directory -Path $registryRoot -Force | Out-Null
    New-Item -Path $registryPath -Force | Out-Null
    Set-ItemProperty -LiteralPath $registryPath -Name InstallLocation -Value $oldRoot
    Set-ItemProperty -LiteralPath $registryPath -Name UninstallString -Value ('"' + (Join-Path $oldRoot 'uninstall.exe') + '"')
    Set-ItemProperty -LiteralPath $registryPath -Name DisplayIcon -Value (Join-Path $oldRoot 'nx_main\MuMuNxMain.exe')
    Set-ItemProperty -LiteralPath $registryPath -Name DisplayVersion -Value '6.8.15.0'

    $script:MockMuMuServicePath = '"' + (Join-Path $oldRoot 'nx_main\MuMuPlayerRemoteService.exe') + '" --service'
    $script:MockInstallerPath = $installerPath
    $script:MockPrepareExitCode = 80011
    Set-Content -LiteralPath $installerPath 'mock-installer'

    $env:MUMU_SCOOP_TEST_MODE = '1'
    $env:MUMU_SCOOP_TEST_REGISTRY_PATH = $registryPath
    $env:APPDATA = Join-Path $root 'Roaming'
    $env:USERPROFILE = $root
    New-Item -ItemType Directory -Path $env:APPDATA -Force | Out-Null

    function is_admin { return $true }
    function cache_path {
        param($App,$Version,$Url)
        return $script:MockInstallerPath
    }
    function Start-Sleep {
        param([int]$Seconds,[int]$Milliseconds)
    }
    function Start-Process {
        param(
            [string]$FilePath,
            [string[]]$ArgumentList,
            [switch]$Wait,
            [switch]$PassThru
        )
        Assert (Test-Path -LiteralPath $FilePath -PathType Leaf) 'Mock installer file is missing.'
        $actionArg = $ArgumentList | Where-Object { $_ -like '/action=*' } | Select-Object -First 1
        $dirArg = $ArgumentList | Where-Object { $_ -like '/D=*' } | Select-Object -First 1
        Assert ($actionArg -and $dirArg) 'Missing MuMu installer action or /D argument.'
        Equal $ArgumentList[-1] $dirArg '/D must remain the final installer argument.'
        Equal $dirArg ("/D=" + $script:ExpectedInstallRoot) 'Installer must target the real Scoop version directory.'

        $action = $actionArg.Substring(8)
        if ($action -eq 'install_prepare' -and $script:MockPrepareExitCode -ne 0) {
            return [pscustomobject]@{ ExitCode = $script:MockPrepareExitCode }
        }
        if ($action -eq 'install_prepare') {
            return [pscustomobject]@{ ExitCode = 0 }
        }
        if ($action -eq 'commit') {
            New-Item -ItemType Directory -Path (Join-Path $script:ExpectedInstallRoot 'nx_main') -Force | Out-Null
            Set-Content (Join-Path $script:ExpectedInstallRoot 'nx_main\MuMuNxMain.exe') 'new-version-main'
            Set-Content (Join-Path $script:ExpectedInstallRoot 'nx_main\MuMuPlayerRemoteService.exe') 'new-version-service'
            return [pscustomobject]@{ ExitCode = 0 }
        }
        throw "Unexpected mock installer action: $action"
    }

    function Invoke-MuMuInstallHook([string]$Version) {
        $script:dir = Join-Path $script:AppRoot $Version
        $script:fname = "MuMu-setup-$Version.exe"
        $script:version = $Version
        $script:app = 'mumuplayer'
        $script:persist_dir = $script:PersistRoot
        $script:ExpectedInstallRoot = $script:dir
        New-Item -ItemType Directory -Path $script:dir -Force | Out-Null
        Set-Content (Join-Path $script:dir $script:fname) 'downloaded-installer'
        . ([scriptblock]::Create($script:HookText))
    }

    $script:AppRoot = $appRoot
    $script:PersistRoot = $persistRoot
    $script:HookText = $hookText

    # Failed setup must not change Registry or service paths.
    $failed = $false
    try {
        Invoke-MuMuInstallHook -Version $newVersion
    } catch {
        $failed = $true
        if ($_.Exception.Message -notmatch '80011') { throw }
    }
    Assert $failed 'The injected setup failure was not surfaced.'
    Equal (Get-ItemProperty -LiteralPath $registryPath).InstallLocation $oldRoot 'Registry changed after failed setup.'
    Assert ($script:MockMuMuServicePath -like "*$oldRoot*") 'Service path changed after failed setup.'

    # Successful setup changes only references to the immediately previous Scoop version directory.
    $script:MockPrepareExitCode = 0
    Set-Content -LiteralPath $installerPath 'mock-installer'
    Invoke-MuMuInstallHook -Version $newVersion

    Assert (Test-Path -LiteralPath (Join-Path $newRoot 'nx_main\MuMuNxMain.exe') -PathType Leaf) 'New payload was not created inside the Scoop version directory.'
    Equal (Get-ItemProperty -LiteralPath $registryPath).InstallLocation $newRoot 'Registry InstallLocation was not updated.'
    Assert ([string](Get-ItemProperty -LiteralPath $registryPath).UninstallString -like ('*' + (Join-Path $newRoot 'uninstall.exe') + '*')) 'Registry UninstallString was not updated.'
    Assert ([string](Get-ItemProperty -LiteralPath $registryPath).DisplayIcon -like ('*' + (Join-Path $newRoot 'nx_main\MuMuNxMain.exe') + '*')) 'Registry DisplayIcon was not updated.'
    Equal $script:MockMuMuServicePath ('"' + (Join-Path $newRoot 'nx_main\MuMuPlayerRemoteService.exe') + '" --service') 'Service image path was not updated.'
    Assert (Test-Path -LiteralPath (Join-Path $oldRoot 'nx_main\MuMuNxMain.exe')) 'The old Scoop version directory was moved or deleted.'

    # Build legacy persist junctions to verify safe full-uninstall cleanup.
    New-Item -ItemType Directory -Path $legacyRoot -Force | Out-Null
    foreach ($name in @('configs','vms','nx_device')) {
        $persistent = Join-Path $persistRoot $name
        New-Item -ItemType Directory -Path $persistent -Force | Out-Null
        Set-Content (Join-Path $persistent 'keep.txt') "keep-$name"
        New-Item -ItemType Junction -Path (Join-Path $legacyRoot $name) -Value $persistent | Out-Null
    }
    Set-Content (Join-Path $legacyRoot 'keep-unexpected-file.txt') 'retain-this-file'

    $script:dir = $newRoot
    $script:persist_dir = $persistRoot
    $script:cmd = 'update'
    . ([scriptblock]::Create($postUninstallText))
    Assert (Test-Path -LiteralPath $registryPath) 'Update-time post_uninstall removed Registry.'
    Assert ($script:MockMuMuServicePath -like "*$newRoot*") 'Update-time post_uninstall removed the service.'
    Assert (Test-Path -LiteralPath (Join-Path $legacyRoot 'configs')) 'Update-time post_uninstall detached persist links.'

    $script:cmd = 'uninstall'
    . ([scriptblock]::Create($postUninstallText))
    Assert (-not (Test-Path -LiteralPath $registryPath)) 'Full uninstall did not remove the matching Registry entry.'
    Assert ([string]::IsNullOrWhiteSpace($script:MockMuMuServicePath)) 'Full uninstall did not remove the Scoop-owned service.'
    foreach ($name in @('configs','vms','nx_device')) {
        Assert (Test-Path -LiteralPath (Join-Path (Join-Path $persistRoot $name) 'keep.txt')) "Uninstall removed persistent $name data."
        Assert (-not (Test-Path -LiteralPath (Join-Path $legacyRoot $name))) "Uninstall did not detach the $name junction."
    }
    Equal (Get-Content (Join-Path $legacyRoot 'keep-unexpected-file.txt') -Raw).Trim() 'retain-this-file' 'Uninstall removed unexpected legacy data.'
    Assert (Test-Path -LiteralPath (Join-Path $newRoot 'nx_main\MuMuNxMain.exe')) 'post_uninstall removed program files instead of leaving them to Scoop.'

    @(
        '## MuMuPlayer Registry and uninstall regression'
        ''
        '- Injected installer failure and verified no Registry or service paths changed.'
        '- Verified successful update rewrites Registry InstallLocation, UninstallString and DisplayIcon.'
        '- Verified MuMuPlayerRemoteService image path follows the new Scoop version directory.'
        '- Verified update-time post_uninstall leaves Registry, service and persist links intact.'
        '- Verified full uninstall removes only matching Registry/service entries.'
        '- Verified known legacy persist junctions are detached while persistent data and unexpected files remain.'
        ''
        'Mock installer only; it does not boot Android or validate host virtualization drivers.'
    ) | Out-File $env:GITHUB_STEP_SUMMARY -Encoding utf8
    Write-Host 'MuMuPlayer Registry and uninstall regression passed.'
} finally {
    if (Test-Path -LiteralPath $registryRoot) {
        Remove-Item -LiteralPath $registryRoot -Recurse -Force -ErrorAction SilentlyContinue
    }
    if (Test-Path -LiteralPath $root) {
        Remove-Item -LiteralPath $root -Recurse -Force -ErrorAction SilentlyContinue
    }
    Remove-Item Env:\MUMU_SCOOP_TEST_MODE -ErrorAction SilentlyContinue
    Remove-Item Env:\MUMU_SCOOP_TEST_REGISTRY_PATH -ErrorAction SilentlyContinue
}

$global:LASTEXITCODE = 0
