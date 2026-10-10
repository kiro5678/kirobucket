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

