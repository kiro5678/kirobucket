$ErrorActionPreference = 'Stop'

$repoRoot = Split-Path $PSScriptRoot -Parent
$manifestPath = Join-Path $repoRoot 'bucket\mumuplayer.json'
$manifest = Get-Content -LiteralPath $manifestPath -Raw | ConvertFrom-Json -ErrorAction Stop

function Assert([bool]$Condition, [string]$Message) {
    if (-not $Condition) { throw $Message }
}

function Assert-ScriptSyntax([string]$Text, [string]$Name) {
    $tokens = $null
    $errors = $null
    [System.Management.Automation.Language.Parser]::ParseInput($Text, [ref]$tokens, [ref]$errors) | Out-Null
    if ($errors.Count -gt 0) {
        $details = $errors | ForEach-Object { $_.Message }
        throw "$Name has PowerShell syntax errors: $($details -join '; ')"
    }
}

Assert (@($manifest.persist) -contains 'configs') 'Manifest must persist configs.'
Assert (@($manifest.persist) -contains 'vms') 'Manifest must persist vms.'
Assert (@($manifest.persist) -contains 'nx_device') 'Manifest must persist nx_device.'

$preText = @($manifest.pre_install) -join [Environment]::NewLine
$postText = @($manifest.post_install) -join [Environment]::NewLine
Assert-ScriptSyntax $preText 'pre_install'
Assert-ScriptSyntax $postText 'post_install'

$helperPattern = '(?s)\$mumuMigrationHelperContent\s*=\s*@''\r?\n(?<helper>.*?)\r?\n''@'
$helperMatch = [regex]::Match($preText, $helperPattern)
Assert $helperMatch.Success 'Could not extract the embedded migration helper from pre_install.'

$helperText = $helperMatch.Groups['helper'].Value
Assert-ScriptSyntax $helperText 'embedded migration helper'

foreach ($required in @(
    '-Phase Pre',
    '-Phase Post',
    '_mumu-scoop-path-backups',
    'nx_device\12.0\configs',
    'nx_device\15.0\configs',
    'MuMuVMMDrv',
    'MuMuNxSup',
    'LocalServer32'
)) {
    Assert ($preText.Contains($required) -or $postText.Contains($required) -or $helperText.Contains($required)) "Missing required migration or validation behavior: $required"
}

$testRoot = Join-Path $env:RUNNER_TEMP ('mumu-persist-path-' + [guid]::NewGuid().ToString('N'))
$scoopAppRoot = Join-Path $testRoot 'Scoop Root\apps\mumuplayer'
$oldRoot = Join-Path $scoopAppRoot '1.8.5.5748'
$newRoot = Join-Path $scoopAppRoot '1.8.17.6200'
$persistRoot = Join-Path $testRoot 'Persist\mumuplayer'
$appDataConfig = Join-Path $testRoot 'Roaming\Netease\MuMuPlayerGlobal\install_config.json'
$programFilesMock = Join-Path $testRoot 'Program Files'
$servicesRegistryRoot = 'HKCU:\Software\KiroBucketMuMuMigrationTests\Services\' + [guid]::NewGuid().ToString('N')
$classesRegistryRoot = 'HKCU:\Software\KiroBucketMuMuMigrationTests\Classes\CLSID'
$registryRoot = Split-Path $servicesRegistryRoot -Parent
$vmDataPath = Join-Path $persistRoot 'vms\MuMuPlayerGlobal-15.0-1\userdata.img'

