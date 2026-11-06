# KiroBucket — Under Review

This folder is the staging area for manifests that are not ready for the active Scoop bucket.

A manifest belongs here when it is newly added but still needs verification, when maintenance or validation has failed, or when its installer, extraction method, launch path, checksum, or update behavior is uncertain.

**Files in this folder are outside `bucket/` and are not installable through KiroBucket.** Keep them here until the review is complete. Do not copy them back into `bucket/` until the manifest has been validated.

## Review checklist

1. Confirm the upstream project and official release asset.
2. Validate the JSON and the Scoop manifest schema.
3. Verify the release URL and SHA-256 checksum.
4. Inspect the actual installer/archive payload and confirm the executable path.
5. Confirm install, update, uninstall, persistence, and architecture behavior.
6. Run the relevant KiroBucket manifest validation workflows.
7. Move the manifest back to `bucket/` only after the checks pass, then update the relevant documentation.

## Current review queue

| Manifest | Reason |
| --- | --- |
| [go-away-edge-installer](go-away-edge-installer.json) | Installer type and extraction behavior are unknown; the manifest declares a shortcut but no verified setup or payload handling. |
| [quanto-flx](quanto-flx.json) | Rainmeter RMSKIN add-on, not a standalone application; it requires Rainmeter's SkinInstaller workflow. |
| [zenbreak-msix](zenbreak-msix.json) | MSIX file is being unpacked as a 7-Zip archive; the unpackaged executable still needs a runtime/launch test. |
| [anton](anton.json) | Official endpoint redirects to a setup EXE, but the publisher checksum and installer/uninstaller behavior are not verified. |
| [autooff](autooff.json) | Official 4.25 setup EXE has no upstream SHA-256; installer engine, payload, silent switches, custom install path, and portable extraction are unverified. |
| [starcodec](starcodec.json) | Official 20261016 download page lists the standard 45.5 MB package, but the final binary URL, SHA-256, installer engine, silent arguments, codec registration, and uninstall behavior are unverified. |
| [pulse-launcher](pulse-launcher.json) | Only a pre-release setup EXE is published; installer engine, payload layout, and uninstall behavior are unverified. |
| [taskslinger](taskslinger.json) | Official setup has no verified Scoop-contained install path or portable extraction method. |
| [layer](layer.json) | Tauri/NSIS setup has no separate portable build; its custom install directory and included EULA terms remain unresolved. |
| [keptinflow](keptinflow.json) | Official setup EXE; installer engine, payload layout, silent switches, and Scoop-contained install or portable extraction behavior are unverified. |
| [udm-pro](udm-pro.json) | 236 MB Windows setup EXE; no upstream license file or installer instructions. Installer engine, payload, silent/custom-directory switches, and uninstall behavior are unverified. |
| [nectarlink](nectarlink.json) | NSIS setup locks new install-directory ACLs and adds Firewall, scheduled-task, AppX, HKLM, and shortcut entries; `/S /D=$dir` is unsafe for Scoop, and no supported portable Windows build is published. |
| [jan](jan.json) | Tauri Windows setup only (x64 and ARM64); no Windows portable archive is published. Installer payload, silent install path, and uninstall behavior remain unverified. |
| [deeptutor](deeptutor.json) | Official Windows Portable ZIP is published, but its archive layout and actual application executable path have not yet been verified. |
| [twindesk](twindesk.json) | Per-machine NSIS setup uses Firewall rules, an HKLM WebClient setting, TrustedPeople certificate registration, and optional AppX/virtual-camera integration; Scoop-safe install and uninstall are unverified. |
| [mystify](mystify.json) | Official Windows ZIP has no published SHA-256; archive layout, executable path, and .NET runtime availability are unverified. It is an animation app rather than a native `.scr` screen saver. |
| [vcredist-aio](vcredist-aio.json) | The release ZIP checksum is published, but its payload has not been inspected. The upstream installer must be run manually as administrator and changes system-wide Visual C++ runtimes; Scoop must not execute it automatically. |
| [visual-cpp-redist-aio](visual-cpp-redist-aio.json) | x86/x64 ZIP manifest; the official Installer.cmd is invoked in quiet mode with administrator approval. Confirm the archive root layout and installation behavior before promotion. |
| [visual-cpp-redist-aio-arm64](visual-cpp-redist-aio-arm64.json) | ARM64 SFX EXE manifest; the vendor's quiet installer is invoked with administrator approval. Verify installation behavior before promotion. |

