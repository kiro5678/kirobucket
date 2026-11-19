# Orfeo Scoop payload extraction — 2026-11-19

## Decision

Use the official Windows Setup NSIS asset, not the Portable self-extracting EXE, for the Scoop manifest. The Setup package contains a nested archive with the complete app payload. Scoop can extract that payload into its version directory without running the vendor installer.

## Upstream files and hashes

| Asset | Size | SHA-256 | Result |
| --- | ---: | --- | --- |
| Orfeo-1.7.3-portable.exe | 143,806,967 bytes | 39b7a44b730cab44033defe82d63a05b0b3b087543f5e05e5e448d1313a7125f | Outer SFX extracts only four bootstrap files; app itself extracts under TEMP when launched |
| Orfeo-Setup-1.7.3.exe | 155,969,595 bytes | 4219b3e689ac5bb29949c1f378f665082f7379ab0ebe56a24bed94c506848728 | Outer NSIS plus nested app-64.7z extraction succeeds |

## Confirmed package layout

The official Setup NSIS container exposes $PLUGINSDIR/app-64.7z. Extracting that archive produces 96 application files, including:

- Orfeo.exe
- resources/app.asar
- resources/elevate.exe
- resources/native/orfeo-review.exe
- resources/native/orfeo_audio.node

## Manifest implementation

bucket/orfeo.json now:

1. Downloads Orfeo-Setup-1.7.3.exe#/dl.7z with its verified GitHub SHA-256.
2. Lets Scoop's normal extraction stage extract the outer NSIS container into the version directory.
3. Uses pre_install to run Expand-7zipArchive on $PLUGINSDIR/app-64.7z into the same version directory.
4. Checks for the app executable, Electron archive, and required native payload files before continuing.
5. Generates Orfeo.cmd, which sets PORTABLE_EXECUTABLE_DIR=%~dp0 and launches Orfeo.exe from the version directory.
6. Removes the temporary NSIS plugin directory and uninstaller remnants.
7. Persists Orfeo-Data, which is where Orfeo stores settings, demo data, and downloaded soundfonts in portable mode.
8. Exposes Orfeo.cmd through both Scoop's bin and Start Menu shortcut.

The wrapper is necessary because the application detects PORTABLE_EXECUTABLE_DIR to choose the location of Orfeo-Data. Running the extracted Orfeo.exe without that environment variable would use its normal installed-build user-data location.

## Workflow evidence

- Portable vs Setup extraction experiment: [run 44441542007](https://github.com/kiro5678/kirobucket/actions/runs/44441542007). Portable SFX extraction does not produce the full app tree; Setup outer NSIS extraction and nested app-64.7z extraction succeed; the extracted Orfeo application launches from the test app directory.
- Final manifest extraction / launcher / persistence test: [run 44442604728](https://github.com/kiro5678/kirobucket/actions/runs/44442604728). Verifies the exact Setup hash, executes the actual pre_install strings from bucket/orfeo.json, confirms all required application paths, confirms Orfeo runs from the Scoop app version directory rather than TEMP, and confirms data is written beneath the simulated Scoop persist location.
- Checkver: [run 44442734824](https://github.com/kiro5678/kirobucket/actions/runs/44442734824), passed in PowerShell 5.1 and PowerShell 7.
- Archive validation: [run 44442846830](https://github.com/kiro5678/kirobucket/actions/runs/44442846830), passed.
- Autoupdate validation: [run 44442938157](https://github.com/kiro5678/kirobucket/actions/runs/44442938157), passed.
- Manifest Pipeline: [run 44442604699](https://github.com/kiro5678/kirobucket/actions/runs/44442604699), passed.
- Separate Portable TEMP diagnostic: [run 44443082506](https://github.com/kiro5678/kirobucket/actions/runs/44443082506), passed after the diagnostic was decoupled from the Scoop manifest.

## Scope and limitations

The final extraction workflow reproduced Scoop's outer archive extraction stage, ran the actual manifest pre_install script, verified the launcher, and tested app execution with a simulated persist junction. It did not run a complete scoop install / scoop uninstall CLI lifecycle on a user machine. The application was launched in a Windows Actions runner for a controlled smoke test; normal interactive use and all application features were not exhaustively tested.

## Files

- Manifest: [bucket/orfeo.json](../../bucket/orfeo.json)
- Extraction workflow: [orfeo-scoop-extraction-experiments.yml](../../.github/workflows/orfeo-scoop-extraction-experiments.yml)
- Portable TEMP diagnostic: [orfeo-portable-temp-test.yml](../../.github/workflows/orfeo-portable-temp-test.yml)
- Inventory: [docs/manifest-portability.md](../../docs/manifest-portability.md)