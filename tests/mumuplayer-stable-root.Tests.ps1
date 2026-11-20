$ErrorActionPreference = 'Stop'
$repoRoot = Split-Path $PSScriptRoot -Parent
$manifest = Get-Content (Join-Path $repoRoot 'bucket\mumuplayer.json') -Raw | ConvertFrom-Json
$hookText = @($manifest.pre_install) -join [Environment]::NewLine
function Assert([bool]$ok,[string]$message) { if (-not $ok) { throw $message } }
function Equal($actual,$expected,[string]$message) { if ([string]$actual -ine [string]$expected) { throw "$message Actual='$actual'; Expected='$expected'" } }

$tokens=$null; $parseErrors=$null
[System.Management.Automation.Language.Parser]::ParseInput($hookText,[ref]$tokens,[ref]$parseErrors) | Out-Null
Assert ($parseErrors.Count -eq 0) 'pre_install syntax error.'
Assert (@($manifest.persist) -contains 'configs' -and @($manifest.persist) -contains 'vms' -and @($manifest.persist) -contains 'nx_device') 'Manifest must persist configs, vms, nx_device.'
Equal $manifest.shortcuts[0][0] 'MuMuPlayer.cmd' 'Shortcut must use version-local launcher.'
foreach ($marker in @('$stableRoot','Get-MuMuRegisteredInstallRoot','Copy-MuMuInstallRootToStable','Update-MuMuUninstallRegistration','Restore-MuMuRegistrySnapshot','Set-MuMuServicePath','('/D=' + $stableRoot)')) {
    Assert ($hookText.Contains($marker)) "Missing stable-root handling: $marker"
}

$root = Join-Path $env:RUNNER_TEMP ('mumu-stable-' + [guid]::NewGuid().ToString('N'))
$scoopRoot = Join-Path $root 'Scoop Root'
$persistRoot = Join-Path $root 'Global Persist\mumuplayer'
$appDataRoot = Join-Path $root 'Roaming'
$registryRoot = 'HKCU:\Software\KiroBucketMuMuTests\' + [guid]::NewGuid().ToString('N')
$registryPath = Join-Path $registryRoot 'MuMuPlayerGlobal'
$oldRoot = Join-Path $scoopRoot 'apps\mumuplayer\1.8.5.5748'
$newDir = Join-Path $scoopRoot 'apps\mumuplayer\1.8.16.6114'
$stableRoot = Join-Path $persistRoot 'install'
$persistConfig = Join-Path $persistRoot 'configs\main\install_config.json'
$appDataConfig = Join-Path $appDataRoot 'Netease\MuMuPlayerGlobal\install_config.json'
$vmData = Join-Path $persistRoot 'vms\test-vm\userdata.img'
$vmConfig = Join-Path $persistRoot 'vms\test-vm\vm_config.json'
$deviceMarker = Join-Path $persistRoot 'nx_device\device-marker.txt'
$env:APPDATA = $appDataRoot
$env:MUMU_SCOOP_TEST_MODE = '1'
$env:MUMU_SCOOP_TEST_REGISTRY_PATH = $registryPath
$script:ExpectedStableRoot = $stableRoot
$script:MockMuMuServicePath = $null
$script:MockProductVersion = $null
$script:FailPrepare = $false
$script:RetryPrepare = $false
$script:PrepareRetried = $false
$script:RetryCommit = $false
$script:CommitRetried = $false
$script:Targets = New-Object System.Collections.Generic.List[string]

