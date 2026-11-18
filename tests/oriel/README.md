# Oriel Notch Scoop manifest

Production manifest: `bucket/Oriel-Niix.json`

Source: [Niix-x/Oriel-Releases](https://github.com/Niix-x/Oriel-Releases)  
Current tested release: `1.1.1`  
Official installer: `OrielSetup-1.1.1.exe`  
SHA-256: `808ec378fcc90c8ae90ace3628596d8819ae728796a1229ff0cf5505ceb8d954`

This is the Oriel Notch desktop overlay. It is separate from the existing `bucket/oriel.json` package (Yangflow RSS reader) and `bucket/oriel-highercomve.json` package (Highercomve Zig framework CLI).

## Installation model

The publisher supplies a per-user setup executable, not a usable portable archive. The installer places the application in `%LOCALAPPDATA%\\Programs\\Oriel`; the Scoop manifest creates a junction inside its version directory and points the Scoop shim/shortcut through that junction.

This package is **not portable**. Before launching the official setup, it checks for an existing Oriel installation folder or uninstall registration and refuses to take ownership of an installation that was not created by this manifest. Uninstall invokes Oriel's registered `uninstall.exe --uninstall --silent`, checks that the application executable and registry references stay absent for five continuous seconds (maximum wait 30 seconds), and removes only the verified residual uninstaller.

Use Scoop as the update authority if Oriel's built-in updater is enabled.

## Automated validation

The active Windows workflow tests the production manifest itself. It:

1. Runs Scoop `checkver.ps1 -Update` against a temporary copy with a deliberately old version, then verifies the latest GitHub release version, generated download URL, and SHA-256.
2. Installs the package through a temporary Git bucket.
3. Runs two consecutive forced same-version `scoop update -f` cycles and checks after each that `oriel.exe`, the registered uninstaller, and the Scoop launch junction are present.
4. Runs `scoop uninstall` and verifies removal of the Scoop version directory, external Oriel executables, and Oriel uninstall registry entry.
5. Separately inspects the official installer, pinned hash, and extraction behavior.

The other files in `tests/oriel/manifests/` preserve the unsuccessful installation-method probes for reference; they are no longer part of the active CI matrix.

## Checkver and autoupdate

`checkver.github` reads the latest release tag from the official repository. `autoupdate.url` follows the published `v$version/OrielSetup-$version.exe` asset naming pattern. The workflow actively validates these fields using Scoop's own `checkver.ps1`.

## Important distinction

This manifest does not provide a portable installation and does not move Oriel's program files into the Scoop version directory. Scoop manages the publisher's per-user installation lifecycle through the junction and official uninstaller.
