# Layer, Orfeo, and Pulse Monitor manifests — 2026-11-01

## Added

- `bucket/orfeo.json` — Orfeo 1.6.0. Uses the official Electron Builder portable target, pins the release SHA-256, renames the versioned asset to `Orfeo.exe`, and persists the verified `Orfeo-Data` directory used by the portable build.
- `bucket/pulse-monitor.json` — Pulse Monitor 1.3.4. Uses Inno Setup payload extraction with `innounp`; the main executable path is confirmed by upstream `setup.iss`. The optional PawnIO driver setup is not executed by Scoop. The app itself requests Administrator privileges.
- `bucket/layer.json` — Layer 1.11.2, recorded as **Review**. Both x64 and ARM64 official setup assets and their GitHub SHA-256 digests are pinned. The manifest stages the installer only and does not claim to install the app.

## Review rationale

- Layer's `tauri.conf.json` declares NSIS packaging and `installMode: both`. Tauri's current issue #16006 reports that the silent `/D=` install-directory argument can be ignored with this mode. No portable asset or verified extracted payload was established, so the manifest does not run the setup or point a shortcut at an unverified path.
- Layer's source repository declares MIT, but the distributed bundle includes `src-tauri/eula.txt` with separate redistribution restrictions. The manifest uses `license: Unknown` pending clarification of the binary's applicable terms.

## Validation and limitations

- Parsed all three manifest JSON documents before writing.
- Release versions, asset URLs, and SHA-256 digests were taken from the upstream GitHub Releases metadata.
- Verified Orfeo's portable target and `Orfeo-Data` path from its `package.json` and `electron/main.ts`.
- Verified Pulse's Inno Setup type, `Pulse.exe` file placement, optional driver task, and elevation manifest from upstream `setup.iss`, `Pulse.csproj`, and `app.manifest`.
- Verified Layer's Tauri NSIS target, `installMode: both`, and bundled EULA from its upstream configuration and release workflow.
- Windows Scoop install/run/uninstall tests and the archive-extraction workflows have not been run in this session. No claim is made that those runtime tests passed.
- Updated the portability inventory and category map. Editing `.github/workflows/manifest-table.yml` triggers the repository's documentation-generation workflow; its run still needs to be checked.
