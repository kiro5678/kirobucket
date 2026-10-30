# Manifest Portability Inventory

**Audit target:** `master`  
**Bucket manifests reviewed:** 825  
**Classification:** based on the actions declared by each manifest, not on the file extension or the folder where the application files are placed.

## Definitions

| Class | Meaning in this repository |
|---|---|
| **Portable** | Scoop downloads a standalone executable or extracts an archive/installer payload into the Scoop app directory. The manifest does not run the vendor's installation routine or register a Windows package/component as part of installation. The application files can generally be moved with the Scoop app directory. |
| **Nonportable** | The manifest runs the vendor's setup routine, registers an MSIX/AppX package, installs a driver/service/runtime, installs fonts into Windows, or writes persistent Windows integration such as a protocol registration. This remains Nonportable even when the setup routine places the main files inside `$dir` or the Scoop app directory. |
| **Review** | The manifest downloads a setup/package asset but its current instructions do not establish a safe, complete extraction or installation method. Do not assume it is Portable until the payload and launch path are verified. |

**Application data is not part of this classification.** A Portable application may still store settings, profiles, databases, caches, or other user data under `%APPDATA%`, `%LOCALAPPDATA%`, Documents, or another location outside Scoop. Portable means the application payload is not installed into Windows by the manifest; it does not mean that every part of the application's data is relocatable.

The word *Nonportable* here describes installation behavior. It does not mean that every listed program installs to `C:\Program Files` or affects every Windows account. Some installers are per-user, some are machine-wide, and some install their files under Scoop but still run the real vendor setup.

## Summary

| Classification | Manifests | How to interpret it |
|---|---:|---|
| Portable | 768 | Current manifest instructions use standalone files or extraction without a Windows installation routine. |
| Nonportable | 53 | The manifest performs an actual installation or persistent Windows registration. |
| Review | 4 | The current manifest does not prove a complete portable extraction or installation path. |
| **Total** | **825** | Current JSON files in `bucket/` on `master`. |

## Nonportable manifests

These manifests execute an actual installer or create persistent Windows integration. A target path inside Scoop does **not** change the classification.

