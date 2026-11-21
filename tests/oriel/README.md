# Oriel Notch Scoop manifest

Production manifest: `bucket/Oriel-Niix.json`

- Source: [Niix-x/Oriel-Releases](https://github.com/Niix-x/Oriel-Releases)
- Current tested release: `1.1.1`
- Official installer: `OrielSetup-1.1.1.exe`
- SHA-256: `808ec378fcc90c8ae90ace3628596d8819ae728796a1229ff0cf5505ceb8d954`

This is the Oriel Notch desktop overlay. It is separate from the existing `bucket/oriel.json` package (Yangflow RSS reader) and `bucket/oriel-highercomve.json` package (Highercomve Zig framework CLI).

## Installation model

The publisher supplies a per-user setup executable, not a portable archive. Scoop runs the official setup interactively, without passing command-line switches. The setup wizard opens during `scoop install`; Scoop waits until the user completes or cancels it.

Before setup starts, `pre_install` checks for an existing standalone Oriel installation and refuses to take it over. After the wizard exits successfully, the `installer.script` verifies that `oriel.exe` and `uninstall.exe` exist in `%LOCALAPPDATA%\\Programs\\Oriel`, creates a Junction in the Scoop version directory, and removes the downloaded setup file. The shim and Start Menu shortcut target the executable through that Junction.

This package is **not portable**. Oriel keeps its user data in `%APPDATA%\\Oriel` and uses Windows Credential Manager for some credentials. The existing uninstaller script remains responsible for Scoop uninstall and update operations. Disable Oriel's built-in automatic update check in Settings > About so Scoop remains the update authority.

## Automated validation

The Windows workflow runs Scoop's official `checkver.ps1` against a temporary copy and verifies the generated version, setup URL, and SHA-256. It also checks that the guided installer uses the downloaded `$fname`, has no silent arguments, and that the `pre_install`, `installer.script`, and `uninstaller.script` PowerShell blocks parse successfully.

The workflow does **not** run the setup wizard or claim a full install/uninstall lifecycle: the GUI requires a person to complete it in an interactive Windows session. Complete one manual `scoop install Oriel-Niix` test on a desktop session before treating the runtime lifecycle as verified.

## Checkver and autoupdate

`checkver.github` reads the latest release tag from the official repository. `autoupdate.url` follows the published `v$version/OrielSetup-$version.exe` asset naming pattern. The workflow actively validates these fields using Scoop's own `checkver.ps1`.

## Important distinction

This manifest does not provide a portable installation and does not move Oriel's program files into the Scoop version directory. Scoop manages the publisher's per-user installation lifecycle through the junction and official uninstaller.
