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
