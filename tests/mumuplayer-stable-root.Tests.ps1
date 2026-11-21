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
function Remove-Junction([string]$Path) {
    $item = Get-Item -LiteralPath $Path -Force -ErrorAction SilentlyContinue
    if (-not $item) { return }
    if ($item.LinkType -ne 'Junction') { throw "Refusing to remove non-junction in test: $Path" }
    [IO.Directory]::Delete($Path, $false)
}
function Remove-ScoopCurrentAndPersistLinks([string]$Version) {
    Remove-Junction $script:ExpectedStableRoot
    $versionRoot = Join-Path $script:AppRoot $Version
    foreach ($name in @('configs','vms','nx_device')) {
        Remove-Junction (Join-Path $versionRoot $name)
    }
}
function Invoke-ScoopLinkCurrent([string]$Version) {
    $versionRoot = Join-Path $script:AppRoot $Version
    Remove-Junction $script:ExpectedStableRoot
    New-Item -ItemType Junction -Path $script:ExpectedStableRoot -Value $versionRoot | Out-Null
    $link = Get-Item -LiteralPath $script:ExpectedStableRoot -Force
    Assert ($link.LinkType -eq 'Junction') 'Scoop current alias is not a junction.'
    Equal ([IO.Path]::GetFullPath([string]$link.Target)) ([IO.Path]::GetFullPath($versionRoot)) 'Scoop current alias points to the wrong version.'
}
function Invoke-ScoopPersistData([string]$Version) {
    $appDir = Join-Path $script:AppRoot $Version
    foreach ($name in @('configs','vms','nx_device')) {
        $source = Join-Path $appDir $name
        $target = Join-Path $script:PersistRoot $name
        $sourceExists = Test-Path -LiteralPath $source -PathType Container
        $targetExists = Test-Path -LiteralPath $target -PathType Container
        if ($sourceExists -and -not $targetExists) {
            Move-Item -LiteralPath $source -Destination $target -ErrorAction Stop
        } elseif ($sourceExists -and $targetExists) {
            $original = "$source.original"
            if (Test-Path -LiteralPath $original) {
                throw "Scoop persist simulation found an existing .original path: $original"
            }
            Move-Item -LiteralPath $source -Destination $original -ErrorAction Stop
        }
        if (-not (Test-Path -LiteralPath $target -PathType Container)) {
            New-Item -ItemType Directory -Path $target -Force | Out-Null
        }
        if (-not (Test-Path -LiteralPath $source)) {
            New-Item -ItemType Junction -Path $source -Value $target | Out-Null
        }
    }
    Invoke-ScoopLinkCurrent $Version
}

$tokens=$null
$parseErrors=$null
[System.Management.Automation.Language.Parser]::ParseInput($hookText,[ref]$tokens,[ref]$parseErrors) | Out-Null
Assert ($parseErrors.Count -eq 0) 'pre_install PowerShell syntax error.'
[System.Management.Automation.Language.Parser]::ParseInput($postUninstallText,[ref]$tokens,[ref]$parseErrors) | Out-Null
Assert ($parseErrors.Count -eq 0) 'post_uninstall PowerShell syntax error.'
Assert (@($manifest.persist) -contains 'configs' -and @($manifest.persist) -contains 'vms' -and @($manifest.persist) -contains 'nx_device') 'Manifest must persist configs, vms and nx_device.'
Equal $manifest.shortcuts[0][0] 'MuMuPlayer.cmd' 'Shortcut must use the version-local launcher.'
foreach ($marker in @(
    'Join-Path $scoopAppRoot',
    'Find-MuMuPreviousVersionInstallRoot',
    'New-MuMuCurrentVersionJunction',
    'Move-MuMuInstallRootToStable',
    'Move-MuMuPersistDataIntoVersion',
    'Restore-MuMuPersistDataToStore',
    'Restore-MuMuCurrentVersionJunction',
    '($stableRoot)'
)) {
    Assert ($hookText.Contains($marker)) "Missing versioned-root handling: $marker"
}
Assert ($hookText -match '\$stableRoot\s*=\s*Join-Path\s+\$scoopAppRoot') 'The program payload must use Scoop current, not persist\install.'