| Manifest | Install behavior / scope |
|---|---|
| [agaric](../bucket/agaric.json) | Runs the NSIS setup with silent install arguments and `/D=$dir`. |
| [air-server-np](../bucket/air-server-np.json) | Runs `msiexec /i` with elevation; installs through Windows Installer. |
| [another](../bucket/another.json) | Runs the vendor setup with `/S /NS /D=$dir`. |
| [belarc-advisor](../bucket/belarc-advisor.json) | Runs the vendor installer; `/D=$dir` is intended to redirect its installation, but the manifest notes that this behavior has not been independently confirmed. |
| [biscuit](../bucket/biscuit.json) | Runs the NSIS setup silently from `pre_install`; it is not extracted as an archive. |
| [clustercut](../bucket/clustercut.json) | Runs the vendor setup with `/S /NS /D=$dir`. |
| [coodesker-github](../bucket/coodesker-github.json) | Runs the vendor setup with `/S /D=$dir`. |
| [crowdsec](../bucket/crowdsec.json) | Runs the MSI installer silently. **Manifest issue:** the download is 1.8.2 but `installer.file` currently names `crowdsec_1.8.1.msi`. |
| [directx-np](../bucket/directx-np.json) | Runs the extracted `DXSETUP.exe`; installs DirectX runtime components into Windows. |
| [dlman](../bucket/dlman.json) | Runs the vendor setup with `/S /D=$dir`. |
| [ecopaste](../bucket/ecopaste.json) | Runs the NSIS setup with silent/update arguments and `/D=$dir`. |
| [ecopaste-nightly](../bucket/ecopaste-nightly.json) | Runs the NSIS setup silently with `/D=$dir`. |
| [edge-drop](../bucket/edge-drop.json) | Runs the vendor setup with `/S /D=$dir`. |
| [everything-cmdpal](../bucket/everything-cmdpal.json) | Registers an MSIX package with `Add-AppxPackage` for the current user. |
| [filepilot](../bucket/filepilot.json) | Runs the vendor setup with `/S /D=$dir`. |
| [fluentstore](../bucket/fluentstore.json) | Runs the official interactive installer; registers an MSIX package and requires trust approval for its signing certificate. |
| [fxsound](../bucket/fxsound.json) | Runs the official setup/MSI installation. Installs the FxSound virtual audio driver system-wide; elevated install/uninstall is required. |
| [helixnotes](../bucket/helixnotes.json) | Runs the vendor setup with `/S /D=$dir`. |
| [imazing-np](../bucket/imazing-np.json) | Runs the vendor setup silently with administrator rights and a directory override. |
| [k-lite-codec-pack-mega-np](../bucket/k-lite-codec-pack-mega-np.json) | Runs the K-Lite setup silently; this is a real codec installation, not archive extraction. |
| [lapis](../bucket/lapis.json) | Runs the vendor setup with `/S /D=$dir`. |
| [livewallpaper](../bucket/livewallpaper.json) | Runs the Inno Setup installer silently with elevated rights and `/DIR=$dir`. |
| [mumuplayer](../bucket/mumuplayer.json) | Executes the MuMuPlayer vendor installation workflow (`install_prepare` and `commit`); administrator rights are required. **Manifest issue:** the current file failed JSON parsing during this review because its `pre_install` value contains literal line breaks inside a JSON string; fix the JSON before relying on this manifest. |
| [mumuplayer-android15](../bucket/mumuplayer-android15.json) | Executes the Android 15 engine setup workflow and modifies the existing MuMuPlayer installation directory. |
| [mumuplayer-online](../bucket/mumuplayer-online.json) | Runs the MuMuPlayer setup silently with elevated rights. |
| [nightlight-launcher](../bucket/nightlight-launcher.json) | Runs the vendor setup with `/S /D=$dir`. |
| [npcap-np](../bucket/npcap-np.json) | Runs the Npcap setup through AutoHotkey with elevation; installs a network driver/component. |
| [nvidia-desktop-graphic-driver-np](../bucket/nvidia-desktop-graphic-driver-np.json) | Runs the extracted NVIDIA setup silently with elevation; installs the display driver. |
| [nvidia-notebook-graphic-driver-np](../bucket/nvidia-notebook-graphic-driver-np.json) | Runs the extracted NVIDIA setup silently with elevation; installs the notebook display driver. |
| [office-365-apps-home-np](../bucket/office-365-apps-home-np.json) | Runs Office Deployment Tool with the configuration XML to install Microsoft 365/Office. |
| [onedrive-np](../bucket/onedrive-np.json) | Runs Microsoft's installer with `/allusers`; installs OneDrive for all users. |
| [open-shell](../bucket/open-shell.json) | Runs the Open-Shell setup with Windows Installer quiet arguments. |
| [open-shell-nightly](../bucket/open-shell-nightly.json) | Runs the Open-Shell nightly setup with Windows Installer quiet arguments. |
| [openedr](../bucket/openedr.json) | Runs `msiexec /i`; installs the OpenEDR endpoint agent through Windows Installer. |
| [openglass](../bucket/openglass.json) | Runs the signed setup with Inno Setup silent-install arguments. |
| [openzfs-np](../bucket/openzfs-np.json) | Runs the OpenZFS setup silently; installs system-level filesystem components. |
| [poweriso](../bucket/poweriso.json) | Runs the PowerISO setup silently with `/S`. |
| [powershell-np](../bucket/powershell-np.json) | Runs the PowerShell MSI with `msiexec /i` and administrator rights. |
| [recordly](../bucket/recordly.json) | Runs the vendor setup with `/S /D=$dir`. |
| [sandboxie-plus](../bucket/sandboxie-plus.json) | Runs the Sandboxie setup silently; installs system integration including its driver/service components. |
| [scanner](../bucket/scanner.json) | Registers the MSIX package with `Add-AppxPackage` for the current user. |
| [screenbox](../bucket/screenbox.json) | Registers the MSIX bundle and its APPX dependencies with `Add-AppxPackage` for the current user. |
| [smol](../bucket/smol.json) | Runs the vendor setup with `/S /D=$dir`. |
| [sofast](../bucket/sofast.json) | Runs the vendor setup with `/S /D=$dir`; WebView2 remains an external runtime dependency. |
| [spacedrive](../bucket/spacedrive.json) | Runs the vendor setup with `/S /D=$dir`. |
| [sucrose](../bucket/sucrose.json) | Runs the official per-user bundle installer; installs under `%LOCALAPPDATA%\Sucrose` and creates shortcuts. |
| [sucrose-nightly](../bucket/sucrose-nightly.json) | Runs the official per-user bundle installer; installs under `%LOCALAPPDATA%\Sucrose` and creates shortcuts. |
| [tockler](../bucket/tockler.json) | Runs the vendor setup with `/S /D=$dir`. |
| [ttf-stix2](../bucket/ttf-stix2.json) | Copies fonts into the Windows Fonts directory and registers them in the Fonts registry key. Scope is per-user or all-users depending on the Scoop install mode. |
| [ubiquiti-wifiman-desktop-installer](../bucket/ubiquiti-wifiman-desktop-installer.json) | Runs the WiFiman vendor setup with `/S /D=$dir`. |
| [wincux](../bucket/wincux.json) | Runs the vendor setup with `/S /D=$dir`. |
| [yt-dlp-gui](../bucket/yt-dlp-gui.json) | Extracts the MSI payload, then registers the `ytdlp-gui://` URL protocol under `HKCU\Software\Classes`; the registry entry points to the Scoop app path. |
| [znote](../bucket/znote.json) | Runs the vendor setup with `/S /D=$dir`. |

