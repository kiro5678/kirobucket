# Purge, FoxDesktop and Whispra package review — 2026-11-10

## Scope

Reviewed the upstream projects and Windows release assets for Purge, FoxDesktop and Whispra. Used the repository's Windows GitHub Actions workflows to download, hash, list and extract the actual packages. This record distinguishes archive validation from a full Scoop install/update/uninstall or GUI launch test.

## Confirmed package findings

### Purge 1.0.11

- Upstream: https://github.com/stvekoulo/purge
- Official release ZIPs and SHA-256:
  - x64: `Purge-1.0.11-win-x64.zip` — `0cb987c885b1b7ead9eaf55056584bd4deb7fc4073b37824c48ee65d2757bc94`
  - ARM64: `Purge-1.0.11-win-arm64.zip` — `1c868f95ef1e1d23698d3d7657e02a506edab45484730bcd96a7a295f1e5dc4c`
  - x86: `Purge-1.0.11-win-x86.zip` — `d81023d4fb91fbaec3c42d01a4d63db961dafd9efed026a8422d92d08a22db9e`
- Source inspection confirms a self-contained WinUI 3/.NET 10 app, MIT license, and `Purge.exe` at the root of all architecture payloads. The upstream installer uses Inno Setup and creates a Start Menu shortcut. Optional app settings can create a per-user startup registry value and a scheduled cleanup task.
- User settings, history, crash logs and update downloads live under `%LOCALAPPDATA%\\Purge`, outside Scoop's version directory.
- The manifest at `bucket/purge.json` is an active PR candidate only. Its uninstall hook calls `Purge.exe --uninstall-cleanup` only when `$cmd -eq 'uninstall'`, which removes the app's startup/task integration while preserving local data. The hook intentionally skips cleanup during Scoop upgrades.
- The app's own update installer launches the vendor Inno Setup package and targets the current install directory. The manifest notes that Scoop should be used for updates; the app's update check itself was not disabled.

### FoxDesktop 2.0.1

- User-supplied direct URL: https://foxdesktop-app.com/download
- Downloaded package SHA-256: `70cdad4a678d453364ab8cdfd3514708a5c1e79952781052106b47de27c796aa`
- File metadata reported ProductName `FoxDesktop`, FileDescription `FoxDesktop Setup`, version `2.0.1`. Authenticode status was `NotSigned`.
- Detect-It-Easy identified an Inno Setup module. The 32-bit installer stub does not establish the architecture of the installed application.
- Using the pinned `innounp` helper, the workflow extracted 491 files from the Inno `{app}` payload and found `DesktopApp.exe` plus `createdump.exe`.
- No verified public source repository or complete install/uninstall behavior has been established. Keep this as a review-only candidate at `under review scoop bucket/foxdesktop.json`; do not publish an active manifest or label it portable yet.

### Whispra 2.5.0

- Upstream distribution repository: https://github.com/Sxriptor/Whispra-Download
- Official installer URL: https://github.com/Sxriptor/Whispra-Download/releases/download/2.5.0/whispra-setup.exe
- SHA-256: `3510c4a19c557b98f8b20b22a882cb68de4db2b7852477d5de01fcd0a8cc030f`
- The upstream repository distributes the app but does not provide its source code. README describes a proprietary Windows 10/11 64-bit app requiring sign-in.
- The workflow extracted the outer installer and then the nested `$PLUGINSDIR\\app-64.7z` payload. The primary executable `Whispra.exe` was found at the root of that nested payload; a helper executable `Uninstall Whispra.exe` was also found in the outer installer extraction.
- The Scoop install/uninstall switches, user-data locations and update behavior remain unverified. Keep `under review scoop bucket/whispra.json` as a temporary candidate only.

## Workflow defects found and fixed

1. The review inspector originally selected the Inno Setup extraction path only when the download URL ended in `.exe`. FoxDesktop's direct endpoint is `/download`, so the workflow tried 7-Zip instead. The confirmed Inno type is now selected from the explicit `innosetup: true` manifest metadata, independently of the URL suffix.
2. A PowerShell line used `"$appName: ..."`. PowerShell parsed the colon as part of variable/scope syntax and failed before package inspection. Changed it to `"${appName}: ..."`.
3. Added `bucket/purge.json` to both push and pull-request path filters of `.github/workflows/validate-manifest-archives.yml`, so the archive path validator actually tests the new manifest.

## Verification evidence

- Review Manifest Installer and Archive Inspector run #41: https://github.com/kiro5678/kirobucket/actions/runs/42860925207 — succeeded; verified downloads and hashes, FoxDesktop Inno payload, Whispra nested application payload, and Purge packages. Blocking errors: 0.
- Validate manifest archives run #670: https://github.com/kiro5678/kirobucket/actions/runs/42862206849 — succeeded; validated 17 manifests including Purge. Purge x64, ARM64 and x86 SHA-256 values matched; declared `Purge.exe` shortcut path was found in each archive. Failures: 0. The existing Pake MSI regression set also passed.
- Validate GitHub Actions Workflows run #329: https://github.com/kiro5678/kirobucket/actions/runs/42862206907 — succeeded; workflow files passed the repository's actionlint check.
- Review Manifest Installer and Archive Inspector run #43: https://github.com/kiro5678/kirobucket/actions/runs/42862206608 — succeeded; repeated extraction after the inspector fixes. FoxDesktop: Inno extraction passed (491 files; `DesktopApp.exe`). Whispra: outer and nested archive extraction passed (`Whispra.exe`). Purge and the temporary x86 probe also passed in this run.

## Verification limits and next gate

- These are download, digest, archive extraction and manifest archive-path checks. They are not a live Scoop install, GUI launch, upgrade or uninstall cycle.
- The branch's archive validator and workflow lint are verified. Checkver/autoupdate and the broader Manifest Pipeline run on pushes to `master`; they have not been evidenced for this PR branch.
- Purge is the only program promoted to an actual `bucket/` manifest candidate. FoxDesktop and Whispra remain in `under review scoop bucket/` pending installation behavior and uninstaller/update investigation.
- PR #106 remains open and unmerged at the time this record was written.
