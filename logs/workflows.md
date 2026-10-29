# Workflow Change Log

This log records the important changes, fixes, and CI results related to the repository workflows.

## 2026-09-29

### README manifest table workflow
- Added automatic generation of the manifest table from `bucket/*.json`.
- Added concurrency protection to reduce simultaneous README update conflicts.
- Changed checkout to track the `master` branch with full history so manifest update dates can be read reliably.
- Added graceful handling for malformed JSON so the README generator can warn and continue while CI remains responsible for manifest validation.

### CI / manifest validation fixes
- Fixed an invalid JSON escape in `bucket/xyplorer.json` that caused the README table workflow to fail during JSON parsing.
- Confirmed that the corrected `xyplorer.json` passes JSON/schema validation.
- Fixed missing final newlines in workflow-related files/manifests when required by repository CI.

### README duplication issue
- The README generator originally updated only the marker contents and left duplicate `## Manifests` sections outside the markers.
- Changed the generator to replace the complete `## Manifests` section between the start and end markers.
- Removed duplicate and empty generated table sections from the README.

### Manifest sorting work
- Added date sorting support:
  - Newest first (default)
  - Oldest first
- Added alphabetical name sorting support:
  - A–Z
  - Z–A
- Iterations that generated multiple visible tables were removed from the final README layout.
- The final design keeps a single visible manifest table and retains sorting links in the table header.
- Separate generated views are stored under `docs/` so the README itself does not contain duplicated full tables.

### Relevant workflow runs
- Run 36639080509 — CI failure caused by `spacedrive.json` validation.
- Run 36643258424 — CI failure caused by missing final newline in `spacedrive.json`; schema validation itself passed.
- Run 36643573924 — CI success after the newline fix.
- Run 36643982015 — README table workflow success.
- Run 36644154237 — README table workflow success.
- Run 36644990100 — README table workflow success.

## 2026-10-08

### UniGetUI manifest and workflow fixes
- Added/updated `bucket/unigetui.json` for UniGetUI `2026.3.1`, matching the official Scoop Extras manifest while keeping UniGetUI data in the normal user AppData location instead of Scoop's `persist` directory.
- Removed `pre_install` creation of `ForceUniGetUIPortable` and removed `persist: "Settings"` so UniGetUI does not run in forced portable mode.
- Fixed CI failure caused by `unigetui.json` missing the required final CRLF newline; the manifest schema itself was valid.
- Fixed a race in `format-manifests.yml` where simultaneous workflow pushes could fail with `fetch first`.
- Updated manifest normalization to fetch/rebase against the latest `master` before pushing.
- Updated CI triggering so normalization can explicitly dispatch a follow-up CI run after it changes manifests.

### Relevant workflow runs
- Run 37833777695 — normalization failed because another workflow had already advanced `master`; push was rejected with `fetch first`.
- Run 37834096226 — CI failed only because `unigetui.json` lacked the required final newline; schema validation passed.
- Run 37834096251 — normalization succeeded for the corrected manifest formatting.
- Run 37835084703 — CI started from the workflow fix commit.
- Run 37835120920 — normalization workflow running with the race-condition fix.
- Run 37835121006 — CI running on commit `986ed518862eb3d8e39ea14654a552aed19af9a8`.

## Current workflow behavior

The manifest-table workflow:
1. Reads all manifests in `bucket/`.
2. Extracts version, description, and last modification date.
3. Generates the README table with the newest updates first.
4. Keeps sorting links for Name and LAST UPDATE.
5. Maintains the generated section using explicit start/end markers.
6. Commits README changes automatically when the generated content changes.

The repository CI remains responsible for validating manifest syntax and schema correctness.

## 2026-10-10

### Manifest archive/path validation
- Added `.github/workflows/validate-manifest-archives.yml` to inspect changed manifests' actual downloadable archives after newline normalization.
- The validator verifies static hashes when available, confirms configured `extract_dir` entries exist, and checks declared `bin` and shortcut paths against the files that remain after extraction.
- Updated `format-manifests.yml` to pass the pre-change commit SHA to the validator after normalization.
- Updated `ci.yml` to start from the `archives-validated` dispatch, so Scoop's standard tests run after archive/path checks succeed rather than in parallel.
- The validator can also be run manually for one manifest by providing a path such as `bucket/winzenith.json`.
- Validation intentionally does not execute downloaded installers or manifest install scripts. Non-archive installers and paths that may be generated by install hooks are reported as unverified warnings.

### Archive validator test results
- Run 38025650597 exposed a checker bug: nested `shortcuts` arrays were flattened and the shortcut label was mistaken for a file path. The validator was fixed to preserve nested arrays.
- Run 38025720619 — archive validation succeeded for `bucket/winzenith.json`: downloaded the v1.3.5 ZIP, verified its SHA-256, and confirmed the declared `bin` and shortcut paths exist in the archive contents; 0 validation failures.
- Run 38025734499 — the official CI matrix passed after the archive validator dispatched it.
- Added a direct-push gate in `ci.yml` so a push containing any `bucket/*.json` change cannot start Scoop tests before archive validation. README/docs/log-only changes are ignored by the direct CI trigger; successful archive validation triggers CI with the `archives-validated` event.
- The archive path filter is case-insensitive so uppercase manifest extensions such as `FoliCon.JSON` are included.

### `format-manifests.yml` dispatch fix
- Fixed the PowerShell dispatch step to avoid the malformed multiline SHA regex that caused earlier workflow runs to fail during workflow parsing before any jobs started.
- Moved GitHub event and commit-message values into environment variables, then validates the base commit SHA in PowerShell using the anchored 40-character hexadecimal pattern.
- Kept a guarded fallback to the parent commit when the push event does not provide a valid base SHA; the step fails explicitly if a valid SHA still cannot be determined.
- Runs 38025532072, 38025537807, 38025539515, and 38025581234 are historical failures from the earlier broken workflow revisions.
- Run 38025708738 — `Normalize manifest newlines` succeeded after the fix.