## Review before classifying

These entries should not be treated as Portable or Nonportable until their payloads and launch behavior are checked.

| Manifest | Why it needs review |
|---|---|
| [go-away-edge-installer](../bucket/go-away-edge-installer.json) | Downloads a standalone `.exe` and creates a shortcut, but the manifest has no extraction or installer instructions. The shortcut label says “Installer”; inspect the executable before classifying it. |
| [motrix-next](../bucket/motrix-next.json) | Downloads a `*-setup.exe` without an archive fragment or installer instructions. Its declared `bin` is `motrix-next.exe`, which does not match the downloaded setup filename. The current extraction/launch path is not established. |
| [quanto-flx](../bucket/quanto-flx.json) | Downloads a Rainmeter `.rmskin` add-on and depends on Rainmeter; the notes say it is installed through `SkinInstaller.exe`. This is an add-on payload, not a standalone portable application. |
| [zenbreak-msix](../bucket/zenbreak-msix.json) | Renames an MSIX asset as a 7-Zip archive and extracts its files without registering the MSIX package. Verify that the unpackaged executable works before calling it Portable. |

## Portable examples and important exceptions

The following are examples of Portable manifest techniques in this bucket:

| Manifest pattern | Example manifests | Why they are Portable |
|---|---|---|
| MSI extraction, not Windows Installer execution | [rqbit](../bucket/rqbit.json), [sklad](../bucket/sklad.json), [timigs](../bucket/timigs.json), [clipper](../bucket/clipper.json), [cooldesk-msi](../bucket/cooldesk-msi.json), [cedro-modern-dock](../bucket/cedro-modern-dock.json), [scrcpy-gui-kil0bit](../bucket/scrcpy-gui-kil0bit.json), [poltertype](../bucket/poltertype.json), [dnschanger-msi](../bucket/dnschanger-msi.json) | Scoop extracts the MSI payload; the manifest does not run `msiexec /i`. |
| Inno Setup payload extraction | [fort](../bucket/fort.json), [lively](../bucket/lively.json), [taskexplorer](../bucket/taskexplorer.json), [reg-organizer](../bucket/reg-organizer.json), [soft-organizer](../bucket/soft-organizer.json), [Auslogics-disk-defrag](../bucket/Auslogics-disk-defrag.json) | `innosetup: true` tells Scoop to extract the installer payload instead of running the vendor setup. |
| EXE/NSIS payload extraction | [endstate](../bucket/endstate.json), [mechvibes](../bucket/mechvibes.json), [openscreen](../bucket/openscreen.json), [keyboardsounds](../bucket/keyboardsounds.json), [keyboardsounds-pro](../bucket/keyboardsounds-pro.json), [super-productivity](../bucket/super-productivity.json), [safepdf-installer](../bucket/safepdf-installer.json) | The downloaded setup file is treated as an archive or its embedded application archive is extracted; the vendor setup routine is not executed. |
| Explicit portable mode | [windhawk](../bucket/windhawk.json), [winhance](../bucket/winhance.json) | Their manifest passes the application's explicit portable-mode option. |
| Setup executable used only as an extractor | [veracrypt](../bucket/veracrypt.json), [hxd.chs](../bucket/hxd.chs.json) | The manifest uses the setup program only to extract application files; it does not perform the normal installation. |
| File-only or direct portable payload | [filee](../bucket/filee.json), [drift](../bucket/drift.json), [bulk-crap-uninstaller](../bucket/bulk-crap-uninstaller.json), [MPOGPUFIX](../bucket/MPOGPUFIX.json), [winzenith](../bucket/winzenith.json), [spotlight-downloader](../bucket/spotlight-downloader.json) | The manifest downloads an archive or standalone executable without running a Windows installer. |