$root = Join-Path $env:RUNNER_TEMP ('mumu-versioned-' + [guid]::NewGuid().ToString('N'))
$scoopRoot = Join-Path $root 'Scoop Root'
$appRoot = Join-Path $scoopRoot 'apps\mumuplayer'
$persistRoot = Join-Path $root 'Global Persist\mumuplayer'
$appDataRoot = Join-Path $root 'Roaming'
$programDataRoot = Join-Path $root 'ProgramData'
$tempRoot = Join-Path $root 'Temp'
$registryRoot = 'HKCU:\Software\KiroBucketMuMuTests\' + [guid]::NewGuid().ToString('N')
$registryPath = Join-Path $registryRoot 'MuMuPlayerGlobal'
$legacyRoot = Join-Path $persistRoot 'install'
$previousVersion = '1.8.5.5748'
$firstVersion = '1.8.16.6114'
$secondVersion = '1.8.17.6200'
$thirdVersion = '1.8.18.6300'
$previousRoot = Join-Path $appRoot $previousVersion
$firstDir = Join-Path $appRoot $firstVersion
$secondDir = Join-Path $appRoot $secondVersion
$thirdDir = Join-Path $appRoot $thirdVersion
$persistConfig = Join-Path $persistRoot 'configs\main\install_config.json'
$appDataConfig = Join-Path $appDataRoot 'Netease\MuMuPlayerGlobal\install_config.json'
$vmData = Join-Path $persistRoot 'vms\test-vm\userdata.img'
$vmConfig = Join-Path $persistRoot 'vms\test-vm\vm_config.json'
$deviceMarker = Join-Path $persistRoot 'nx_device\device-marker.txt'

$env:APPDATA = $appDataRoot
$env:ProgramData = $programDataRoot
$env:TEMP = $tempRoot
$env:MUMU_SCOOP_TEST_MODE = '1'
$env:MUMU_SCOOP_TEST_REGISTRY_PATH = $registryPath

$script:AppRoot = $appRoot
$script:PersistRoot = $persistRoot
$script:ExpectedStableRoot = Join-Path $appRoot 'current'
$script:MockMuMuServicePath = $null
$script:MockProductVersion = $null
$script:MockPreparedProductVersion = $null
$script:FailPrepare = $false
$script:RetryPrepare = $false
$script:PrepareRetried = $false
$script:RetryCommit = $false
$script:CommitRetried = $false
$script:Targets = New-Object System.Collections.Generic.List[string]
$script:PhysicalTargets = New-Object System.Collections.Generic.List[string]

