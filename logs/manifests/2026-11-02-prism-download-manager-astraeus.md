# Prism Download Manager rename and Astraeus manifest — 2026-11-02

## Changes

- Renamed `bucket/prism.json` to `bucket/prism-download-manager.json` and changed its Start Menu shortcut label to **Prism Download Manager**. The existing Prism release URL, version, hash, persistence, and browser-host cleanup logic were retained.
- Added `bucket/astraeus.json` for Astraeus 2.2.3 using the official standalone Windows executable, published SHA-256 digest, GitHub release checkver, and versioned autoupdate URL.
- Added `astraeus.ini` to Scoop persistence and documented Astraeus's first-run startup-copy behavior, registry/AppData storage, and built-in updater.
- Updated the portability inventory and category mapping: `prism-download-manager` → Download Managers; `astraeus` → Notch.

## Source verification

- Astraeus latest stable release checked: `v2.2.3`, published 2026-10-29.
- Official asset: `Astraeus.exe` (2,598,912 bytes). GitHub release metadata publishes SHA-256 `0b3846263040daf49c73f38f03eb1dcd33a77d4bf11746106e82e1522b2ca24c`.
- Upstream README describes a single native executable with no installer or separate runtime. It also documents the optional first-run startup flow, which copies the executable to `%LOCALAPPDATA%\\Programs\\Astraeus` when accepted.
- Upstream README documents settings under `HKCU\\Software\\Astraeus`, user data under `%LOCALAPPDATA%\\Astraeus`, and the built-in updater that replaces the executable after validating its hash.

## Validation and limitations

- Parsed the new Astraeus manifest as JSON and retained the existing Prism manifest data while changing its shortcut label.
- The SHA-256 is taken from GitHub's published release digest; the binary was not independently downloaded and re-hashed in this session.
- Windows Scoop install, update, launch, and uninstall tests were not run in this session.
- Updating `.github/workflows/manifest-table.yml` is intended to trigger the existing documentation-generation workflow after these manifest and inventory changes. Its generated outputs and Actions result must be checked separately.
