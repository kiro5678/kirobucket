# Canonical Nonportable Manifest Classifications

This file is the source of truth for manifests classified as Nonportable. The generated tables in `manifest-portability.md` are outputs only; do not use them as classification input.

| Manifest | Reason |
| --- | --- |
| [diskdrift](../bucket/diskdrift.json) | The official Inno Setup registers a LocalSystem service and machine-wide startup entry, with binaries under protected Program Files; it requires elevation. |
| [flowcat-windows](../bucket/flowcat-windows.json) | The official Inno Setup installer registers the FlowCat Collector Windows service and requires elevation. `/DIR=$dir` keeps program binaries in the Scoop version directory, but the required service lifecycle remains a system-level install. |
| [fibratus](../bucket/fibratus.json) | The official MSI registers a LocalSystem service, installs its service executable under protected Program Files, and adds that protected Bin directory to the machine-wide PATH; it requires elevation and must not be redirected to the user-writable Scoop directory. |
| [oo-bluecon](../bucket/oo-bluecon.json) | O&O's official Setup EXE performs a machine-wide Windows Installer installation and requires elevation; it is not a portable application payload. |