### CI trigger order and safeguards
- For pushes affecting `bucket/**`, `format-manifests.yml` runs first and normalizes manifest JSON files to exactly one trailing CRLF. It commits and pushes only when normalization changes file contents.
- After normalization, `format-manifests.yml` sends the `manifests-normalized` repository dispatch with the pre-change base SHA to `validate-manifest-archives.yml`.
- The archive validator checks changed manifests' downloadable archives, static hashes, and statically verifiable `extract_dir`, `bin`, and shortcut paths. Only after successful validation does it send the `archives-validated` dispatch that starts `ci.yml`.
- The direct `push` trigger in `ci.yml` ignores `bucket/**` and `.github/workflows/format-manifests.yml` (as well as README, docs, and logs). Its gate also prevents direct-push test jobs from running when changed manifest JSON files have not passed the archive-validation path.
- `Register PSGallery` remains in the CI test job before the dependency-installation and Scoop test steps.
- Run 38025708738 — the normalization workflow succeeded, but reported that manifests already had exactly one CRLF, so this run did not demonstrate a normalization commit.
- Run 38025720619 — archive validation succeeded for `bucket/winzenith.json`, including SHA-256 and declared `bin`/shortcut path checks; the validator dispatched CI after the checks passed.
- Run 38025734499 — both CI matrix jobs (`powershell` and `pwsh`) passed, including `Register PSGallery` and Scoop tests.
- These results verify the formatter workflow, archive validator, and dispatched CI success. They do not, by themselves, establish that one newly modified manifest was pushed and observed completing the entire end-to-end sequence in a single test.

## 2026-10-11

### ALLPlayer manifest and Inno Setup archive validation
- Fixed `bucket/allplayer.json` installation metadata by assigning the downloaded setup a distinct local filename (`ALLPlayer-setup-$version.exe`) so it cannot collide with the extracted `ALLPlayer.exe` application executable.
- Added the static SHA-256 for the current 9.6 installer: `239deb29411cffcc716718ed7fd16a2db7afa7f903c2b1ccc54b8b4bda2d8a65`.
- Added a short manifest comment explaining why the local setup filename differs from the remote filename.
- Updated `.github/workflows/validate-manifest-archives.yml`: it verifies static hashes for Inno Setup EXEs, but skips launch-path inspection when 7-Zip exposes PE sections instead of the files extracted by Scoop's `innounp`. This avoids treating the executable's PE sections as an archive file list; it does not constitute a runtime installation test.
- Run 38107881846 — archive validation passed for `bucket/allplayer.json`: SHA-256 OK, 0 failures; the workflow dispatched CI run 38107896724.
- Earlier runs 38107473777 and 38107600546 failed because the validator tried to infer extracted application paths from 7-Zip's PE-section listing, not because of a checksum mismatch.

## 2026-10-11

### ALLPlayer executable collision fix
- The earlier fix that only changed the local installer filename did not resolve shim creation: Scoop's `bin` still pointed to `ALLPlayer.exe`, which was not present after Inno Setup extraction.
- Updated archive validation to use the same `innounp` extraction style Scoop uses for Inno Setup installers and to report executable architecture and version metadata.
- Confirmed from the actual v9.6.0.0 installer that `ALLPlayer,1.exe` is x64 (22,715,984 bytes), while `ALLPlayer,2.exe` is x86 (17,049,168 bytes). Both report the original filename `ALLPlayer.exe`.
- Updated `bucket/allplayer.json` with a guarded `pre_install` hook that renames the x64 `ALLPlayer,1.exe` to the expected `ALLPlayer.exe` before Scoop creates the shim and shortcut. The hook fails explicitly if the x64 executable is missing or if a target file already exists.
- Run 38109276051 — archive validation succeeded; the installer SHA-256 and innounp helper SHA-256 matched. The validator found both executable architectures and reported 0 failures. Launch-path presence is warned rather than asserted at archive-inspection time because the pre-install hook creates the canonical `ALLPlayer.exe` name.
- Run 38109309430 — CI passed after archive validation; both `powershell` and `pwsh` matrix jobs succeeded, including `Register PSGallery` and Scoop tests.

### ALLPlayer 32-bit `lib` exclusion (latest manifest adjustment)
- Updated `bucket/allplayer.json` in commit `9ed1030cb242e684dd0099f5d13e7792a247b92f`.
- Extended `pre_install` to require the `lib64` directory and remove only the exact `$dir\lib` directory when it exists; `lib64` is intentionally preserved.
- This is a manifest install-hook change; `.github/workflows/ci.yml` and the archive-validation workflow were not changed for this adjustment.
- Validation status: no CI/archive-validation run has yet been confirmed for commit `9ed1030cb242e684dd0099f5d13e7792a247b92f`. The existing archive validator inspects extracted files but deliberately does not execute install hooks, so the new directory cleanup still needs runtime verification.

### ALLPlayer x86 executable cleanup and shortcut icon
- Updated `bucket/allplayer.json` in commit `bb4530a2f270512e00019c9587c40d426978fbf9`.
- Extended `pre_install` to remove `ALLPlayer,2.exe` (the x86 executable) after renaming `ALLPlayer,1.exe` to `ALLPlayer.exe`; the existing cleanup still removes only `lib` and preserves `lib64`.
- Initially configured a single `ALLPlayer.ico` shortcut icon, then corrected the approach in commit `42cb22bf8f4417f03bca0c9cf026cc56eb9e3def` to use the bundled `allplayer-radio,1.ico` instead of generating an icon from the executable.
- The selected ICO is renamed to `ALLPlayer.ico`, its ICO header is validated, and `allplayer-radio,2.ico` is removed so only the selected bundled icon remains. The shortcut points to `ALLPlayer.ico`.
- CI workflow definitions were not changed by these manifest updates. The archive validator does not execute `pre_install`, so successful archive validation alone cannot prove the x86 file is removed or the icon is generated; those actions need runtime verification on Windows. No CI result for the follow-up commit has been confirmed yet.


### ALLPlayer bundled ICO selection correction
- Commit `42cb22bf8f4417f03bca0c9cf026cc56eb9e3def` updates `pre_install` to keep the bundled `allplayer-radio,1.ico` as `ALLPlayer.ico`, remove `allplayer-radio,2.ico`, and validate the ICO header before keeping the shortcut reference.
- The same hook removes `ALLPlayer,2.exe` and `lib`, while requiring and preserving `lib64`.
- No CI run has been confirmed for this latest commit. Archive validation does not execute `pre_install`, so the cleanup and ICO selection need installation-time verification.

## 2026-10-14