function is_admin { return $true }
function Get-Process { param($Name,$ErrorAction) return @() }
function Start-Sleep { param([int]$Seconds,[int]$Milliseconds) }
function cache_path { param($App,$Version,$Url) return (Join-Path $env:TEMP ('mumu-cache-' + $Version + '.exe')) }
function Start-Process {
    param([string]$FilePath,[string[]]$ArgumentList,[switch]$Wait,[switch]$PassThru,[string]$WindowStyle)
    $actionArg = $ArgumentList | Where-Object { $_ -like '/action=*' } | Select-Object -First 1
    $dirArg = $ArgumentList | Where-Object { $_ -like '/D=*' } | Select-Object -First 1
    Assert ($actionArg -and $dirArg) 'Missing action or /D argument.'
    Equal $ArgumentList[-1] $dirArg '/D must be the final argument.'
    Assert (-not $dirArg.Contains('"')) '/D must be unquoted.'
    $action = $actionArg.Substring(8); $target = $dirArg.Substring(3)
    Equal ([IO.Path]::GetFullPath($target)) ([IO.Path]::GetFullPath($script:ExpectedStableRoot)) 'Installer must use stable persist root.'
    $script:Targets.Add($target) | Out-Null
    Assert (Test-Path $FilePath -PathType Leaf) 'Staged installer is missing.'
    $prefix = [IO.Path]::GetFullPath($target).TrimEnd('\') + '\'
    Assert (-not ([IO.Path]::GetFullPath($FilePath).StartsWith($prefix,[StringComparison]::OrdinalIgnoreCase))) 'Installer is inside install target.'
    $reg = Get-ItemProperty $env:MUMU_SCOOP_TEST_REGISTRY_PATH
    Equal $reg.InstallLocation $target 'Registry InstallLocation not migrated before install_prepare.'
    Assert ([string]$reg.UninstallString -like "*$target\uninstall.exe*") 'UninstallString not migrated before install_prepare.'
    foreach ($p in @($persistConfig,$appDataConfig)) {
        if (Test-Path $p) {
            $cfg0 = Get-Content $p -Raw | ConvertFrom-Json
            if ($cfg0.product.install_dir) { Equal $cfg0.product.install_dir $target "product.install_dir not migrated in $p" }
            if ($cfg0.main.install_dir) { Equal $cfg0.main.install_dir (Join-Path $target 'nx_main') "main.install_dir not migrated in $p" }
        }
    }
    if ($action -eq 'install_prepare' -and $script:FailPrepare) { return [pscustomobject]@{ExitCode=80011} }
    if ($action -eq 'install_prepare' -and $script:RetryPrepare -and -not $script:PrepareRetried) {
        $script:PrepareRetried=$true; return [pscustomobject]@{ExitCode=80002}
    }
    if ($action -eq 'commit' -and $script:RetryCommit -and -not $script:CommitRetried) {
        $script:CommitRetried=$true; return [pscustomobject]@{ExitCode=80002}
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
        $cfg | ConvertTo-Json -Depth 12 | Set-Content $persistConfig -Encoding utf8
        Set-Content (Join-Path $target 'nx_device\15.0\shell\MuMuNxDevice.exe') ('engine=' + $script:MockProductVersion)
        if (Test-Path $appDataConfig) {
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
        if (-not (Test-Path (Join-Path $target 'uninstall.exe'))) { Set-Content (Join-Path $target 'uninstall.exe') 'uninstaller' }
        return [pscustomobject]@{ExitCode=0}
    }
    throw "Unknown action: $action"
}
function Invoke-MuMuHook {
    param([string]$Version,[string]$ProductVersion,[switch]$Fail,[switch]$Retry80002)
    $script:dir=Join-Path $scoopRoot "apps\mumuplayer\$Version"
    $script:fname="MuMu-$Version.exe"; $script:version=$Version; $script:app='mumuplayer'; $script:persist_dir=$persistRoot
    $script:ExpectedStableRoot=Join-Path $persistRoot 'install'
    $script:MockProductVersion=$ProductVersion
    $script:MockPreparedProductVersion=if ($Retry80002) { '6.8.15.9' } else { $ProductVersion }
    $script:FailPrepare=[bool]$Fail
    $script:RetryPrepare=[bool]$Retry80002; $script:PrepareRetried=$false
    $script:RetryCommit=[bool]$Retry80002; $script:CommitRetried=$false
    New-Item -ItemType Directory -Path $script:dir -Force | Out-Null
    Set-Content (Join-Path $script:dir $script:fname) 'mock-installer'
    . ([scriptblock]::Create($hookText))
    if ($Retry80002 -and (-not $script:PrepareRetried -or -not $script:CommitRetried)) { throw '80002 retry branch was not exercised.' }
}
function Invoke-ScoopPersistData([string]$Version) {
    $appDir=Join-Path $scoopRoot "apps\mumuplayer\$Version"
    foreach($name in @('configs','vms','nx_device')) {
        $src=Join-Path $appDir $name; $dst=Join-Path $persistRoot $name
        Assert (-not (Test-Path $src)) "Hook left Scoop persist source: $src"
        New-Item -ItemType Junction -Path $src -Value $dst | Out-Null
    }
}

try {
    New-Item -ItemType Directory -Path $scoopRoot,$persistRoot,$appDataRoot -Force | Out-Null
    foreach($n in @('configs','vms','nx_device')) { New-Item -ItemType Directory -Path (Join-Path $persistRoot $n) -Force | Out-Null }
    New-Item -ItemType Directory -Path (Join-Path $oldRoot 'nx_main'),(Join-Path $persistRoot 'configs\main'),(Join-Path $persistRoot 'vms\test-vm'),(Join-Path $persistRoot 'nx_device\15.0\shell'),(Split-Path $appDataConfig -Parent) -Force | Out-Null
    Set-Content (Join-Path $oldRoot 'uninstall.exe') 'original-uninstaller'
    Set-Content (Join-Path $oldRoot 'nx_main\MuMuNxMain.exe') 'original-main'
    Set-Content (Join-Path $oldRoot 'nx_main\MuMuPlayerRemoteService.exe') 'original-service'
    foreach($n in @('configs','vms','nx_device')) { New-Item -ItemType Junction -Path (Join-Path $oldRoot $n) -Value (Join-Path $persistRoot $n) | Out-Null }

    $cfg=[pscustomobject]@{product=[pscustomobject]@{version='6.8.5.0';install_dir=$newDir};main=[pscustomobject]@{install_dir=(Join-Path $newDir 'nx_main')}}
    $cfg | ConvertTo-Json | Set-Content $persistConfig -Encoding utf8
    $app=[pscustomobject]@{custom='keep';product=[pscustomobject]@{version='6.8.5.0';install_dir=$oldRoot};main=[pscustomobject]@{install_dir=(Join-Path $oldRoot 'nx_main')}}
    $app | ConvertTo-Json | Set-Content $appDataConfig -Encoding utf8
    ([pscustomobject]@{custom='keep-user';old_path=$newDir} | ConvertTo-Json -Compress) | Set-Content (Join-Path $persistRoot 'configs\user-settings.json') -Encoding utf8
    Set-Content $vmData 'vm-data-preserve'
    Set-Content $vmConfig ('vm_path=' + $oldRoot)
    Set-Content $deviceMarker 'device-data-preserve'

    New-Item -ItemType Directory -Path $registryRoot -Force | Out-Null
    New-Item -Path $registryPath -Force | Out-Null
    Set-ItemProperty $registryPath UninstallString ('"' + (Join-Path $oldRoot 'uninstall.exe') + '"')
    Set-ItemProperty $registryPath InstallLocation $oldRoot
    Set-ItemProperty $registryPath DisplayIcon (Join-Path $oldRoot 'nx_main\MuMuNxMain.exe')
    Set-ItemProperty $registryPath DisplayVersion '6.8.5.0'
    $script:MockMuMuServicePath='"' + (Join-Path $oldRoot 'nx_main\MuMuPlayerRemoteService.exe') + '" --service'

    $failed=$false
    try { Invoke-MuMuHook -Version '1.8.16.6114' -ProductVersion '6.8.16.0' -Fail }
    catch { $failed=$true; if ($_.Exception.Message -notmatch '80011') { throw } }
    Assert $failed 'The injected 80011 was not surfaced.'
    $reg=Get-ItemProperty $registryPath
    Equal $reg.InstallLocation $oldRoot 'InstallLocation rollback failed.'
    Assert ([string]$reg.UninstallString -like "*$oldRoot\uninstall.exe*") 'UninstallString rollback failed.'
    Assert ([string]$reg.DisplayIcon -like "*$oldRoot*") 'DisplayIcon rollback failed.'
    Equal ((Get-Content $persistConfig -Raw | ConvertFrom-Json).product.install_dir) $newDir 'Persisted JSON rollback failed.'
    Equal ((Get-Content $appDataConfig -Raw | ConvertFrom-Json).product.install_dir) $oldRoot 'AppData JSON rollback failed.'
    Assert ($script:MockMuMuServicePath -like "*$oldRoot*") 'Service path changed on failed prepare.'
    Equal (Get-Content $vmData -Raw).Trim() 'vm-data-preserve' 'VM data changed on failed migration.'
    Equal (Get-Content $deviceMarker -Raw).Trim() 'device-data-preserve' 'Device data changed on failed migration.'
    Assert (Test-Path (Join-Path $stableRoot 'nx_main\MuMuNxMain.exe')) 'The old install was not copied to stable root.'

    Invoke-MuMuHook -Version '1.8.16.6114' -ProductVersion '6.8.16.0' -Retry80002
    Invoke-ScoopPersistData '1.8.16.6114'
    $reg=Get-ItemProperty $registryPath
    Equal $reg.InstallLocation $stableRoot 'Registry InstallLocation is not stable.'
    Assert ([string]$reg.UninstallString -like "*$stableRoot\uninstall.exe*") 'UninstallString is not stable.'
    Assert ([string]$reg.DisplayIcon -like "*$stableRoot*") 'DisplayIcon is not stable.'
    Equal $script:MockMuMuServicePath ('"' + (Join-Path $stableRoot 'nx_main\MuMuPlayerRemoteService.exe') + '" --service') 'Service path not updated.'
    $cfg=Get-Content $persistConfig -Raw | ConvertFrom-Json
    Equal $cfg.product.version '6.8.15.9' 'Product version missing after commit retry.'
    Equal $cfg.product.install_dir $stableRoot 'Persisted product install_dir is not stable.'
    Equal $cfg.main.install_dir (Join-Path $stableRoot 'nx_main') 'Persisted main install_dir is not stable.'
    $app=Get-Content $appDataConfig -Raw | ConvertFrom-Json
    Equal $app.product.install_dir $stableRoot 'AppData product install_dir is not stable.'
    Equal $app.main.install_dir (Join-Path $stableRoot 'nx_main') 'AppData main install_dir is not stable.'
    Equal $app.custom 'keep' 'Custom AppData settings were lost.'
    $user=Get-Content (Join-Path $persistRoot 'configs\user-settings.json') -Raw | ConvertFrom-Json
    Equal $user.custom 'keep-user' 'Custom persisted settings were lost.'
    Equal $user.old_path $stableRoot 'User config path not migrated.'
    Assert ((Get-Content $vmConfig -Raw) -like "*$stableRoot*") 'VM config path not migrated.'
    Assert ((Get-Content $vmConfig -Raw) -notlike '*1.8.5.5748*') 'Old root remains in VM config.'
    Equal (Get-Content $vmData -Raw).Trim() 'vm-data-preserve' 'VM data was not preserved.'
    Equal (Get-Content $deviceMarker -Raw).Trim() 'device-data-preserve' 'Device data was not preserved.'
    Equal (Get-Content (Join-Path $persistRoot 'nx_device\15.0\shell\MuMuNxDevice.exe') -Raw).Trim() 'engine=6.8.16.0' 'Persisted engine executable was not updated.'
    Assert (Test-Path (Join-Path $stableRoot 'nx_main\MuMuNxMain.exe')) 'Stable main executable missing.'
    Assert (Test-Path (Join-Path $oldRoot 'uninstall.exe')) 'Original versioned installation was deleted during migration.'
    Equal (Get-Content (Join-Path $oldRoot 'uninstall.exe') -Raw).Trim() 'original-uninstaller' 'Original versioned uninstaller was modified.'
    $launcher=Join-Path $scoopRoot 'apps\mumuplayer\1.8.16.6114\MuMuPlayer.cmd'
    Assert (Test-Path $launcher) 'Stable-root launcher missing.'
    Assert ((Get-Content $launcher -Raw) -like "*$stableRoot*") 'Launcher points somewhere other than stable root.'
    foreach($n in @('configs','vms','nx_device')) {
        Assert ([bool]((Get-Item (Join-Path $stableRoot $n) -Force).Attributes -band [IO.FileAttributes]::ReparsePoint)) "Stable root '$n' is not a junction."
    }

    Invoke-MuMuHook -Version '1.8.17.6200' -ProductVersion '6.8.17.0'
    Invoke-ScoopPersistData '1.8.17.6200'
    Equal (Get-ItemProperty $registryPath).InstallLocation $stableRoot 'Second update changed the install root.'
    $cfg=Get-Content $persistConfig -Raw | ConvertFrom-Json
    Equal $cfg.product.version '6.8.17.0' 'Second update did not update product version.'
    Equal $cfg.product.install_dir $stableRoot 'Second update reverted to a version-specific root.'
    Assert (@($script:Targets | ForEach-Object { [IO.Path]::GetFullPath($_) } | Select-Object -Unique).Count -eq 1) 'Multiple installer target roots were used.'

    @(
        '## MuMuPlayer stable install-root regression'
        ''
        '- Injected install_prepare error 80011 and verified Registry/config rollback.'
        '- Preserved the original versioned install while copying binaries into persist.'
        '- Updated uninstall registration, AppData and persisted config paths, and service path.'
        '- Preserved VM data, configs, and custom nx_device files.'
        '- Verified first migration and subsequent upgrades use the same /D target.'
        '- Exercised the 80002 prepare and commit retry branches.'
        ''
        'Mock installer only; it does not boot Android or validate physical host hypervisor drivers.'
    ) | Out-File $env:GITHUB_STEP_SUMMARY -Encoding utf8
    Write-Host 'MuMuPlayer stable-root regression passed.'
} finally {
    if (Test-Path $root) { Remove-Item $root -Recurse -Force -ErrorAction SilentlyContinue }
    if (Test-Path $registryRoot) { Remove-Item $registryRoot -Recurse -Force -ErrorAction SilentlyContinue }
    Remove-Item Env:\MUMU_SCOOP_TEST_MODE -ErrorAction SilentlyContinue
    Remove-Item Env:\MUMU_SCOOP_TEST_REGISTRY_PATH -ErrorAction SilentlyContinue
}
