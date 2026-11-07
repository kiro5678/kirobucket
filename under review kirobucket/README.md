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

The folder currently contains **98 staged manifests**. The placeholder file is not a manifest and is intentionally excluded.

| Manifest | Reason |
| --- | --- |
| [anton](anton.json) | The official endpoint redirects to a setup EXE, but no publisher SHA-256 is available; installer behavior, installation path, and cleanup are unverified. |
| [autooff](autooff.json) | The official 4.25 setup EXE has no published SHA-256. Installer engine, payload, silent switches, custom install path, and cleanup behavior remain unverified. |
| [crowdsec-windows-firewall-bouncer](crowdsec-windows-firewall-bouncer.json) | The MSI installs a Windows service and runs a bouncer-registration custom action; it requires .NET 10. A Scoop-safe service lifecycle and runtime dependency strategy are not established. |
| [deeptutor](deeptutor.json) | The official v1.7.2 Windows Portable ZIP and SHA-256 are available, but the archive layout, main executable path, and launch behavior still need verification. |
| [go-away-edge-installer](go-away-edge-installer.json) | The EXE is the utility's setup/configuration entry point and can change Windows behavior. Its full runtime effects, state location, and rollback behavior have not been tested from Scoop. |
| [ipban](ipban.json) | The x64/x86 ZIPs are published, but IPBan's normal setup creates a Windows service and changes audit policy. Archive layout, configuration persistence, service lifecycle, and cleanup need verification. |
| [jan](jan.json) | The official release provides x64 and ARM64 setup EXEs but no Windows portable archive. Payload extraction, silent/custom installation, and uninstall behavior are unverified. |
| [keptinflow](keptinflow.json) | The official v0.89.0 setup EXE and digest are available, but the installer engine, payload, silent switches, custom install path, and uninstall behavior are unknown. |
| [layer](layer.json) | The official x64/ARM64 assets are Tauri/NSIS setup EXEs. Custom install-directory behavior, payload layout, and a Scoop-contained install/uninstall path remain unverified. |
| [mystify](mystify.json) | The official ZIP has no published SHA-256. Archive layout, executable path, and required .NET runtime availability have not been verified. |
| [pulse-launcher](pulse-launcher.json) | Only the v0.1 pre-release setup EXE is published. Installer engine, embedded payload layout, and install/uninstall behavior are unverified. |
| [quanto-flx](quanto-flx.json) | This is a Rainmeter RMSKIN add-on, not a standalone application. The manifest downloads the skin package but does not apply it through Rainmeter's SkinInstaller. |
| [starcodec](starcodec.json) | The official page lists the 20261016 package, but the final download target, SHA-256, installer engine, codec registration, and uninstall behavior remain unverified. |
| [taskslinger](taskslinger.json) | The official setup is a per-user installer targeting %LocalAppData%\Programs\TaskSlinger. No verified Scoop-contained installation or portable extraction method is available. |
| [tinywall](tinywall.json) | The official download is an MSI whose WiX custom actions invoke `TinyWall.exe /install` and `/uninstall`; the application requires a privileged service to manage Windows Filtering Platform rules. Scoop's default MSI extraction does not run those actions, the legacy `msi` property is deprecated, and a safe elevated install/update/uninstall lifecycle plus the current SHA-256 remain unverified. |
| [udm-pro](udm-pro.json) | The official v2.6.35 setup EXE and digest are available, but the installer engine, payload, silent/custom-directory switches, and uninstall behavior are unverified. |
| [vcredist-aio](vcredist-aio.json) | The ZIP contains a system-wide Visual C++ runtime installer that must be run manually as administrator. The archive and its broad runtime replacement/removal behavior still need inspection. |
| [visual-cpp-redist-aio](visual-cpp-redist-aio.json) | The x86/x64 manifest runs the upstream Installer.cmd quietly with elevation. Verify the archive root, script behavior, effects on existing runtimes, and update/uninstall implications. |
| [visual-cpp-redist-aio-arm64](visual-cpp-redist-aio-arm64.json) | The ARM64 SFX is run quietly with elevation. Confirm the vendor switches and system-wide installation behavior; Scoop uninstall intentionally does not remove the installed runtimes. |
| [Skwire Empire review batch](skwire-review.md) (**79 manifests**) | ZIP download URLs are recorded, but archive contents, SHA-256 values, executable paths, and shortcut targets have not yet been verified. See the batch index for dependencies, compatibility notes, and three entries not staged. |