### Portable does not mean system-neutral at runtime

The classification above concerns what the Scoop manifest does during installation. Some Portable applications can still request administrator rights or change Windows when the user enables a feature or runs a command:

| Manifest | Runtime caveat not performed by the current Scoop install hook |
|---|---|
| [pulse](../bucket/pulse.json) | The ZIP is extracted by Scoop. First-time registration/start of `PulseService` is deliberately left to the app's in-app Repair / Install service action. |
| [ublockdnsclient](../bucket/ublockdnsclient.json) | The binary is extracted; the user must explicitly run its elevated `install` command to configure the DNS service. |
| [net-merge](../bucket/net-merge.json) | The official portable ZIP is extracted; system-wide connection balancing may require a virtual network adapter when used. |
| [patchlight](../bucket/patchlight.json) | The ZIP is extracted; the SYSTEM scheduled task from the vendor setup is not created by the manifest. |
| [veracrypt](../bucket/veracrypt.json) | The portable files are extracted; mounting volumes loads a driver at runtime and requires administrator privileges. |
| [winutil](../bucket/winutil.json) | The manifest downloads a PowerShell script only; the user may run it elevated to change Windows settings, services, registry, apps, and updates. |
| [MPOGPUFIX](../bucket/MPOGPUFIX.json) | The ZIP is extracted; the utility can change Windows graphics settings when the user runs its repair actions. |

Do not move these runtime caveats into the Nonportable list unless the manifest itself starts the installation or registration during `scoop install`.

## Classification rules for future manifest changes

1. Inspect the actual downloaded asset and its archive contents. The `.exe`, `.msi`, or `.msix` extension alone does not determine the class.
2. If the manifest uses `installer` to run the vendor setup, classify it as Nonportable unless the setup is explicitly being used only as a file extractor or the vendor's documented portable mode is selected.
3. An MSI with no deprecated `msi` install block is normally treated as an archive by Scoop. An explicit `msiexec /i` command is a real installation and is Nonportable.
4. `#/dl.7z` tells Scoop to save the downloaded asset with an archive filename and extract it. It does not prove that the resulting files are a working portable application; inspect the extracted payload and launch target.
5. `innosetup: true` selects Inno Setup extraction. It does not mean that the vendor installation routine ran.
6. A normal installer that writes its files to `$dir` is still Nonportable if the manifest executes the installation routine or registers services, drivers, AppX/MSIX packages, fonts, protocol handlers, or other Windows integration.
7. A Portable manifest may have data outside the Scoop directory. Record that as a data/persistence note, not as a reason to mark the manifest Nonportable.
8. Reclassify a manifest whenever its URL, installer arguments, extraction method, or install hooks change. Update this document in the same commit.

## Official references

- [Scoop App Manifests](https://github.com/ScoopInstaller/Scoop/wiki/App-Manifests) — installer, MSI extraction, Inno Setup, and archive URL-fragment behavior.
- [Scoop README](https://github.com/ScoopInstaller/Scoop) — overview of Scoop's portable-app model and the separate `nonportable` bucket.
