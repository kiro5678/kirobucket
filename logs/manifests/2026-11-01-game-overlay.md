# GameOverlay manifest — 2026-11-01

## Added

- `bucket/game-overlay.json` — GameOverlay v1.0.20, official 64-bit `GameOverlay-folder.zip` onedir asset.
- Uses the GitHub Releases API for `checkver` and a version-tagged release URL for `autoupdate`.
- Declares `GameOverlay.exe` as the command shim and Start Menu shortcut target. The upstream build script creates the ZIP from the contents of `dist/onedir/GameOverlay`; the repository archive-validation workflow will verify the current release asset's extracted launch path.
- Pins the SHA-256 digest published in the official GitHub Release asset metadata: `9492eeea400f448f25e60c68b343245e7ddd1ab40dea88e5d5a7177f0d8ab6ef`. Asset size: 14,232,242 bytes (about 13.6 MiB).

## Portability classification

- Classified **Portable**. Scoop extracts the official ZIP and does not execute a vendor setup program or create Windows installation registrations.
- The application asks for administrator access at runtime for FPS capture, ping detection, and CPU sensor access. This UAC behavior is application runtime behavior, not an installation step performed by Scoop.
- Settings are stored outside Scoop at `%APPDATA%\\GameOverlay\\config.json`; uninstalling the Scoop app does not remove that file.
- If CPU temperature is unavailable because Windows blocks the bundled sensor driver's access, the upstream release recommends using Core Temp as a fallback. The manifest does not disable or modify the Windows vulnerable-driver blocklist.
- The overlay cannot render over exclusive-fullscreen games; Borderless / Windowed Fullscreen is required for the overlay.

## Validation

- Release tag `v1.0.20` and asset metadata were read from the official GitHub Releases API. The ZIP asset digest is published by GitHub as `sha256:9492eeea400f448f25e60c68b343245e7ddd1ab40dea88e5d5a7177f0d8ab6ef`.
- The manifest pins the corresponding SHA-256 and declares the executable path based on the upstream build script. CI archive validation and checkver/autoupdate validation remain to be reported after the commit-triggered manifest pipeline runs.
- No interactive application launch, UAC, or uninstall smoke test was performed on a Windows PC in this task.