### Manifest table category mappings
- Added explicit category mappings in `.github/workflows/manifest-table.yml` for existing manifests that previously fell back to `Other Utilities`.
- Removed eight obsolete category keys that no longer matched a current manifest filename: `crapcheckthis`, `developer-placeholder`, `pdfcraft`, `pdfcraft-exe`, `ram-cleaner-flusher-pro`, `timescribe-portable`, `unigetuiglobal`, and `windhawk-alpha`.
- Kept the original fallback behavior at the user's request: unmapped future manifests are categorized as `Other Utilities`; the workflow does not warn or fail because of a missing category mapping.
- The workflow regenerated `README.md` and the six generated manifest-view files under `docs/`.
- [Manifest-table workflow run 38484025594 — success](https://github.com/kiro5678/kirobucket/actions/runs/38484025594).
- [CI run 38484025576 — success](https://github.com/kiro5678/kirobucket/actions/runs/38484025576).

### Archive validation and Scoop autoupdate validation
- Modified `.github/workflows/validate-manifest-archives.yml` to capture the exact commit SHA being checked and expose it together with the validated manifest paths as step outputs.
- After archive/path validation succeeds, the workflow dispatches `manifests-archives-validated` with the manifest list and validated commit SHA. It retains the existing `archives-validated` dispatch for the regular CI workflow.
- Added `.github/workflows/scoop-autoupdate-validation.yml`. It can run from that dispatch or manually; it checks for `checkver` and `autoupdate`, then tests Scoop's update path against a disposable copy rather than rewriting the repository's manifest.
- The autoupdate workflow can use `-ForceUpdate` when its manual `force_update` input is enabled. A normal `-Update` with no newer upstream version does not prove that the URL/hash update template was exercised, so that case is reported as not exercised.
- Updated `docs/manifest-authoring.md` with this distinction and the safe disposable-copy procedure.
- Relevant archive workflow commits: [dispatch integration](https://github.com/kiro5678/kirobucket/commit/4bffa6b1c83ed8484872bcec28749578628be18c) and [output repair](https://github.com/kiro5678/kirobucket/commit/317ccf3ded611703729358116259c8cb6483e5d9).
- Autoupdate workflow commits: [initial workflow](https://github.com/kiro5678/kirobucket/commit/b4dbec3546c2748f47b96a2d7a6ebdd8acf8f2ee), [PowerShell path/regex repair](https://github.com/kiro5678/kirobucket/commit/548e7aa6d03d7d6724a721fa9a8c69bacefc724c), and [failure-pattern repair](https://github.com/kiro5678/kirobucket/commit/b69b787366c13215430dce9f0f63b8abf08b64d2).
- Two intermediate archive-workflow attempts failed while wiring the output: [run 38441504477](https://github.com/kiro5678/kirobucket/actions/runs/38441504477) and [run 38441685973](https://github.com/kiro5678/kirobucket/actions/runs/38441685973). The workflow file was rebuilt and repaired afterward.
- [CI run 38442021855 — success](https://github.com/kiro5678/kirobucket/actions/runs/38442021855).
- [Scoop checkver validation run 38440879693 — PowerShell 5 and PowerShell 7 jobs passed](https://github.com/kiro5678/kirobucket/actions/runs/38440879693). This checks version detection, not necessarily the complete URL/hash update path.
- **End-to-end caveat:** a successful general CI run does not prove that the archive-validation dispatch triggered and completed an autoupdate check against a real changed manifest. That specific end-to-end run has not yet been confirmed.
- `.github/workflows/ci.yml` and `.github/workflows/scoop-checkver-validation.yml` were not modified by this set of changes.

### Log file location
- Consolidated this record into `logs/workflows.md`, alongside the existing workflow history. The temporary duplicate `docs/workflow-change-log.md` was removed after its information was incorporated here.

### MuMuPlayer manifest
- Added `bucket/mumuplayer.json` for the current international NX-main installer build `1.8.5.5748`, included in the MuMu Player 12 global release `6.8.5` published on 2026-10-13.
- Set the official CDN download URL and the SHA-256 reported for that exact installer by the release mirror: `dd5be7411c9a3ccf78ddaaaea89b295260ceb527713ae66b82d2a82f730919c9`.
- Configured `checkver` to discover the newest `nxmain` asset from `LOVECHEN/mumu-release` global-release metadata; `autoupdate` builds the matching official CDN URL from the detected version and build number.
- Added the explicit `mumuplayer` category mapping as `Emulators & Compatibility` in `.github/workflows/manifest-table.yml`.
- The manifest retains the referenced installer switches, shortcut target, and `configs`/`vms` persistence. The shortcut target is installer-generated and still needs runtime verification; archive validation alone cannot prove it exists after installation.

### Scoop Autoupdate Validation parser correction
- Fixed a PowerShell parser error in `.github/workflows/scoop-autoupdate-validation.yml`: changed `$manifestName:` to `${manifestName}:` so the variable is delimited before the colon.
- Fixed the isolated Scoop checkver invocation to pass the copied manifest's full path as the positional `App` argument. Passing the manifest basename together with `-Dir` caused Scoop to interpret the basename as a directory during parameter validation.
- Changed the invocation again to pass `-App`, `-Update`/`-ForceUpdate`, and `-ThrowError` as explicit named parameters. Passing the switch names inside a string array caused PowerShell to bind `-Update` positionally to `Dir`.
- Run [38495030674](https://github.com/kiro5678/kirobucket/actions/runs/38495030674) failed before running manifest checks because of that parser error; it did not indicate a `mumuplayer` version, URL, or hash failure.
- Expanded the MuMuPlayer release metadata query from 30 to 100 releases so newer non-global tags are less likely to push the latest global release outside the response window.

- Latest verification after the fixes: [Scoop Autoupdate Validation run 38495845346 — success](https://github.com/kiro5678/kirobucket/actions/runs/38495845346), [archive validation run 38495811462 — success](https://github.com/kiro5678/kirobucket/actions/runs/38495811462), and [CI run 38495846052 — success](https://github.com/kiro5678/kirobucket/actions/runs/38495846052).
- The checkver script found the current MuMuPlayer NX asset with no failures. The upstream version already matched the manifest, so `-Update` reported the URL/hash update path as **not exercised**; this run does not prove a future release will automatically refresh the URL and hash.

### MuMuPlayer online installer update
- Replaced the single-engine `NXMAIN` offline installer in `bucket/mumuplayer.json` with the international online installer `MuMu_6.0.2_gw-overseas12_all_1786519314.exe`, SHA-256 `552d4729428664d76dbd2aa2bce64db9ad9a923ac4be3209f3c76064e5aac095`.
- The online installer is a small downloader that retrieves MuMuPlayer's install payload from NetEase; the manifest passes the international channel and silent-install arguments so setup can provision the engine components in one installation.
- Updated `checkver` to locate the newest international online-installer asset, skipping Chinese-only online installer releases, and configured the matching official CDN URL template in `autoupdate`.
- Kept `configs` and `vms` persistence and the existing `MuMuNxMain.exe` shortcut target. The workflow can verify URL/hash and manifest schema, but only a runtime installation test can confirm both engine instances are available and the shortcut launches the intended manager.

### MuMuPlayer manifest split
- Restored `bucket/mumuplayer.json` to the dedicated international NX-main offline installer, build `1.8.5.5748`, with its matching SHA-256 and NX-main release discovery/update template.
- Created `bucket/mumuplayer-online.json` as a separate manifest for the international `gw-overseas12_all` online installer `MuMu_6.0.2_gw-overseas12_all_1786519314.exe`, SHA-256 `552d4729428664d76dbd2aa2bce64db9ad9a923ac4be3209f3c76064e5aac095`. This is a small online downloader, not the multi-hundred-megabyte offline package; it retrieves the installation payload during setup.
- Added the `mumuplayer-online` category mapping as `Emulators & Compatibility` in `.github/workflows/manifest-table.yml`; the README manifest-table workflow will regenerate the manifest views.
- [Archive-validation run 38497203542 — success](https://github.com/kiro5678/kirobucket/actions/runs/38497203542). The validator treated the online `.exe` as an installer rather than an archive, so executable-path inspection was skipped; this does not prove runtime installation behavior.
- [Scoop autoupdate-validation run 38497224351 — success](https://github.com/kiro5678/kirobucket/actions/runs/38497224351). `checkver` found the current asset with no failures, but the URL/hash update path was not exercised because the version matched. The CI run associated with the new split is tracked separately and must be checked for its final result.


### MuMuPlayer Android 15 engine manifest
- Added `bucket/mumuplayer-android15.json` for the international MUMU15 Android 15 engine, version `15.8.5.5750`, from the `win-global-offline-6.8.5` release.
- Set the official CDN URL to `MuMu-setup-mumu15-V15.8.5.5750-overseas-1013104801.exe` and its release-mirror SHA-256 to `cc21f4f886e5a5edcc8ab311cdee80f41fba30d6dfc3d0c28db3885cd455aaec`.
- Declared `mumuplayer` as a dependency because MUMU15 is an engine component that shares the NX-main installation directory; the manifest stages the installer with `/action=install_prepare` and then `/action=commit`, passing `/silent=1`, the matching product version, international channel, and shared install directory.
- Added the manifest to the `Emulators & Compatibility` category in `.github/workflows/manifest-table.yml`; the README table workflow will regenerate the index.
- Added a pre-uninstall hook that launches the engine-specific uninstaller if present. The actual install/uninstall behavior has not been runtime-tested; archive/manifest validation cannot prove the emulator launches or that the engine uninstaller exits silently.
- Source release: https://github.com/LOVECHEN/mumu-release/releases/tag/win-global-offline-6.8.5


### MuMuPlayer NX-main installer failure and correction
- User-provided installation log showed the original `/S` invocation did not create `nx_main\\MuMuNxMain.exe`; Scoop nevertheless continued far enough to report the package as installed, while shortcut creation failed and cleanup complained that root-level `uninstall.exe` did not exist.
- Replaced the single `/S` invocation in `bucket/mumuplayer.json` with the documented two-stage installer orchestration: `/action=install_prepare`, then `/action=commit`, using `/from_orchestrator=1`, `/silent=1`, a shared transaction ID, international channel `gw-overseas12`, and `/auto_run=false`. Product version is derived from the NXMAIN engine version (for example, `1.8.5.5748` maps to product version `6.8.5.0`).
- Removed the assumed root-level `uninstall.exe` deletion. The installer hook now checks that `nx_main\\MuMuNxMain.exe` exists and fails the install explicitly if it does not, preventing another false-success installation.
- Runtime installation has not yet been tested on the user's PC; CI and manifest checks must still complete. Reference for the two-stage installation arguments: https://gist.github.com/TameemS/603686cec857ff1f91e68607e374b0d8 and current international-channel command-line observation: https://tria.ge/260825-xwla1ayakg/behavioral1.


### MuMuPlayer error 10002 follow-up
- User's retry reached `install_prepare` but failed with exit code `10002`. MuMuPlayer's official installation-error guide identifies `10002` as an abnormal/unavailable installation path: https://www.mumuplayer.com/help/win/installation-error-codes.html.
- Changed the NXMAIN installer path argument from the quoted form `/D="...` to the unquoted form `/D=...`, matching the observed MuMuPlayer command line in https://tria.ge/260825-xwla1ayakg/behavioral1.
- The path itself is still Scoop's version directory (`$dir`). This change only fixes the argument formatting; a runtime retry is needed to determine whether MuMuPlayer accepts this Scoop-managed destination.


### MuMuPlayer install-path collision fix
- Follow-up analysis found that Scoop stages the downloaded installer inside `$dir` and the manifest also passed that same directory as the MuMuPlayer install destination. This means the destination contained the setup executable when `install_prepare` began, which is consistent with MuMuPlayer's documented error `10002` for an abnormal installation path.
- Updated `bucket/mumuplayer.json` to copy the installer to a unique temporary folder under `$env:SCOOP\\cache`, remove the staged copy from the target version directory, and run both `install_prepare` and `commit` from the separate staging folder while keeping `/D=$dir` as the target. The staging folder is removed in a `finally` block.
- Added an explicit check that the target directory is empty before installation and retained a post-setup check for `nx_main\\MuMuNxMain.exe` so Scoop cannot report success when the expected program binary is absent.
- This addresses the identified path collision, but actual installation still requires a fresh runtime attempt. The official help identifies error `10002` as an abnormal installation path: https://www.mumuplayer.com/help/win/installation-error-codes.html.

- Follow-up hardening: derive the Scoop root from the manifest's version directory rather than relying on `$env:SCOOP`, so staging remains under the actual Scoop root even when UniGetUI launches an elevated shell with a different environment.


### MuMuPlayer installer cache-path refinement
- Confirmed from Scoop's `lib/download.ps1` that `Invoke-CachedDownload` retains the original download under Scoop's cache path and copies it to the version directory for the manifest's pre-install hook. The user's log line `Loading ... from cache` confirms this behavior on their machine.
- Updated `bucket/mumuplayer.json` to use Scoop's `cache_path` helper to locate the original cached installer by app, version, and exact download URL. It removes only the staged copy from the app version directory before installation, avoiding an unnecessary second copy into another cache subfolder.
- Retained a fallback temporary staging directory for cases where the cache file isn't available (for example, when Scoop cache use is disabled). The target directory is still checked to be empty before MuMuPlayer setup runs.
- References: https://github.com/ScoopInstaller/Scoop/blob/develop/lib/download.ps1 and https://github.com/ScoopInstaller/Scoop/blob/develop/lib/core.ps1.


### MuMuPlayer NXMAIN installer type inspection
- Inspected the exact file referenced by `bucket/mumuplayer.json` in a Windows GitHub Actions runner using Detect It Easy 3.21. The installer was downloaded from the public `LOVECHEN/mumu-release` mirror and its SHA-256 matched the manifest exactly: `dd5be7411c9a3ccf78ddaaaea89b295260ceb527713ae66b82d2a82f730919c9`.
- Detect It Easy reported: `PE32`; compiler `Microsoft Visual C/C++ (19.29.30147) [C]`; installer `Nullsoft Scriptable Install System (27-Feb-2026.cvs) [zlib, solid]`. Thus, the file is an NSIS-based installer, not Inno Setup.
- Authenticode signature status was `Valid`, with signer `Netease Interactive Entertainment Pte. Ltd.`; Windows file metadata identified `MuMuPlayer`, version `1.8.5.5748`.
- Inspection workflow: [run 38522600720 — success](https://github.com/kiro5678/kirobucket/actions/runs/38522600720). The installer was inspected statically and was not executed. The inspection workflow remains in `.github/workflows/inspect-mumuplayer-installer.yml` and can be triggered manually to repeat the static inspection of this pinned installer version.


### MuMuPlayer offline installer orchestration correction
- Reworked `bucket/mumuplayer.json` to install both official international offline payloads from the same global release: NXMAIN `1.8.5.5748` and MUMU15 `15.8.5.5750`. The two assets have independent SHA-256 pins and are both managed by Scoop's URL/hash arrays.
- Changed the pre-install hook to run the observed four-step order with one shared transaction ID and product version `6.8.5.0`: NXMAIN `install_prepare`, MUMU15 `install_prepare`, MUMU15 `commit`, then NXMAIN `commit`, waiting 12 seconds between stages. Both installer files are staged/used from Scoop's cache rather than left in the installation target directory.
- Reworked `checkver` to locate both assets from the same latest `win-global-offline-*` release and emit a composite match string; `autoupdate` uses the corresponding capture groups to refresh both download URLs.
- Source for the four-command sequence: https://gist.github.com/TameemS/603686cec857ff1f91e68607e374b0d8?permalink_comment_id=6135981. This is community documentation, not an official MuMuPlayer command-line reference; the source demonstrates version `6.5.2.0`, so the arguments and sequence must still be validated against the current `6.8.5.0` installers in a runtime test.
- SHA-256 pins were cross-checked against the `win-global-offline-6.8.5` release metadata: NXMAIN `dd5be7411c9a3ccf78ddaaaea89b295260ceb527713ae66b82d2a82f730919c9`; MUMU15 `cc21f4f886e5a5edcc8ab311cdee80f41fba30d6dfc3d0c28db3885cd455aaec`.


### MuMuPlayer engine manifest separation correction
- Corrected `bucket/mumuplayer.json` after the prior change had mistakenly combined both NXMAIN and MUMU15 installer payloads in one manifest. It now downloads and installs only the NXMAIN engine again.
- Kept the two-stage `install_prepare` then `commit` invocation for NXMAIN, with the installer staged outside the target directory and the expected `nx_main\\MuMuNxMain.exe` checked after setup.
- MUMU15 remains a separate add-on manifest at `bucket/mumuplayer-android15.json`, as originally requested. The four-step two-engine sequence from a community guide should not be used to silently make the base manifest install MUMU15 as well.
- The two-engine sequence in the linked Gist is community guidance, not official MuMuPlayer documentation; runtime testing is still required to validate this single-engine install orchestration on current builds.
## 2026-10-15

### TieZ clipboard manager manifest
- Added `bucket/tiez-clipboard.json` for the upstream Windows portable ZIP v0.3.3; the SHA-256 value comes from the official GitHub release asset digest.
- Configured version detection against the official release-assets API and matched only Windows portable ZIP assets, avoiding the separate `mac-v*` release tags.
- Configured `tiez-app.exe` as the launch target and persisted the upstream `data` directory across upgrades.
- Registered `tiez-clipboard` in the `Clipboard & Text` category in `.github/workflows/manifest-table.yml`.
- Changed manifest-table generation to fail when a manifest has no category mapping instead of silently assigning `Other Utilities`. Existing bucket JSON filenames were checked against the current mappings.
- Run 38680645332 initially verified the SHA-256 but failed launch-path validation because the executable was nested under `TieZ_0.3.3-portable/`; added the verified `extract_dir` and its autoupdate template.
- Run 38680967583 — archive validation succeeded: SHA-256 OK, `extract_dir` found, all declared launch paths present, 0 failures.
- Run 38680993286 — Scoop `checkver` validation succeeded. No newer upstream version was available, so the workflow did not exercise URL/hash autoupdate templates; a forced template check remains unverified.
- Run 38680993995 — both Scoop CI matrix jobs (`powershell` and `pwsh`) passed, including `Register PSGallery`.
- Run 38680946022 — README manifest-table workflow succeeded and generated the updated manifest views; the README lists `tiez-clipboard` under `Clipboard & Text`.

### Pulse manifest review and service lifecycle
- The official latest stable release at review time was v1.4.0, published on 2026-10-14. The manifest already had the correct version, download URL, and SHA-256 digest; no newer version was available to bump to.
- Confirmed from the upstream README, installation guide, and packaging source that `Pulse-1.4.0-windows-x64.zip` is a payload archive, not a true portable edition. `Pulse.exe` depends on the `PulseService` Windows service; the official Setup also installs the bundled VC++ runtime and registers/starts the service.
- Corrected `bucket/pulse.json` after verifying the upstream v1.4.0 GUI has an explicit in-app **Repair / Install service** action. A fresh Scoop install no longer registers or starts `PulseService`; the user can install it from Pulse itself. Removed automatic execution of the bundled x64 VC++ redistributable entirely, so Scoop does not trigger UAC for that prerequisite even when it is missing. The hook always removes the extracted `redist` payload; during Scoop updates it only stops/re-registers/starts `PulseService` if the service was already registered for this Scoop installation.
- Improved the post-install `notes` shown by Scoop: if PulseService fails because the runtime is missing, the message now explicitly recommends manual installation of the official Microsoft x64 Redistributable via `https://aka.ms/vc14/vc_redist.x64.exe`; no automatic install or UAC prompt is triggered for it.
- Added safeguards to refuse install/update while `Pulse.exe` is running and to refuse replacing a `PulseService` registered outside this Scoop app directory. Scoop uninstall now refuses to continue while Pulse is running and removes the service only when its registered executable belongs to this Scoop installation.
- Updated the notes to disclose that the ZIP is not truly portable, a fresh Scoop install leaves first-time service registration to Pulse's in-app **Repair / Install service** action, updates refresh an already registered Scoop-managed service, and uninstall removes only that Scoop-managed service. Scoop no longer installs Visual C++ Runtime or requests elevation for it; if it is absent, the user must install the prerequisite separately. Settings/logs remain in `%LOCALAPPDATA%\\Pulse`.
- Updated `docs/manifest-authoring.md` with rules for ZIP payloads that depend on system services or machine-wide prerequisites.
- Run 38685286919 — archive validation passed: SHA-256 matched, `Pulse.exe` bin/shortcut paths existed in the archive, 0 failures.
- Run 38685322488 — targeted Scoop checkver/autoupdate validation succeeded. `checkver` passed, but no newer upstream version was available, so the URL/hash update template was not exercised.
- Run 38685323736 — Scoop CI passed both `powershell` and `pwsh` jobs.
- Run 38685166448 — README manifest-table workflow succeeded; the generated README now lists Pulse 1.4.0 under `System Monitoring & Hardware` with the corrected description.
- Run 38685089644 — repository-wide checkver validation failed on GitHub API rate limits (HTTP 403) during the all-manifest sweep. It logged `pulse.json` as checked but showed no Pulse-specific failure; the targeted validation above reported Pulse checkver success.
- The GitHub workflows validate JSON/schema, archive layout, hashes, checkver, and Scoop tests, but they do not execute UAC prompts or perform a full service install/update/uninstall on a real Windows machine. The lifecycle hooks were checked against upstream's documented `--stop`, `--install-start`, and `--uninstall` commands; end-to-end installation behavior still needs a runtime test on Windows.

## 2026-10-20

### Excavator API rate-limit and MuMuPlayer checkver correction
- [Excavator run 39372547015 — failed](https://github.com/kiro5678/kirobucket/actions/runs/39372547015/job/118463413112). The job logged multiple GitHub REST API `403 rate limit exceeded` responses; the fatal MuMuPlayer checkver script then reported that no international release was found.
- The upstream releases API now uses tags such as `win-6.8.5` rather than the old `win-global-offline-6.8.5` pattern. The current `win-6.8.5` release (published 2026-10-13) contains the expected overseas NX-main and MUMU15 installer assets, so requiring the obsolete tag prefix was brittle.
- Updated the custom checkver scripts in `mumuplayer.json`, `mumuplayer-android15.json`, and `mumuplayer-online.json` to add an optional Bearer authorization header from `GITHUB_TOKEN`, while preserving local use when the variable is absent.
- Updated the NX-main and Android 15 lookups to select the newest release containing the matching international installer asset, independent of the tag name. The online-installer lookup already searched assets across releases; it now also uses the optional authorization header.
- Updated `docs/manifest-authoring.md` with a general rule to authenticate custom GitHub API checkver calls when a workflow token is available and to filter mixed releases by the intended asset.
- Explicitly passed `${{ github.token }}` as `GITHUB_TOKEN` to the repository-wide checkver and targeted autoupdate validation steps; without this environment mapping, the custom manifest scripts would fall back to anonymous API requests inside those validation workflows.
- The upstream release-list was inspected to confirm the current expected assets. This fixes the identified failure path, but the prior failed run has not been re-executed against the new commit; a successful Excavator run is still required to confirm the workflow end to end.

### Checkver failure analysis — LiveWallpaper and LynxOptimizer
- [Manual Scoop Checkver Validation run 39100103135](https://github.com/kiro5678/kirobucket/actions/runs/39100103135/job/117594454652) failed on exactly two manifests; the other 304 passed. `mumuplayer.json`, `mumuplayer-android15.json`, and `mumuplayer-online.json` all passed in this run.
- `livewallpaper.json`: the JSONPath read only `$[0].assets[*].browser_download_url`, but the newest upstream release used the `LiveWallpaper_Installer_v...` filename that the regex did not support. The manifest deliberately targets the newer 4.x `GiantappWallpaper_..._x64-setup.exe` / prior `LiveWallpaper.Installer...` asset family, so expanded JSONPath to all assets across the release list while retaining the existing version and verified URL/hash.
- `lynxoptimizer.json`: `checkver` queried `/releases/latest`, which returned the `PREVIEW-0.280.0` channel, while the manifest URL/autoupdate template intentionally use the mutable `PREVIEW-DEV` tag and version `0.216.2`. Changed the API endpoint to `/releases/tags/PREVIEW-DEV`; verified that it returns name `PREVIEW:0.216.2` and the exact asset/hash already pinned in the manifest.
- Updated `docs/manifest-authoring.md` to require release-channel alignment between `checkver` and autoupdate URLs, and to search across the intended release asset family when upstream uses multiple naming schemes.
- The changes have been committed, but the new repository-wide checkver/CI runs must finish before calling these two fixes fully validated.

### Repository-wide checkver follow-up — 2026-10-20
- [Manual Scoop Checkver Validation run 39388954560](https://github.com/kiro5678/kirobucket/actions/runs/39388954560) confirmed that the two failures from run 39100103135 were corrected: both `livewallpaper` and `lynxoptimizer` passed under pwsh.
- The run still failed on ten other manifests. Eight GitHub-release manifests used URL-fragment regexes such as `tag/v...` even though the current Scoop GitHub API mode applies their regex to the JSON `tag_name` field. Updated the patterns in `adb-device-manager`, `android-dex`, `cooldesk`, `cooldesk-msi`, `ds4windows`, `fluenttweaker`, `mucommander`, and `nightlight-launcher` to match the actual tag value.
- `flow` and `fluentstore` use release channels marked as prereleases, so GitHub's `/releases/latest` endpoint returned 404 even though their published tagged releases and Windows assets exist. Added explicit release-list scripts that select the newest numeric Flow tag with the Windows x64 ZIP and the newest FluentStore beta tag with the x64 installer. Verified Flow v0.7.0 and FluentStore v0.4.0-beta assets exist in upstream release metadata.
- Corrected the Flow description to reflect the current upstream application (calendar/event/time management rather than flowcharts).
- Updated the manifest-authoring rules to document JSON `tag_name` matching and handling of projects that publish only prereleases. These changes are intended to clear the ten newly surfaced failures; the next full checkver run must confirm the result.

### HelixNotes checkver fallback — 2026-10-20
- [Manual Scoop Checkver Validation run 39390145242](https://github.com/kiro5678/kirobucket/actions/runs/39390145242) showed that the Windows PowerShell job passed all manifests but the pwsh job failed only on `helixnotes.json`; Scoop reported the GitLab API permalink URL as invalid (404). The earlier run `39387739358` used commit `28484002`, before the subsequent fixes to other checkver manifests.
- The official [HelixNotes homepage](https://helixnotes.com/) currently displays `Latest release v1.3.6`, matching the existing manifest version and download URL. Switched `checkver` to the homepage and a regex for that release label, avoiding the GitLab API endpoint that failed under pwsh.
- Updated `docs/manifest-authoring.md` with guidance on using an official homepage release label as a fallback when the upstream API is unreliable, and validating the captured version.
- A repository-wide checkver workflow was triggered by this documentation update; it must finish successfully in both PowerShell and pwsh before the fix is considered validated. The pinned version, installer URL and hash were otherwise left unchanged.


### Repository-wide checkver — API rate-limit failures on five manifests
- [Validation run 39469049101](https://github.com/kiro5678/kirobucket/actions/runs/39469049101) checked 306 manifests. Windows PowerShell passed, and the pwsh job failed on `spotlight-dimmer.json`, `sucrose-nightly.json`, `tiez-clipboard.json`, `tiro-notes.json`, and `translumo.json`.
- The five errors were all GitHub REST API HTTP 403 rate-limit responses from URL-based `checkver` requests. The workflow already passed `GITHUB_TOKEN`, but Scoop's built-in URL/JSONPath path did not attach it to those requests. The errors therefore did not establish that releases were missing.
- Converted those five manifests to custom `checkver.script` lookups that send `Authorization: Bearer $env:GITHUB_TOKEN` when available and retain an anonymous fallback for local use. The scripts preserve each intended release channel: Windows-tagged Spotlight Dimmer releases, Sucrose pre-releases, TieZ portable Windows ZIP assets, Tiro Notes releases with the Windows x64 ZIP, and Translumo's latest release tag.
- Added a rule to `docs/manifest-authoring.md` explaining that built-in `checkver.url`/JSONPath requests do not automatically use the workflow token and that HTTP 403 rate limits should be fixed as authentication problems, not treated as missing releases.
- Validation status: these changes have been committed and need a fresh repository-wide run in both PowerShell and pwsh to confirm that the five checks and the full sweep pass.


### Follow-up to repository-wide checkver run 39469049101 — 2026-10-20
- [Follow-up run 39471485084](https://github.com/kiro5678/kirobucket/actions/runs/39471485084) confirmed that the five manifest-specific API scripts now use the token, but exposed a broader rate-limit issue: native GitHub API URLs in Scoop's built-in `checkver.url` path do not send `GITHUB_TOKEN`. The pwsh job therefore logged HTTP 403 failures for 19 other API-backed manifests, while the Windows PowerShell job's only failure was `biniware-run.json`.
- Updated `.github/workflows/scoop-checkver-validation.yml` to patch the temporary Scoop checkout's `bin/checkver.ps1` during CI so requests to `api.github.com` receive the supplied Bearer token. This is an ephemeral CI-only change; it does not modify Scoop upstream or the repository's manifests beyond their intended version-detection configuration.
- Updated `bucket/biniware-run.json` to match the current official page's raw HTML. The previous `Current version[^\\d]*...` pattern stopped at digits in HTML attributes before reaching the displayed version. The replacement is bounded and non-greedy; version `7.9.0.0`, the existing download URL, and hash remain unchanged. The official page currently lists Biniware Run 7.9.0.0 and the same SHA-256 pinned in the manifest.
- Updated `docs/manifest-authoring.md` to document the workflow's API authentication shim and safe raw-HTML version matching.
- A separate archive validation job, [run 39471473484](https://github.com/kiro5678/kirobucket/actions/runs/39471473484), failed on `sucrose-nightly.json`: its existing 7z asset contained a Sucrose Bundle setup executable, while the manifest declares `Sucrose.Launcher/Sucrose.Launcher.exe` as if the archive held the application files. The current URL/hash were not changed by the checkver fix. This is a separate packaging/install-layout issue; it is not an API authentication or version-detection failure and remains to be reviewed independently.
- Validation status: a new full checkver run is required to confirm both shell jobs after the workflow authentication and Biniware regex fixes.


### Sucrose stable/nightly installer payload correction — 2026-10-20
- [Archive validation run 39471473484](https://github.com/kiro5678/kirobucket/actions/runs/39471473484) showed that `sucrose-nightly.json` downloaded a file ending in `.7z` whose actual contents were the Sucrose Bundle setup executable, not the extracted application. The declared in-Scoop `Sucrose.Launcher` path therefore could not exist.
- Checked the [official Sucrose Installation guide](https://github.com/Taiizor/Sucrose/wiki/Installation): it describes Sucrose as a self-extracting per-user Bundle installer, specifies that package managers run the release `.exe` with `/s`, and documents the install path as `%LOCALAPPDATA%\\Sucrose`.
- Updated both `sucrose.json` and `sucrose-nightly.json` to use the corresponding official setup `.exe` assets and verified SHA-256 digests, run each architecture's installer silently using `/s`, and call the official HKCU uninstall entry during Scoop uninstall. Removed invalid `bin` and shortcut targets that incorrectly assumed the application files were extracted inside the Scoop version directory. Updated autoupdate URLs to the official installer filenames.
- The stable manifest is pinned to the official stable release v26.7.5.0. The nightly manifest remains on the latest prerelease v26.10.5.0; its `checkver` now selects prerelease releases containing the x64 Bundle installer, rather than only relying on a numeric tag.
- Both manifests now explicitly note that the official installer installs to the user's profile and that stable and nightly manifests share the same per-user path, so they are not side-by-side installations.
- Updated the authoring rules to warn that a `.7z` extension alone does not prove the payload is a portable archive or match the paths declared in a manifest.
- The manifest/schema and archive validation workflows must complete against this correction before calling it fully verified; the installer was not run interactively on a user's PC.
## 2026-10-24

### UniGetUI global-data manifest
- Renamed `bucket/unigetui.json` to `bucket/unigetuiglobal.json` to distinguish regular per-user data storage from the separate portable manifest.
- Removed the post-install migration of existing `Settings` contents from prior UniGetUI Scoop locations; installation no longer copies legacy settings into `%LOCALAPPDATA%\UniGetUI`. The hook only removes `ForceUniGetUIPortable` so UniGetUI uses its normal per-user data directory.
- Removed `ForceUniGetUIPortable` from the installed ZIP so UniGetUI uses its normal per-user data directory instead of storing active configuration and caches inside Scoop.
- Kept `bucket/unigetui-portable.json` as the separate portable variant and updated the manifest category mapping and category documentation.

## 2026-10-29

### Merge and checkver workflow reconciliation — PR #33 and PR #32

- Merged [PR #33 — Fix checkver detection for affected manifests](https://github.com/kiro5678/kirobucket/pull/33) into `master` first. Merge commit: [`9af68b6`](https://github.com/kiro5678/kirobucket/commit/9af68b63fdfa8f3b8353892d36592078695a82bf).
- Merged [PR #32 — Add categorized manifests from Neuber, Aurelitec, ComputerSluggish, Funk.eu and LopeSoft](https://github.com/kiro5678/kirobucket/pull/32) afterward. Merge commit: [`b1cfaf4`](https://github.com/kiro5678/kirobucket/commit/b1cfaf4ec4ba5af56b03b91a2ed040ed32d46b72).
- Reconciled `.github/workflows/scoop-checkver-validation.yml` after the branch conflict. Push-triggered runs validate only manifests changed by that push; manual full-bucket validation requires the optional repository Actions secret `CHECKVER_GITHUB_TOKEN`.
- Kept the checkver exemption limited to `bucket/kvrt.json`. Failures in any other manifest are recorded as failures and cause the workflow to exit with code 1.
- Updated `docs/manifest-authoring.md` to document use of `CHECKVER_GITHUB_TOKEN` for authenticated requests to unrelated public GitHub repositories, while preserving the existing regex, timeout/retry, and validation guidance.
- Follow-up commits: [workflow reconciliation](https://github.com/kiro5678/kirobucket/commit/3a72558553c33e87be95f9f0e7576b8ba8ed76a0) and [authoring guidance](https://github.com/kiro5678/kirobucket/commit/d2586144c385dcc69100fa40940a7e0d8c90ab43).
- Verification performed: fetched the workflow and authoring guide from `master` and confirmed the optional-token handling, changed-manifest selection, KVRT-only exception, and failure behavior are present.
- CI status: no post-change run result was available during this verification, so the changes are committed and inspected but are not recorded as CI-passing.

### muCommander nightly checkver — transient 404 and mutable release version

- Investigated [checkver validation run 40860770065, job 123403114234](https://github.com/kiro5678/kirobucket/actions/runs/40860770065/job/123403114234). The only non-KVRT manifest failure was `bucket/mucommander-nightly.json`: the API endpoint `/repos/mucommander/mucommander/releases/tags/nightly` returned `404 Not Found`.
- Inspected the upstream [nightly workflow](https://github.com/mucommander/mucommander/blob/master/.github/workflows/nightly.yml). It deletes the previous `nightly` release/tag before rebuilding and uploading replacement assets, so the official API can temporarily have no release at that tag.
- Backed up the prior manifest to [`logs/manifests/mucommander-nightly-1.6.3-2026-10-29.json`](https://github.com/kiro5678/kirobucket/blob/master/logs/manifests/mucommander-nightly-1.6.3-2026-10-29.json).
- Replaced the URL/JSONPath-only version lookup with a PowerShell `checkver.script` that retries the official release endpoint up to 20 times with a 15-second delay, optionally authenticates with `GITHUB_TOKEN`, verifies the `nightly` tag and the expected x86_64 portable ZIP, and extracts both the app version and source commit from the official release metadata.
- The script emits the app version and seven-character commit separated by `|`; `checkver.replace` makes the Scoop version include both, so republished nightly builds can trigger updates even when the semantic app version is unchanged. The `autoupdate.url` uses `$matchVersion` to keep the filename aligned with the upstream asset's app version.
- Updated `docs/manifest-authoring.md` with the bounded-retry rule for nightly releases that are deleted and recreated during builds, and retained the requirement to fail clearly if the official source remains unavailable.
- Verification status: the updated manifest, backup, documentation, and log were committed and read back from `master`. The official nightly release API still returned `404`. Archive validation run [40885487833](https://github.com/kiro5678/kirobucket/actions/runs/40885487833) also failed because the official portable ZIP URL returned `404`; this confirms the asset itself was unavailable, not merely the API lookup. Checkver run [40885436217](https://github.com/kiro5678/kirobucket/actions/runs/40885436217) was still in progress at the last status check. Do not consider the fix end-to-end verified until the upstream nightly release and asset are available and both checkver shell jobs plus archive validation pass. The script intentionally fails after its bounded retry window rather than skipping the manifest or fabricating a version.

