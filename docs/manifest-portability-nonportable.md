# Canonical Nonportable Manifest Classifications

This file is the source of truth for manifests classified as Nonportable. The generated tables in `manifest-portability.md` are outputs only; do not use them as classification input.

| Manifest | Reason |
| --- | --- |
| [disk-activity-monitor](../bucket/disk-activity-monitor.json) | The official installer registers a Windows service and installs application files under Program Files; it requires elevation. |
| [diskdrift](../bucket/diskdrift.json) | The official Inno Setup registers a LocalSystem service and machine-wide startup entry, with binaries under protected Program Files; it requires elevation. |
| [fibratus](../bucket/fibratus.json) | The official MSI registers a LocalSystem service, installs its service executable under protected Program Files, and adds that protected Bin directory to the machine-wide PATH; it requires elevation and must not be redirected to the user-writable Scoop directory. |
