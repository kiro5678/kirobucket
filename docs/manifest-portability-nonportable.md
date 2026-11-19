# Canonical Nonportable Manifest Classifications

This file is the source of truth for manifests classified as Nonportable. The generated tables in `manifest-portability.md` are outputs only; do not use them as classification input.

| Manifest | Reason |
| --- | --- |
| [bean-network-tester](../bucket/bean-network-tester.json) | The core network-impairment feature requires the bundled WinDivert kernel driver. The application loads it at runtime and elevates to Administrator; while loaded, Windows keeps WinDivert64.sys open in the app directory. |
| [better-windows-services](../bucket/better-windows-services.json) | Unelevated launches use the Scoop-persisted .NET extraction folder; elevated launches deliberately extract required native runtime libraries under `%ProgramData%\BetterWindowsServices`, outside Scoop-managed paths, where the application enforces a protected ACL before WPF starts. |
| [disk-activity-monitor](../bucket/disk-activity-monitor.json) | The official installer registers a Windows service and installs application files under Program Files; it requires elevation. |
| [diskdrift](../bucket/diskdrift.json) | The official Inno Setup registers a LocalSystem service and machine-wide startup entry, with binaries under protected Program Files; it requires elevation. |
| [flowcat-windows](../bucket/flowcat-windows.json) | The official Inno Setup installer registers the FlowCat Collector Windows service and requires elevation. `/DIR=$dir` keeps program binaries in the Scoop version directory, but the required service lifecycle remains a system-level install. |
| [fibratus](../bucket/fibratus.json) | The official MSI registers a LocalSystem service, installs its service executable under protected Program Files, and adds that protected Bin directory to the machine-wide PATH; it requires elevation and must not be redirected to the user-writable Scoop directory. |
| [oo-bluecon](../bucket/oo-bluecon.json) | O&O's official Setup EXE performs a machine-wide Windows Installer installation and requires elevation; it is not a portable application payload. |
| [llplayer](../bucket/llplayer.json) | The published Windows package is framework-dependent (`SelfContained=false`) and requires the .NET 10 Desktop Runtime outside Scoop-managed paths. The application archive itself is extracted into the Scoop app directory without running vendor setup. |
| [winrust-np](../bucket/winrust-np.json) | The executable declares `requireAdministrator`; its optional plugins install components under Program Files and modify Windows shell, services, and machine/user registry state. Scoop therefore distributes the launcher as Nonportable and runs its rollback command before removal. The bundled purge feature is irreversible and is not undone by rollback. |