function is_admin { return $true }
function Get-Process { param($Name,$ErrorAction) return @() }
function Start-Sleep { param([int]$Seconds,[int]$Milliseconds) }
function cache_path {
    param($App,$Version,$Url)
    return (Join-Path $env:TEMP ('mumu-cache-' + $Version + '-' + [guid]::NewGuid().ToString('N') + '.exe'))
}
function Start-Process {
    param([string]$FilePath,[string[]]$ArgumentList,[switch]$Wait,[switch]$PassThru,[string]$WindowStyle)
    $actionArg = $ArgumentList | Where-Object { $_ -like '/action=*' } | Select-Object -First 1
    $dirArg = $ArgumentList | Where-Object { $_ -like '/D=*' } | Select-Object -First 1
    Assert ($actionArg -and $dirArg) 'Missing MuMu installer action or /D argument.'
    Equal $ArgumentList[-1] $dirArg '/D must be the final installer argument.'
    Assert (-not $dirArg.Contains('"')) '/D must be unquoted.'
    $action = $actionArg.Substring(8)
    $target = $dirArg.Substring(3)
    Equal ([IO.Path]::GetFullPath($target)) ([IO.Path]::GetFullPath($script:ExpectedStableRoot)) 'Installer must use Scoop current alias.'
    $targetItem = Get-Item -LiteralPath $target -Force
    Assert ($targetItem.LinkType -eq 'Junction') 'Installer target is not the current version junction.'
    $physicalTarget = [string]@($targetItem.Target)[0]
    $script:Targets.Add($target) | Out-Null
    $script:PhysicalTargets.Add($physicalTarget) | Out-Null
    Assert (Test-Path -LiteralPath $FilePath -PathType Leaf) 'Staged installer is missing.'
    $prefix = [IO.Path]::GetFullPath($physicalTarget).TrimEnd('\') + '\'
    Assert (-not ([IO.Path]::GetFullPath($FilePath).StartsWith($prefix,[StringComparison]::OrdinalIgnoreCase))) 'Installer is inside the program target.'

    $reg = Get-ItemProperty -LiteralPath $env:MUMU_SCOOP_TEST_REGISTRY_PATH
    Equal $reg.InstallLocation $target 'Registry InstallLocation was not migrated to current before install_prepare.'
    Assert ([string]$reg.UninstallString -like "*$target\uninstall.exe*") 'UninstallString was not migrated to current.'
    $activePersistConfig = Join-Path $target 'configs\main\install_config.json'
    Assert (Test-Path -LiteralPath $activePersistConfig -PathType Leaf) 'Persisted config was not available through current during setup.'
    $cfg0 = Get-Content -LiteralPath $activePersistConfig -Raw | ConvertFrom-Json
    Equal $cfg0.product.install_dir $target 'product.install_dir was not migrated before setup.'
    Equal $cfg0.main.install_dir (Join-Path $target 'nx_main') 'main.install_dir was not migrated before setup.'

    if (Test-Path -LiteralPath $appDataConfig) {
        $app = Get-Content $appDataConfig -Raw | ConvertFrom-Json
        if ($app.product.install_dir) { Equal $app.product.install_dir $target 'AppData product.install_dir not migrated.' }
        if ($app.main.install_dir) { Equal $app.main.install_dir (Join-Path $target 'nx_main') 'AppData main.install_dir not migrated.' }
    }

    if ($action -eq 'install_prepare' -and $script:FailPrepare) {
        return [pscustomobject]@{ExitCode=80011}
    }
    if ($action -eq 'install_prepare' -and $script:RetryPrepare -and -not $script:PrepareRetried) {
        $script:PrepareRetried=$true
        return [pscustomobject]@{ExitCode=80002}
    }
    if ($action -eq 'commit' -and $script:RetryCommit -and -not $script:CommitRetried) {
        $script:CommitRetried=$true
        return [pscustomobject]@{ExitCode=80002}
    }
    if ($action -eq 'install_prepare') {
        New-Item -ItemType Directory -Path (Join-Path $target 'configs\main'),(Join-Path $target 'vms\test-vm'),(Join-Path $target 'nx_device\15.0\shell') -Force | Out-Null
        $cfg = [pscustomobject]@{
            product=[pscustomobject]@{version=$script:MockPreparedProductVersion;install_dir=$target}
            main=[pscustomobject]@{install_dir=(Join-Path $target 'nx_main')}
            engines=[pscustomobject]@{mumu15=[pscustomobject]@{
                player=[pscustomobject]@{install_dir=(Join-Path $target 'nx_device\15.0\shell')}
                vms=[pscustomobject]@{install_dir=(Join-Path $target 'vms')}
                renderer=[pscustomobject]@{install_dir=(Join-Path $target 'nx_device\15.0\device')}
            }}
        }
        $cfg | ConvertTo-Json -Depth 12 | Set-Content -LiteralPath $activePersistConfig -Encoding utf8
        Set-Content (Join-Path $target 'nx_device\15.0\shell\MuMuNxDevice.exe') ('engine=' + $script:MockProductVersion)
        if (Test-Path -LiteralPath $appDataConfig) {
            $app = Get-Content $appDataConfig -Raw | ConvertFrom-Json
            $app.product.version=$script:MockPreparedProductVersion
            $app.product.install_dir=$target
            $app.main.install_dir=Join-Path $target 'nx_main'
            $app | ConvertTo-Json -Depth 12 | Set-Content $appDataConfig -Encoding utf8
        }
        return [pscustomobject]@{ExitCode=0}
    }
    if ($action -eq 'commit') {
        New-Item -ItemType Directory -Path (Join-Path $target 'nx_main') -Force | Out-Null
        Set-Content (Join-Path $target 'nx_main\MuMuNxMain.exe') ('main=' + $script:MockProductVersion)
        Set-Content (Join-Path $target 'nx_main\MuMuPlayerRemoteService.exe') 'service'
        if (-not (Test-Path -LiteralPath (Join-Path $target 'uninstall.exe'))) {
            Set-Content (Join-Path $target 'uninstall.exe') 'uninstaller'
        }
        return [pscustomobject]@{ExitCode=0}
    }
    throw "Unknown mocked MuMu action: $action"
}
function Invoke-MuMuHook {
    param(
        [string]$Version,
        [string]$ProductVersion,
        [switch]$Fail,
        [switch]$Retry80002
    )
    $script:dir = Join-Path $script:AppRoot $Version
    $script:fname = "MuMu-$Version.exe"
    $script:version = $Version
    $script:app = 'mumuplayer'
    $script:persist_dir = $script:PersistRoot
    $script:ExpectedStableRoot = Join-Path $script:AppRoot 'current'
    $script:MockProductVersion = $ProductVersion
    $script:MockPreparedProductVersion = if ($Retry80002) { '6.8.15.9' } else { $ProductVersion }
    $script:FailPrepare = [bool]$Fail
    $script:RetryPrepare = [bool]$Retry80002
    $script:PrepareRetried = $false
    $script:RetryCommit = [bool]$Retry80002
    $script:CommitRetried = $false
    New-Item -ItemType Directory -Path $script:dir -Force | Out-Null
    Set-Content (Join-Path $script:dir $script:fname) 'mock-installer'
    . ([scriptblock]::Create($hookText))
    if ($Retry80002 -and (-not $script:PrepareRetried -or -not $script:CommitRetried)) {
        throw 'The 80002 prepare/commit retry branches were not both exercised.'
    }
}
function Invoke-UpgradeAttempt {
    param([string]$Version,[string]$ProductVersion,[switch]$Fail,[switch]$Retry80002)
    $versionRoot = Join-Path $script:AppRoot $Version
    Remove-Junction $script:ExpectedStableRoot
    if (Test-Path -LiteralPath $versionRoot) {
        Remove-Item -LiteralPath $versionRoot -Recurse -Force
    }
    Invoke-MuMuHook -Version $Version -ProductVersion $ProductVersion -Fail:$Fail -Retry80002:$Retry80002
}
function New-MuMuConfig([string]$InstallRoot,[string]$ProductVersion) {
    return [pscustomobject]@{
        product=[pscustomobject]@{version=$ProductVersion;install_dir=$InstallRoot}
        main=[pscustomobject]@{install_dir=(Join-Path $InstallRoot 'nx_main')}
        engines=[pscustomobject]@{mumu15=[pscustomobject]@{
            player=[pscustomobject]@{install_dir=(Join-Path $InstallRoot 'nx_device\15.0\shell')}
            vms=[pscustomobject]@{install_dir=(Join-Path $InstallRoot 'vms')}
            renderer=[pscustomobject]@{install_dir=(Join-Path $InstallRoot 'nx_device\15.0\device')}
        }}
        custom='keep'
    }
}

try {
    New-Item -ItemType Directory -Path $scoopRoot,$appRoot,$persistRoot,$appDataRoot,$programDataRoot,$tempRoot -Force | Out-Null
    New-Item -ItemType Directory -Path (Join-Path $legacyRoot 'nx_main'),(Join-Path $legacyRoot 'plugins'),(Join-Path $persistRoot 'configs\main'),(Join-Path $persistRoot 'vms\test-vm'),(Join-Path $persistRoot 'nx_device\15.0\shell'),(Split-Path $appDataConfig -Parent),$previousRoot -Force | Out-Null

    Set-Content (Join-Path $legacyRoot 'uninstall.exe') 'original-uninstaller'
    Set-Content (Join-Path $legacyRoot 'nx_main\MuMuNxMain.exe') 'original-main'
    Set-Content (Join-Path $legacyRoot 'nx_main\MuMuPlayerRemoteService.exe') 'original-service'
    Set-Content (Join-Path $legacyRoot 'plugins\marker.dll') 'plugin-payload'
    Set-Content (Join-Path $previousRoot 'MuMuPlayer.cmd') '@echo off'
    foreach ($name in @('configs','vms','nx_device')) {
        New-Item -ItemType Junction -Path (Join-Path $legacyRoot $name) -Value (Join-Path $persistRoot $name) | Out-Null
    }

    (New-MuMuConfig $legacyRoot '6.8.5.0') | ConvertTo-Json -Depth 12 | Set-Content -LiteralPath $persistConfig -Encoding utf8
    (New-MuMuConfig $legacyRoot '6.8.5.0') | ConvertTo-Json -Depth 12 | Set-Content -LiteralPath $appDataConfig -Encoding utf8
    Set-Content $vmData 'vm-data-preserve'
    Set-Content $vmConfig ('vm_path=' + $legacyRoot)
    Set-Content $deviceMarker 'device-data-preserve'

    New-Item -ItemType Directory -Path $registryRoot -Force | Out-Null
    New-Item -Path $registryPath -Force | Out-Null
    Set-ItemProperty $registryPath UninstallString ('"' + (Join-Path $legacyRoot 'uninstall.exe') + '"')
    Set-ItemProperty $registryPath InstallLocation $legacyRoot
    Set-ItemProperty $registryPath DisplayIcon (Join-Path $legacyRoot 'nx_main\MuMuNxMain.exe')
    Set-ItemProperty $registryPath DisplayVersion '6.8.5.0'
    $script:MockMuMuServicePath = '"' + (Join-Path $legacyRoot 'nx_main\MuMuPlayerRemoteService.exe') + '" --service'

    $failed=$false
    try { Invoke-UpgradeAttempt -Version $firstVersion -ProductVersion '6.8.16.0' -Fail }
    catch {
        $failed=$true
        if ($_.Exception.Message -notmatch '80011') { throw }
    }
    Assert $failed 'The injected 80011 was not surfaced.'
    $reg=Get-ItemProperty -LiteralPath $registryPath
    Equal $reg.InstallLocation $legacyRoot 'Registry rollback failed.'
    Assert ([string]$reg.UninstallString -like "*$legacyRoot\uninstall.exe*") 'UninstallString rollback failed.'
    Assert ([string]$reg.DisplayIcon -like "*$legacyRoot*") 'DisplayIcon rollback failed.'
    Equal ((Get-Content $persistConfig -Raw | ConvertFrom-Json).product.install_dir) $legacyRoot 'Persist config rollback failed.'
    Equal ((Get-Content $appDataConfig -Raw | ConvertFrom-Json).product.install_dir) $legacyRoot 'AppData config rollback failed.'
    Assert ($script:MockMuMuServicePath -like "*$legacyRoot*") 'Service path changed after failed migration.'
    Equal (Get-Content $vmData -Raw).Trim() 'vm-data-preserve' 'VM data changed after failed migration.'
    Equal (Get-Content $deviceMarker -Raw).Trim() 'device-data-preserve' 'Device data changed after failed migration.'
    Assert (Test-Path (Join-Path $legacyRoot 'nx_main\MuMuNxMain.exe')) 'Rollback did not restore the legacy main executable.'
    Assert (Test-Path (Join-Path $legacyRoot 'uninstall.exe')) 'Rollback did not restore the legacy uninstaller.'
    Equal (Get-Content (Join-Path $legacyRoot 'plugins\marker.dll') -Raw).Trim() 'plugin-payload' 'Rollback did not restore nested program files.'
    $currentAfterRollback=Get-Item -LiteralPath $script:ExpectedStableRoot -Force
    Equal ([IO.Path]::GetFullPath([string]@($currentAfterRollback.Target)[0])) ([IO.Path]::GetFullPath($previousRoot)) 'Current junction was not restored to the previous installed version.'

    Invoke-UpgradeAttempt -Version $firstVersion -ProductVersion '6.8.16.0'
    Assert (Test-Path (Join-Path $firstDir 'nx_main\MuMuNxMain.exe')) 'First version payload is not inside its Scoop version directory.'
    Assert (Test-Path (Join-Path $firstDir 'uninstall.exe')) 'First version uninstaller is not inside its Scoop version directory.'
    Assert (-not (Test-Path (Join-Path $legacyRoot 'nx_main\MuMuNxMain.exe'))) 'Legacy persist root still contains the program main executable.'
    Assert (-not (Test-Path (Join-Path $legacyRoot 'uninstall.exe'))) 'Legacy persist root still contains the uninstaller.'
    Assert (Test-Path (Join-Path $firstDir 'MuMuPlayer.cmd')) 'Version-local launcher was not created.'
    Invoke-ScoopPersistData $firstVersion
    $reg=Get-ItemProperty -LiteralPath $registryPath
    Equal $reg.InstallLocation $script:ExpectedStableRoot 'Registry InstallLocation is not the stable current alias.'
    Assert ([string]$reg.UninstallString -like "*$script:ExpectedStableRoot\uninstall.exe*") 'UninstallString is not based on current alias.'
    Equal ((Get-Content $persistConfig -Raw | ConvertFrom-Json).product.install_dir) $script:ExpectedStableRoot 'Persisted product.install_dir is not current.'
    Equal ((Get-Content $persistConfig -Raw | ConvertFrom-Json).product.version) '6.8.16.0' 'Product version missing after first migration.'
    Equal $script:MockMuMuServicePath ('"' + (Join-Path $script:ExpectedStableRoot 'nx_main\MuMuPlayerRemoteService.exe') + '" --service') 'Service image path is not current.'
    Equal (Get-Content $vmData -Raw).Trim() 'vm-data-preserve' 'VM data was not preserved.'
    Equal (Get-Content $deviceMarker -Raw).Trim() 'device-data-preserve' 'Device data was not preserved.'
    $persistedConfig=Get-Content (Join-Path $persistRoot 'configs\main\install_config.json') -Raw | ConvertFrom-Json
    Equal $persistedConfig.custom 'keep' 'Custom persistent config was lost.'

    Remove-ScoopCurrentAndPersistLinks $firstVersion
    Invoke-UpgradeAttempt -Version $secondVersion -ProductVersion '6.8.17.0'
    Assert (Test-Path (Join-Path $secondDir 'nx_main\MuMuNxMain.exe')) 'Second update did not place binaries in its version directory.'
    Assert (-not (Test-Path (Join-Path $firstDir 'nx_main\MuMuNxMain.exe'))) 'Second update left the old program binaries behind.'
    Assert (Test-Path (Join-Path $secondDir 'uninstall.exe')) 'Second update uninstaller is missing.'
    Invoke-ScoopPersistData $secondVersion
    Equal (Get-ItemProperty -LiteralPath $registryPath).InstallLocation $script:ExpectedStableRoot 'Second update changed the stable Registry path.'
    Equal ((Get-Content $persistConfig -Raw | ConvertFrom-Json).product.version) '6.8.17.0' 'Second update did not store the new product version.'
    Equal ((Get-Content $persistConfig -Raw | ConvertFrom-Json).product.install_dir) $script:ExpectedStableRoot 'Second update changed persistent install_dir.'
    Assert (@($script:PhysicalTargets | Select-Object -Unique).Count -ge 2) 'Installer phases did not execute against more than one version directory.'

    Remove-ScoopCurrentAndPersistLinks $secondVersion
    Invoke-UpgradeAttempt -Version $thirdVersion -ProductVersion '6.8.18.0' -Retry80002
    Invoke-ScoopPersistData $thirdVersion
    Equal (Get-ItemProperty -LiteralPath $registryPath).InstallLocation $script:ExpectedStableRoot '80002 retry changed the stable install path.'
    Assert (Test-Path (Join-Path $thirdDir 'nx_main\MuMuNxMain.exe')) 'Third version payload is missing.'
    Equal ((Get-Content $persistConfig -Raw | ConvertFrom-Json).product.version) '6.8.15.9' 'The commit retry result was not preserved.'

    Remove-ScoopCurrentAndPersistLinks $thirdVersion
    $script:dir = $thirdDir
    $script:persist_dir = $persistRoot
    $cmd = 'update'
    . ([scriptblock]::Create($postUninstallText))
    Assert (Test-Path $registryPath) 'post_uninstall removed Registry during scoop update.'
    Assert ($script:MockMuMuServicePath -like "*$script:ExpectedStableRoot*") 'post_uninstall removed service during scoop update.'
    Assert (Test-Path $persistConfig) 'post_uninstall removed persistent config during scoop update.'

    $cmd = 'uninstall'
    . ([scriptblock]::Create($postUninstallText))
    Assert (-not (Test-Path $registryPath)) 'Full Scoop uninstall did not remove current-root registration.'
    Assert ([string]::IsNullOrWhiteSpace($script:MockMuMuServicePath)) 'Full Scoop uninstall did not remove current-root service.'
    Assert (Test-Path $vmData) 'Scoop uninstall removed persisted VM data.'
    Assert (Test-Path $deviceMarker) 'Scoop uninstall removed persisted device data.'
    Assert (Test-Path $persistConfig) 'Scoop uninstall removed persisted configuration.'
    Assert (-not (Test-Path $legacyRoot)) 'The empty legacy install root and its old persist junctions were not cleaned.'
    Assert (Test-Path (Join-Path $thirdDir 'nx_main\MuMuNxMain.exe')) 'post_uninstall incorrectly deleted versioned program files instead of leaving them to Scoop.'

    @(
        '## MuMuPlayer versioned-payload regression'
        ''
        '- Injected 80011 during migration from persist\install and verified reverse-move rollback.'
        '- Verified successful migration places MuMu binaries and uninstall.exe inside the Scoop version directory.'
        '- Simulated Scoop persist_data moving configs, vms and nx_device back to persist and creating version-local junctions.'
        '- Simulated a subsequent update after unlink_current and verified old binaries move to the next version directory.'
        '- Exercised the 80002 prepare and commit retry branches.'
        '- Verified current alias paths, Registry, AppData, service path and persisted VM/config/device data.'
        '- Verified post_uninstall keeps persistent user data and leaves versioned files for Scoop to remove.'
        ''
        'Mock installer only; it does not boot Android or validate host virtualization drivers.'
    ) | Out-File $env:GITHUB_STEP_SUMMARY -Encoding utf8
    Write-Host 'MuMuPlayer versioned-payload regression passed.'
} finally {
    if (Test-Path $root) { Remove-Item $root -Recurse -Force -ErrorAction SilentlyContinue }
    Remove-Item Env:\MUMU_SCOOP_TEST_MODE -ErrorAction SilentlyContinue
    Remove-Item Env:\MUMU_SCOOP_TEST_REGISTRY_PATH -ErrorAction SilentlyContinue
}

$global:LASTEXITCODE = 0
