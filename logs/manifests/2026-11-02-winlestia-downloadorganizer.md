# Winlestia and Download Organizer manifests — 2026-11-02

## Added

- `bucket/winlestia.json` — Winlestia 0.9.0, official x64 Inno Setup release asset. The manifest extracts the Inno payload and exposes the GUI shortcut plus the `winlestia` CLI.
- `bucket/downloadorganizer.json` — Download Organizer 0.1.0, official x64 Tauri/NSIS setup. The manifest runs the setup silently inside the Scoop version directory and declares the matching silent uninstaller.
- Both manifests use the official GitHub Releases API for `checkver` and version-tagged URLs with Release asset digest lookup for `autoupdate`.

## Portability classification

- **Winlestia — Portable.** The upstream `installer/Winlestia.iss` identifies Inno Setup 6, the GUI executable at `Glass-v5\\Panneaux.Glass.exe`, and the CLI at `Glass-v5\\winlestia.exe`. Scoop uses `innosetup: true`, so the vendor setup routine is not executed. The app itself replaces the taskbar while running; optional autostart and terminal integrations can still write current-user settings when enabled. Profile/settings remain in `%LOCALAPPDATA%\\Panneaux`.
- **Download Organizer — Nonportable.** The upstream Tauri configuration declares the NSIS bundle target. Scoop executes the official setup with `/S /D=$dir`; the files remain under Scoop, but the normal setup/uninstall registration is still being used. The application's signed updater is separate from Scoop and can be disabled in Settings. Settings/history remain in `%APPDATA%\\com.thonyy.download-organizer`.

## Source and validation

- Winlestia release `v0.9.0`: official asset `Winlestia-Setup-0.9.0.exe`, 192,973,298 bytes; GitHub SHA-256 `c9c406669bd9e7205aba2c3458fb23b727cd53b74b1991bc0456d06152442834`.
- Download Organizer release `v0.1.0`: official asset `Download.Organizer_0.1.0_x64-setup.exe`, 2,857,995 bytes; GitHub SHA-256 `1bfa7be1429ae20a8f120918e1b029e32e5773ede33b6aaa61a7069ce5295119`. The source branch already reports package version 0.1.1, but no 0.1.1 release asset was published at the time of this update, so the manifest tracks the latest published release (0.1.0).
- Both manifest files passed JSON parsing before commit. Installer technologies, release asset names, hashes, application paths, Tauri package target and uninstaller hook were checked against the official project repositories.
- A Windows Scoop install/upgrade/uninstall smoke test, Inno payload extraction test, and live `checkver.ps1` / archive / autoupdate CI validation were not run in this environment. Do not treat those tests as passed until the repository workflows or a Windows test confirm them.