try {
    $directories = @(
        (Join-Path $persistRoot 'configs\main'),
        (Join-Path $persistRoot 'nx_device\12.0\configs\device'),
        (Join-Path $persistRoot 'nx_device\15.0\configs\device'),
        (Join-Path $persistRoot 'nx_device\12.0\shell'),
        (Join-Path $persistRoot 'nx_device\15.0\shell'),
        (Join-Path $persistRoot 'nx_device\12.0\vms\MuMuPlayerGlobal-12.0-base\keymap_config'),
        (Join-Path $persistRoot 'nx_device\15.0\vms\MuMuPlayerGlobal-15.0-base\install_apk'),
        (Split-Path $appDataConfig -Parent),
        $newRoot
    )
    New-Item -ItemType Directory -Path $directories -Force | Out-Null
    Set-Content -LiteralPath (Join-Path $persistRoot 'nx_device\12.0\shell\MuMuNxDevice.exe') -Value 'android12'
    Set-Content -LiteralPath (Join-Path $persistRoot 'nx_device\15.0\shell\MuMuNxDevice.exe') -Value 'android15'
    New-Item -ItemType Directory -Path (Split-Path $vmDataPath -Parent) -Force | Out-Null
    Set-Content -LiteralPath $vmDataPath -Value 'do-not-change-vm-data'

    $persistInstallConfig = [ordered]@{
        product = [ordered]@{ install_dir = $oldRoot; version = '6.8.5.0' }
        main = [ordered]@{ install_dir = (Join-Path $oldRoot 'nx_main') }
        engines = [ordered]@{
            nemux = [ordered]@{ player = [ordered]@{ install_dir = (Join-Path $oldRoot 'nx_device\12.0\shell') } }
            mumu15 = [ordered]@{ player = [ordered]@{ install_dir = (Join-Path $oldRoot 'nx_device\15.0\shell') } }
        }
    }
    $persistInstallPath = Join-Path $persistRoot 'configs\main\install_config.json'
    $persistInstallConfig | ConvertTo-Json -Depth 20 | Set-Content -LiteralPath $persistInstallPath -Encoding utf8
    $persistInstallConfig | ConvertTo-Json -Depth 20 | Set-Content -LiteralPath $appDataConfig -Encoding utf8

    $vm12Config = [ordered]@{
        path = (Join-Path $oldRoot 'nx_device\12.0\vms\MuMuPlayerGlobal-12.0-base\keymap_config')
        unrelated = '12.0'
    }
    $vm15Config = [ordered]@{
        path = (Join-Path $oldRoot 'nx_device\15.0\vms\MuMuPlayerGlobal-15.0-base\install_apk')
        unrelated = '15.0'
    }
    $vm12Path = Join-Path $persistRoot 'nx_device\12.0\configs\device\vm_config.json'
    $vm15Path = Join-Path $persistRoot 'nx_device\15.0\configs\device\vm_config.json'
    $vm12Config | ConvertTo-Json -Depth 10 | Set-Content -LiteralPath $vm12Path -Encoding utf8
    $vm15Config | ConvertTo-Json -Depth 10 | Set-Content -LiteralPath $vm15Path -Encoding utf8

    & ([scriptblock]::Create($helperText)) -Phase Pre -VersionRoot $newRoot -PersistRoot $persistRoot -AppDataConfig $appDataConfig -ProgramFilesRoot $programFilesMock -ServicesRegistryRoot $servicesRegistryRoot -ClassesRegistryRoot $classesRegistryRoot

    $persistAfter = Get-Content -LiteralPath $persistInstallPath -Raw | ConvertFrom-Json
    Assert ($persistAfter.product.install_dir -eq $newRoot) 'Pre-install did not update product.install_dir.'
    Assert ($persistAfter.main.install_dir -eq (Join-Path $newRoot 'nx_main')) 'Pre-install did not update main.install_dir.'
    Assert ($persistAfter.engines.nemux.player.install_dir -eq (Join-Path $persistRoot 'nx_device\12.0\shell')) 'Pre-install did not map nemux to its stable persist location for installer access.'
    Assert ($persistAfter.engines.mumu15.player.install_dir -eq (Join-Path $persistRoot 'nx_device\15.0\shell')) 'Pre-install did not map mumu15 to its stable persist location for installer access.'

    $vm12After = Get-Content -LiteralPath $vm12Path -Raw | ConvertFrom-Json
    $vm15After = Get-Content -LiteralPath $vm15Path -Raw | ConvertFrom-Json
    Assert ($vm12After.path -eq (Join-Path $persistRoot 'nx_device\12.0\vms\MuMuPlayerGlobal-12.0-base\keymap_config')) 'Android 12 config path was not mapped to its stable persist location during pre_install.'
    Assert ($vm15After.path -eq (Join-Path $persistRoot 'nx_device\15.0\vms\MuMuPlayerGlobal-15.0-base\install_apk')) 'Android 15 config path was not mapped to its stable persist location during pre_install.'
    Assert ((Get-Content -LiteralPath $vmDataPath -Raw).Trim() -eq 'do-not-change-vm-data') 'VM data was modified.'
    $backupRoot = Join-Path $persistRoot '_mumu-scoop-path-backups'
    Assert (Test-Path -LiteralPath $backupRoot -PathType Container) 'A backup folder was not created before configuration edits.'
    Assert ((Get-ChildItem -LiteralPath $backupRoot -Filter '*.json' -File -Recurse).Count -ge 4) 'Expected original configuration backups were not created.'

    # Simulate Scoop persist_data: version-local junctions are created after the installer succeeds.
    foreach ($name in @('configs','vms','nx_device')) {
        $versionLink = Join-Path $newRoot $name
        $persistTarget = Join-Path $persistRoot $name
        New-Item -ItemType Junction -Path $versionLink -Target $persistTarget | Out-Null
    }

    $persistAfterPost = Get-Content -LiteralPath $persistInstallPath -Raw | ConvertFrom-Json
    Assert ($persistAfterPost.engines.nemux.player.install_dir -eq (Join-Path $persistRoot 'nx_device\12.0\shell')) 'Pre-install persist path was unexpectedly changed before post_install.'
    $persistAfter = Get-Content -LiteralPath $persistInstallPath -Raw | ConvertFrom-Json
    Assert ($persistAfter.product.install_dir -eq $newRoot) 'Post-install did not leave product.install_dir at the current version root.'
    Assert ($persistAfter.engines.nemux.player.install_dir -eq (Join-Path $newRoot 'nx_device\12.0\shell')) 'Post-install did not restore nemux path through the version-local persist junction.'
    Assert ($persistAfter.engines.mumu15.player.install_dir -eq (Join-Path $newRoot 'nx_device\15.0\shell')) 'Post-install did not restore mumu15 path through the version-local persist junction.'
    $vm12Post = Get-Content -LiteralPath $vm12Path -Raw | ConvertFrom-Json
    $vm15Post = Get-Content -LiteralPath $vm15Path -Raw | ConvertFrom-Json
    Assert ($vm12Post.path -eq (Join-Path $newRoot 'nx_device\12.0\vms\MuMuPlayerGlobal-12.0-base\keymap_config')) 'Android 12 config path was not normalized after persist links were created.'
    Assert ($vm15Post.path -eq (Join-Path $newRoot 'nx_device\15.0\vms\MuMuPlayerGlobal-15.0-base\install_apk')) 'Android 15 config path was not normalized after persist links were created.'

    foreach ($engine in @(
        [pscustomobject]@{Version='12.0';Runtime='MuMuVMMVbox';Service='MuMuVMMDrv';Driver='MuMuVMMDrv.sys';Server='MuMuVMMSVC.exe';CLSID='{23cd1535-edaa-4f21-a4ab-45d97fd1d58b}'}
        [pscustomobject]@{Version='15.0';Runtime='MuMuNxVbox';Service='MuMuNxSup';Driver='MuMuNxSup.sys';Server='MuMuNxSVC.exe';CLSID='{50859a2f-a5dd-4fcd-b107-ff2a37b33e4a}'}
    )) {
        $runtime = Join-Path $programFilesMock $engine.Runtime
        $driver = Join-Path $runtime "LoadedDrivers\$($engine.Driver)"
        $server = Join-Path $runtime "Hypervisor\$($engine.Server)"
        New-Item -ItemType Directory -Path (Split-Path $driver -Parent),(Split-Path $server -Parent) -Force | Out-Null
        Set-Content -LiteralPath $driver -Value 'driver'
        Set-Content -LiteralPath $server -Value 'server'

        $serviceKey = Join-Path $servicesRegistryRoot $engine.Service
        New-Item -Path $serviceKey -Force | Out-Null
        Set-ItemProperty -LiteralPath $serviceKey -Name ImagePath -Value $driver

        $comKey = Join-Path $classesRegistryRoot ($engine.CLSID + '\LocalServer32')
        $registryKey = [Microsoft.Win32.Registry]::CurrentUser.CreateSubKey(
            $comKey -replace '^HKCU:\\',''
        )
        try { $registryKey.SetValue('', $server, [Microsoft.Win32.RegistryValueKind]::String) }
        finally { $registryKey.Dispose() }
    }

    $postOutput = @(& ([scriptblock]::Create($helperText)) -Phase Post -VersionRoot $newRoot -PersistRoot $persistRoot -AppDataConfig $appDataConfig -ProgramFilesRoot $programFilesMock -ServicesRegistryRoot $servicesRegistryRoot -ClassesRegistryRoot $classesRegistryRoot 2>&1 | ForEach-Object { "$_" })
    $postText = $postOutput -join [Environment]::NewLine
    Assert ($postText -match 'Android 12: Hypervisor and COM checks passed') 'Android 12 Hypervisor/COM validation did not pass.'
    Assert ($postText -match 'Android 15: Hypervisor and COM checks passed') 'Android 15 Hypervisor/COM validation did not pass.'

    foreach ($path in @($persistInstallPath,$appDataConfig,$vm12Path,$vm15Path)) {
        $content = Get-Content -LiteralPath $path -Raw
        Assert (-not $content.Contains('1.8.5.5748')) "Old Scoop version path remains in $path"
    }
    Assert ((Get-Content -LiteralPath $vmDataPath -Raw).Trim() -eq 'do-not-change-vm-data') 'VM data changed after post-install validation.'

    Write-Host 'MuMuPlayer persisted-path migration regression passed.'
    @(
        '## MuMuPlayer persisted-path migration'
        ''
        '- Verified old Scoop version paths are migrated in AppData and persisted MuMu JSON configuration.'
        '- Verified Android 12 and Android 15 paths remain mapped to their own engine directories.'
        '- Verified backups are created before JSON changes.'
        '- Verified VM data under persist\vms is not modified.'
        '- Verified Hypervisor driver and COM LocalServer32 registrations for both engines using isolated mock roots.'
        ''
        'No live MuMu installer, Windows kernel driver, COM registration, or user VM data was modified.'
    ) | Out-File -LiteralPath $env:GITHUB_STEP_SUMMARY -Encoding utf8
}
finally {
    if (Test-Path -LiteralPath $testRoot) {
        Remove-Item -LiteralPath $testRoot -Recurse -Force -ErrorAction SilentlyContinue
    }
    if (Test-Path -LiteralPath $registryRoot) {
        Remove-Item -LiteralPath $registryRoot -Recurse -Force -ErrorAction SilentlyContinue
    }
}
