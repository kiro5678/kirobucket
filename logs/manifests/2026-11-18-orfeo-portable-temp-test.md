# Orfeo Portable TEMP runtime test — 2026-11-18

## Result

**Passed.** GitHub Actions run [44318206990](https://github.com/kiro5678/kirobucket/actions/runs/44318206990) launched the official Windows Portable asset from the existing Scoop manifest on a Windows Server 2025 runner.

## Asset verification

- Manifest: `bucket/orfeo.json`
- Version: `1.7.3`
- Official asset: `Orfeo-1.7.3-portable.exe`
- Downloaded size: `143,806,967` bytes
- Manifest SHA-256: `39b7a44b730cab44033defe82d63a05b0b3b087543f5e05e5e448d1313a7125f`
- Downloaded SHA-256: `39b7a44b730cab44033defe82d63a05b0b3b087543f5e05e5e448d1313a7125f`
- Hash result: exact match

## Runtime observation

The workflow redirected the launched process's `TEMP` and `TMP` environment variables to an isolated directory and monitored it while Orfeo was running.

Observed evidence:

- 2 temporary directories were created under the isolated TEMP.
- 6 executable files appeared under those directories, including the extracted `Orfeo.exe`, `resources\\elevate.exe`, and `resources\\native\\orfeo-review.exe`.
- 4 `Orfeo.exe` processes were observed with executable paths inside the isolated TEMP directory.
- 197 files were present under isolated TEMP at the end of the observation window.
- The launcher remained running during the 40-second observation window.

The output included paths of the form:

```text
...\\isolated-temp\\3LzsMVJaiAJKj6ozAN180yZ2atH\\Orfeo.exe
...\\isolated-temp\\nsaB9FB.tmp\\7z-out\\Orfeo.exe
```

## Conclusion and scope

Orfeo's single-file Portable launcher **extracts its application payload to TEMP at runtime** and runs the app from the extracted path.

This does not mean Scoop unpacks the downloaded file during `scoop install`. Scoop's manifest still downloads one EXE directly into its managed app directory. The `Orfeo-Data` persistence entry concerns the separate user-data folder beside the portable launcher.

The workflow forcibly stopped the app processes and removed its isolated test directory in its cleanup block. Therefore, this run does **not** establish whether Orfeo automatically removes its temporary extraction after a normal user exit.

## Reproducibility

Workflow: [orfeo-portable-temp-test.yml](../../.github/workflows/orfeo-portable-temp-test.yml)

The workflow runs on changes to itself or `bucket/orfeo.json`, and it can also be started manually with `workflow_dispatch`.
