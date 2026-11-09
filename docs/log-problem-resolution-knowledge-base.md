# Repository Problem Resolution Knowledge Base and Workflow Change Log

This is the repository-wide maintenance record for technical problems, resolutions, workflow changes, and CI validation history encountered while maintaining `kirobucket`.

## Mandatory rule

Whenever a real problem is encountered in this repository, investigate it to an evidence-supported cause and apply a fix. **After the problem has been resolved, add an entry to this file in the same task.** Do not finish the task with a fix that exists only in chat, a commit message, or an unrecorded workflow run.

This rule applies to all repository work, not only Scoop manifests. Examples include manifests, Scoop behavior, PowerShell scripts, GitHub Actions, CI validation, release/download handling, documentation generation, repository structure, and maintenance tooling.

Before investigating a recurring or previously seen problem, search this knowledge base and reuse the recorded findings where they still apply. Update an existing entry when new evidence changes the cause, fix, or verification procedure; do not create duplicate entries for the same underlying issue.

## Required incident record

Each resolved issue must record:

1. **Date** — the date the issue was resolved (YYYY-MM-DD).
2. **Problem and symptoms** — what failed, the exact error or incorrect behavior, and the affected file, manifest, workflow, or component.
3. **Root cause** — the cause established by investigation. Distinguish confirmed facts from hypotheses; never present an assumption as a confirmed cause.
4. **Resolution** — the exact change or steps that fixed the problem, including relevant file paths and settings.
5. **Verification** — the checks actually performed and their results. Link to the relevant GitHub Actions run, commit, issue, release, or other evidence when available.
6. **Prevention / regression check** — the rule, test, validation, or monitoring step that prevents recurrence.
7. **Status** — use **Resolved and verified** only when the fix has been tested or independently confirmed. If verification is incomplete, say so explicitly and do not label the issue verified.

Do not claim that an entire workflow, manifest, installation, or batch passed when only one stage or a partial sample was checked. Record the exact scope of successful and unsuccessful checks.

## Incident entry template

Copy this template for every newly resolved issue and fill in the evidence-based details:

### YYYY-MM-DD — Short problem title

- **Status:** Resolved and verified / Resolved, verification pending
- **Affected area:** `path/to/file`, manifest name, workflow, or component
- **Problem:** Observable failure and relevant error/output.
- **Root cause:** Confirmed cause; explicitly mark any remaining uncertainty.
- **Resolution:** Exact change made and why it addresses the cause.
- **Verification:** Commands, tests, workflow run links, commit links, and precise results. State what was not tested.
- **Prevention:** New or updated rule, automated check, or procedure that prevents recurrence.

## Documentation and evidence rules

- Add the entry **after** resolving the problem and confirming the fix; do not wait for a later cleanup task.
- Keep entries concise but reproducible. Include exact paths, command names, workflow names, and relevant version details.
- Prefer links to immutable commit SHAs and specific GitHub Actions runs over links to moving branch pages.
- Preserve useful error text, but remove credentials, tokens, private URLs, personal paths, and other secrets.
- If several symptoms share one confirmed root cause, document them in one incident. If apparently similar failures have different causes, document them separately.
- If the cause is still unknown or the fix is not verified, do not invent a resolution. Record the limitation in the relevant task or issue and add the knowledge-base entry once the cause and fix are established.
- When a new incident exposes a general repository rule, update the relevant permanent guide (for example, `docs/manifest-authoring.md`) as well as adding the incident entry here.

## Resolved incidents

### 2026-11-10 — Promote the successful Pake Desktop extraction manifest

- **Status:** Resolved, repository validation pending.
- **Affected area:** `bucket/pake-desktop.json`, removed `bucket/pake-desktop-extracted-test.json`, `docs/categories.md`, and `docs/manifest-portability.md`.
- **Problem:** The canonical Pake Desktop manifest ran the official Velopack setup, which could fail during Scoop reinstall because the running setup process held the version directory that Velopack needed to replace. A separate extraction-only manifest had succeeded in the user's installation test but remained named as an experimental package.
- **Root cause:** The setup program performs an in-place Velopack installation/update operation. The embedded `lib\\app` application payload can instead be extracted without running that setup process.
- **Resolution:** Replaced the canonical manifest with the tested 7-Zip payload-extraction definition, retained the verified x64 download hash and real `Pake.exe` launch path, renamed the Start Menu shortcut to `Pake Desktop`, and removed the duplicate experimental manifest. ARM64 was intentionally omitted because only x64 extraction/install was tested. The manifest notes that Velopack self-updating is unavailable and Scoop must manage updates.
- **Verification:** The user explicitly confirmed that installation with the extraction-only manifest succeeded. Repository PR checks and post-merge workflow results remain pending; no broader claim about a separate ARM64 test or GUI regression suite is made here.
- **Prevention:** When a setup process must replace its own Scoop version directory, do not launch it from within that directory. Verify any embedded archive independently, confirm the extracted `extract_dir` and executable path, and promote an extraction-based manifest only for the architectures actually tested.


### 2026-11-09 — Fix Scoop schema validation for hop, HatchZip, and Prime Files

- **Status:** Resolved and verified.
- **Affected area:** `bucket/hop.json`, `bucket/hatchzip.json`, `bucket/prime-files.json`; PRs [#70](https://github.com/kiro5678/kirobucket/pull/70) and [#71](https://github.com/kiro5678/kirobucket/pull/71).
- **Problem:** The first PR validation for these three manifests reported `Invalid JSON` for every file even though each file parsed as JSON. The failure was in Scoop's manifest-schema validation, not JSON syntax parsing.
- **Root cause:** Scoop's schema rejects unresolved variables such as `$version` in the base `url` field; that variable belongs in `autoupdate.url` templates only. The schema also does not accept the compound license expression `MIT OR Apache-2.0` as a single license identifier.
- **Resolution:** Replaced each base download URL with the verified, fixed URL for its current upstream release while retaining `$version` in the corresponding `autoupdate.url`. Changed HatchZip's `license` field to the supported `MIT` identifier and recorded its dual MIT/Apache-2.0 licensing and bundled license files in `notes`.
- **Verification:** The initial failure is recorded in [Pull Requests run 42534886128](https://github.com/kiro5678/kirobucket/actions/runs/42534886128). After the fixes, [Pull Requests run 42535098948](https://github.com/kiro5678/kirobucket/actions/runs/42535098948) completed successfully. Its log reports `Lint: True`, `Hashes: True`, `Checkver: True`, `Autoupdate: True`, and `Autoupdate Hash Extraction: True` for all three manifests. Separate manual validation on the same upstream releases also passed checkver ([42534954986](https://github.com/kiro5678/kirobucket/actions/runs/42534954986)), archive download/hash/path checks ([42535003763](https://github.com/kiro5678/kirobucket/actions/runs/42535003763)), and autoupdate ([42535037096](https://github.com/kiro5678/kirobucket/actions/runs/42535037096)). These checks do not constitute a live GUI launch or a full install/uninstall test. The post-merge Manifest Pipeline for commit `277ab93643bf2d15b9982cee94177dda34c99075` was queued behind an older unrelated pipeline at the time of this entry.
- **Prevention:** Keep the current-release `url` literal and version-specific; use `$version` only in `autoupdate.url`. Use one license identifier accepted by Scoop's schema and document additional license options in a note. Treat the PR's JSON Schema result as distinct from a basic JSON parse.


### 2026-11-05 — Keep missing category mappings non-blocking

- **Status:** Implemented; workflow verification pending.
- **Affected area:** `.github/workflows/manifest-table.yml`; `docs/manifest-authoring.md`.
- **Problem:** A strict validation change made the documentation generator fail when a bucket manifest had no functional category mapping. That is not the required behavior for this repository.
- **Resolution:** Keep `docs/categories.md` as the category source of truth, but treat missing mappings as non-blocking: issue a warning and assign the manifest to `Other Utilities`. Stale mappings also produce a warning and are ignored. Do not throw or stop the workflow for either condition.
- **Prevention:** Missing classifications must always fall back to `Other Utilities`; the documentation generator must continue to completion.


### 2026-11-05 — Eliminate 407 missing-category warnings in manifest documentation generation

- **Status:** Resolved and verified.
- **Affected area:** `.github/workflows/manifest-table.yml`; `docs/categories.md`; generated manifest views; `docs/manifest-authoring.md`.
- **Problem:** `Update Manifest Documentation` completed successfully but emitted 407 warnings of the form `No category mapping for '<manifest>'; using 'Other Utilities'.` This silently put many manifests in the wrong generated category. The existing hard-coded `$categoryMap` had drifted from the functional categories already maintained in `docs/categories.md`. The bucket also contains `FoliCon.JSON` with an uppercase extension, which the old Linux `Get-ChildItem -Filter *.json` enumeration could miss.
- **Root cause:** Two independent sources of category data were maintained: a large static PowerShell hashtable and the functional-category tables in `docs/categories.md`. They had diverged. In addition, extension matching was case-sensitive on the Ubuntu generator runner.
- **Resolution:** Removed the static category list and made `docs/categories.md` the single source of truth. The workflow now parses only the functional-category sections (not publisher cross-lists), enumerates `.json` filenames case-insensitively, and fails on either missing category mappings or stale mappings instead of silently falling back to `Other Utilities`. Added the six missing functional-category rows for `ghost-saver`, `majorprivacy`, `matrixcode`, `matrixrain`, `rayburst`, and `vcredist`; corrected the functional category counts and total to 886. The existing `FoliCon.JSON` row is now included by case-insensitive extension handling. Also documented the source-of-truth rule in `docs/manifest-authoring.md`.
- **Verification:** [Workflow lint run 42016219972](https://github.com/kiro5678/kirobucket/actions/runs/42016219972) passed. [Manifest documentation generation run 42016220005](https://github.com/kiro5678/kirobucket/actions/runs/42016220005) completed successfully. Its log states `Loaded 886 functional category mappings for 886 bucket manifests from docs/categories.md` and `Generated installer-type inventory for 886 manifests across 19 installer types.` The completed log contains **zero** `No category mapping` warnings, **zero** other `WARNING:` lines, and **zero** error lines. The generated views were committed at [6d97e1e](https://github.com/kiro5678/kirobucket/commit/6d97e1e68a35f96f8d8991d68fed01677534a0bb). Final `docs/categories.md` reports 886 unique functional manifests.
- **Prevention:** Keep functional manifest categories in `docs/categories.md` only. The generator validates one-to-one coverage against all JSON files in `bucket/`, including uppercase extensions. Do not reintroduce a separately maintained category hashtable or a silent fallback category. Publisher-suite lists remain cross-lists and do not replace each manifest's functional category.


### 2026-11-05 — Correct Detect It Easy 4.0.0 archive layout

- **Status:** Resolved and verified.
- **Affected area:** `bucket/detect-it-easy.json`.
- **Problem:** After updating Detect It Easy to release 4.0.0, archive validation failed with `extract_dir 'die' does not exist in the archive`. The 4.0.0 release also replaced the older `die_win64_portable_4.0.0_x64.zip` / `die_win32_portable_4.0.0_x86.zip` asset names with `die_win64_4.0.0.zip` and `die_win32_4.0.0.zip`.
- **Root cause:** The updated ZIP files contain the application files directly at the archive root; there is no top-level `die/` directory. The previous `extract_dir` value was stale and would cause Scoop to look for a path that is not present.
- **Resolution:** Updated both architecture URLs, SHA-256 hashes, and their `autoupdate.url` templates to the official 4.0.0 asset names. Removed `extract_dir: "die"` so Scoop extracts the archive root directly into the version directory. Kept the declared `die.exe`, `diec.exe`, and `diel.exe` launch paths unchanged.
- **Verification:** [Archive validation run 42007599251](https://github.com/kiro5678/kirobucket/actions/runs/42007599251) passed with zero failures. It downloaded the x64 and x86 archives, verified both SHA-256 hashes, and confirmed that all declared `bin` and shortcut paths exist in both archives. Commit: [0c0733e](https://github.com/kiro5678/kirobucket/commit/0c0733e9257aec5ebc5feb53a89ec578894e6d33). The workflow validates archive contents and launch paths; it does not launch the application.
- **Prevention:** Never infer `extract_dir` from a product name or a previous release. Inspect the current archive for every architecture. Use `extract_dir` only when the exact directory exists; omit it when files are already at the archive root. Keep the archive-path validator in the manifest pipeline.


### 2026-10-31 — Use Deskboard's official Windows updater metadata for checkver

- **Status:** Resolved and verified.
- **Affected area:** `bucket/deskboard.json`.
- **Problem:** Checkver failed when the manifest attempted to scrape the filename or version label from `https://deskboard.geeke.app/download`. Both direct page matching and a browser User-Agent request failed on GitHub Actions; the runner received HTML that did not expose the dynamic Windows release details or a parseable version label.
- **Root cause:** The official download page is not a reliable raw-HTML version source for automated clients. The Windows release metadata is published separately at `https://deskboard.geeke.app/downloads/windows/latest.json`, which exposes `version` and `platforms.windows-x86_64.url`.
- **Resolution:** Replaced the page-scraping script with native Scoop `checkver.url` + `jsonpath: "$.version"` and a regex that strips the upstream `v` prefix while capturing the semantic version. Kept the Windows installer URL template aligned with the official filename pattern `Deskboard_$version_x64-setup.exe`; no unsupported `autoupdate.hash` field was added.
- **Verification:** [Checkver run 41230903787](https://github.com/kiro5678/kirobucket/actions/runs/41230903787) passed for both Windows PowerShell and PowerShell 7. [Archive validation run 41230954671](https://github.com/kiro5678/kirobucket/actions/runs/41230954671) verified the downloaded asset's SHA-256 and confirmed every declared `bin`/shortcut path exists in the extracted archive. [Autoupdate validation run 41230985680](https://github.com/kiro5678/kirobucket/actions/runs/41230985680) passed with `ForceUpdate`, resolving the URL to `Deskboard_0.13.0_x64-setup.exe` and exercising the download/hash update path. [CI run 41231026348](https://github.com/kiro5678/kirobucket/actions/runs/41231026348) passed in both PowerShell editions.
- **Prevention:** For applications whose web download page is dynamically rendered, inspect the official platform-specific updater metadata before authoring `checkver`. Prefer stable JSON fields and validate that the selected version belongs to the intended platform. Do not rely on search-engine snippets or infer a release version from a hard-coded URL.


### 2026-10-31 — Fix automatic Deskboard installer inspection checkout

- **Status:** Resolved and verified.
- **Affected area:** `.github/workflows/multi-engine-installer-type-inspector.yml`; `under review scoop bucket/deskboard.json`.
- **Problem:** The first push-triggered inspection run failed with `The automatic Deskboard inspection could not find its review manifest.`
- **Root cause:** The inspector originally supported manual URL input and did not check out the repository. The new push-triggered path attempted to read the review manifest from `GITHUB_WORKSPACE` before a checkout existed.
- **Resolution:** Added a pinned `actions/checkout` step before reading repository files. The push trigger is scoped to the Deskboard review manifest and the inspector workflow file; when no manual URL is supplied, the workflow reads the manifest's `url` field.
- **Verification:** [Inspector run 41229404592](https://github.com/kiro5678/kirobucket/actions/runs/41229404592) completed successfully. The file was downloaded and its SHA-256 was calculated as `0812aa7a5667c4820a0c30d72afb72939e5c74c4f251580c41c4cd71c9287ebc`. Detect It Easy 3.21 identified `Nullsoft Scriptable Install System 3.11 [lzma, solid]` with scan exit code 0. [NSIS extraction run 41229492201](https://github.com/kiro5678/kirobucket/actions/runs/41229492201) also completed successfully: 7-Zip listed and extracted the NSIS payload and found `deskboard.exe` plus `uninstall.exe`. Neither workflow executed the installer or application.
- **Prevention:** Any GitHub Actions step that reads files from the checked-out repository must run after an explicit checkout step. Keep static inspection and extraction tests separate from executing installers.


### 2026-10-31 — Repair duplicated and corrupted manifest authoring guide and merge portability rules

- **Status:** Fixed; documentation update verified.
- **Affected files:** `docs/manifest-authoring.md`, `docs/manifest-portability.md`, `docs/scoop-manifest-portability-rules.md`.
- **Problem:** The manifest authoring guide contained an old duplicated section inserted in the middle of the `checkver.github` paragraph. This broke the Regex example and repeated parts of the guide. Portable / Nonportable rules were also split across a separate file with cross-links between the documents.
- **Root cause:** The historical reason for inserting the duplicated section cannot be established from the file contents alone. The confirmed facts are the duplication and the interrupted Regex paragraph. Do not attribute the issue to a specific commit without evidence.
- **Resolution:** Rebuilt `manifest-authoring.md` in Arabic as a single reference, removed the duplicate section, repaired the Regex wording, and merged the Portable / Nonportable / Review rules, MSI / Inno / NSIS / EXE extraction methods, and testing guidance into the same guide. Updated the link in `manifest-portability.md` to point to the unified guide, then deleted the separate rules file after moving its content.
- **Verification:** Read back the unified guide and portability inventory from GitHub after the update, and checked the Arabic content and internal links. Scoop and CI tests were not run because the changes were documentation-only.
- **Prevention:** Keep `docs/manifest-authoring.md` as the single primary reference and do not maintain parallel copies of the same rules. When adding a new rule, update the unified guide, classification inventory, and incident log where applicable.

## 2026-10-31 — Correct Manifest Pipeline trigger documentation

- **Problem:** `docs/manifest-authoring.md` described the Manifest Pipeline as manual-only, while `.github/workflows/manifest-pipeline.yml` on `master` also defines a `push` trigger for the `master` branch when `bucket/*.json` files change. This mismatch could lead to incorrect expectations about validation starting after a manifest is added.
- **Symptoms:** The guide's instructions did not match the actual `on.push` and `on.workflow_dispatch` settings in the workflow file.
- **Root cause:** The guide was not updated when workflow triggers were added or changed, leaving the documentation outdated.
- **Resolution:** Updated the guide to document the automatic trigger when manifest files are pushed to `master`, while retaining the manual trigger. Removed the old closing sentence that claimed there were no incident records even though the file already contained an incident log.
- **Verification:** Read the current YAML from `master` and confirmed `push.branches: master`, `push.paths: bucket/*.json`, and `workflow_dispatch`. The documentation files were to be read back from GitHub after the update to confirm the change. No workflow was actually run as part of this correction.
- **Prevention:** Whenever workflow triggers are changed, review and update the corresponding section in `manifest-authoring.md` in the same commit. Reading the YAML is not a substitute for monitoring an actual Actions run.
- **Status:** The documentation was corrected and checked against the current configuration; workflow execution was not tested.

## 2026-10-31 — Fix Fig and Nook version detection through the GitHub REST API

- **Status:** The manifests were updated; post-fix Scoop validation has not yet completed.
- **Affected files:** `bucket/fig.json` and `bucket/nook.json`.
- **Problem:** Fig failed to match its Regex against `https://github.com/Skynse/Fig/releases/latest`, causing Manifest Pipeline to stop before reaching Nook.
- **Root cause:** The Regex was designed to capture `tag_name` from JSON, but the checkver source did not provide JSON in the format Scoop expected.
- **Resolution:** Used `checkver.url` with `jsonpath: "$.tag_name"` and an explicit Regex in both Fig and Nook, pointing the URL to the GitHub REST API endpoint for the latest release.
- **Verification:** The current API values are Fig = `v1.0.1` and Nook = `v0.2.1`. Both values matched their Regex patterns, but the independent Scoop checkver validation for the two manifests has not yet been rerun.
- **Prevention:** When extracting `tag_name` from JSON, use `checkver.url` with JSONPath and Regex. Do not assume that `checkver.github` or a regular GitHub page will automatically be converted to JSON.



## 2026-10-31 — Fix Android DEX archive URL and verify executable paths

- **Status:** The manifest-specific validation stages were fixed and verified; the combined Manifest Pipeline run was still waiting for the README page-generation stage.
- **Affected files:** `bucket/android-dex.json` and `docs/manifest-authoring.md`.
- **Problem:** Archive validation initially failed because `Android_Dex_Windows_x64.zip` did not contain `Android_Dex.exe` at the expected path. After selecting the correct official archive, validation revealed that the current download URL contained the unresolved `$version` variable.
- **Root cause:** The selected asset did not match the Windows file recommended by the official README. The `$version` update variable was also used in the current-release URL instead of being reserved for the `autoupdate` template.
- **Resolution:** Used `Android_Dex_Windows.zip` from release `Android-Dex-v.1.4` with the correct SHA-256, and made `architecture.64bit.url` a fixed URL for the current release. Kept `$version` only in `autoupdate.architecture.64bit.url`.
- **Verification:** Formatting passed in [41193383683](https://github.com/kiro5678/kirobucket/actions/runs/41193383683). `checkver` passed in both PowerShell and pwsh in [41193419418](https://github.com/kiro5678/kirobucket/actions/runs/41193419418). SHA-256 and archive-path validation passed in [41193462723](https://github.com/kiro5678/kirobucket/actions/runs/41193462723). The `autoupdate` test passed in [41193496154](https://github.com/kiro5678/kirobucket/actions/runs/41193496154), and CI passed in both PowerShell and pwsh in [41193538127](https://github.com/kiro5678/kirobucket/actions/runs/41193538127). Do not mark the combined Manifest Pipeline run fully successful until the README table-generation stage has completed.
- **Prevention:** Put a real, version-specific release URL in `architecture.<arch>.url`. Use `$version` only in `autoupdate.url` templates, then verify archive extraction and the presence of every file referenced by `bin` and shortcuts.



## 2026-10-31 — Scoop repository checkout failed because of the GitHub API rate limit

- **Status:** The authentication configuration fix was applied; operational verification after the change is still pending.
- **Affected files:** `.github/workflows/scoop-checkver-validation.yml`, `.github/workflows/ci.yml`, and `.github/workflows/scoop-autoupdate-validation.yml`.
- **Problem:** Checkver and CI jobs failed during the `Checkout Scoop` step before manifest checks started, with the explicit error `API rate limit exceeded for installation`. Manifest Pipeline stopped at the first failed child stage, so the 48-manifest batch and the Fig/Nook rechecks were not completed.
- **Root cause:** The `actions/checkout` step for `ScoopInstaller/Scoop` automatically used `github.token`, which was associated with a GitHub App installation and had reached its API request limit. The logs confirm that the failure occurred during checkout, not inside Scoop `checkver` or the manifest Regex patterns.
- **Resolution:** Added `${{ secrets.CHECKVER_GITHUB_TOKEN || github.token }}` to the Scoop repository checkout steps in all three workflows. When available, the PAT stored in `CHECKVER_GITHUB_TOKEN` is used, with the default GitHub token retained as a fallback.
- **Verification:** Logs from [41194974061](https://github.com/kiro5678/kirobucket/actions/runs/41194974061) and [41194857644](https://github.com/kiro5678/kirobucket/actions/runs/41194857644) confirmed that Scoop checkout stopped with the API-limit error before Checkver/CI began. The edits were inspected as text before being pushed; the jobs have not yet been rerun, so the API-limit issue has not yet been proven resolved.
- **Prevention:** Use a dedicated token with its own API rate limit when checking out the Scoop repository or making frequent GitHub API requests. Do not report a Checkver failure as a manifest error when checkout failed before Checkver ran. Report test-environment setup results separately from the actual test results in Manifest Pipeline reports.


## 2026-10-31 — Add Wintor, Cliptray, Yerel, and Anton to the bucket with validation statuses

- **Status:** All four manifests were added to `bucket/`. The Review classifications for the source-build projects and Anton are provisional pending operational verification. No successful installation or local build is claimed at this stage.
- **Affected files:** `bucket/wintor.json`, `bucket/cliptray.json`, `bucket/yerel.json`, `bucket/anton.json`, `docs/manifest-portability.md`, `docs/categories.md`, and `.github/workflows/manifest-table.yml`.
- **Problem:** Not all four applications provided a ready-to-use Windows asset with a published download URL and checksum. Wintor is distributed through Microsoft Store; Cliptray and Yerel do not publish Windows release assets in the specified repositories; and Anton's official Windows URL redirects to a setup EXE without a publicly available checksum.
- **Resolution:** Added Wintor through its official Store Product ID using winget, with removal of the per-user package on uninstall. Added Cliptray and Yerel as source-build manifests pinned to full Git commit hashes, with build dependencies and shortcuts created by a hook after a successful build. Added Anton as a Review entry that downloads, but does not run, the official setup file and detects the version from the redirect URL.
- **Evidence available before execution:** The README, `Package.appxmanifest`, and repository source confirm Wintor's distribution method and Cliptray/Yerel requirements. Anton's official URL redirected to Windows version 0.2.48. No published checksum was available for Anton or the source archives; the source repositories were pinned to full Git commit SHA-1 values instead of inventing archive hashes.
- **Tests not yet performed:** Execution of winget/Microsoft Store, building Cliptray with MSVC, building Yerel through npm, and running Anton Setup on Windows had not been verified. Wait for Scoop Checkver, archive/autoupdate validation, and CI results after the push; these checks do not replace actual installation and build testing.
- **Prevention:** Do not replace missing release assets with files from a fork or another similarly named project. Do not describe source-build applications as Portable before a successful build and launch test, and do not run an uninspected setup file or assume its data/integration behavior.


## 2026-10-31 — Remove Wintor because its installation depended on winget

- **Status:** Deleted `bucket/wintor.json` at the user's request.
- **Affected files:** `bucket/wintor.json`, `docs/manifest-portability.md`, `docs/categories.md`, and `.github/workflows/manifest-table.yml`.
- **Reason:** The manifest relied on `winget install --source msstore` to install a Microsoft Store application instead of downloading and managing a Windows package directly through Scoop.
- **Resolution:** Deleted the manifest and removed its entry from the category index and generated README map, updating the total manifest count to 834 and the Nonportable count to 57.
- **Verification:** After pushing, the absence of the file and its references, as well as successful README table generation, needed to be confirmed. The winget installation itself was not run as part of this deletion.
- **Prevention:** Do not add a manifest that invokes winget or another external package manager to install a separate application unless the user explicitly requests it. Prefer direct package URLs that Scoop can download and manage.


## 2026-10-31 — Remove the Cliptray and Yerel manifests

- **Change:** Deleted `bucket/cliptray.json` and `bucket/yerel.json` at the user's request.
- **Context:** Both manifests downloaded a source ZIP from GitHub and built the application locally. Neither Windows build nor application launch had been verified.
- **Index updates:** Removed the entries from `docs/categories.md`, `docs/manifest-portability.md`, and the category map in `.github/workflows/manifest-table.yml`.
- **Counts:** 832 manifests: 771 Portable, 56 Nonportable, and 5 Review. The ZIP archive count decreased from 562 to 560.
- **Verification:** The GitHub tree and Actions runs were to be checked after the update to confirm that both files were gone and the README had been regenerated.


---

## Workflow Change Log

The following section preserves the complete historical content of the former `logs/workflows.md`. Existing workflow records and their run links are retained; heading levels are nested under this unified document.


This log records the important changes, fixes, and CI results related to the repository workflows.

### 2026-09-29

#### README manifest table workflow
- Added automatic generation of the manifest table from `bucket/*.json`.
- Added concurrency protection to reduce simultaneous README update conflicts.
- Changed checkout to track the `master` branch with full history so manifest update dates can be read reliably.
- Added graceful handling for malformed JSON so the README generator can warn and continue while CI remains responsible for manifest validation.

#### CI / manifest validation fixes
- Fixed an invalid JSON escape in `bucket/xyplorer.json` that caused the README table workflow to fail during JSON parsing.
- Confirmed that the corrected `xyplorer.json` passes JSON/schema validation.
- Fixed missing final newlines in workflow-related files/manifests when required by repository CI.

#### README duplication issue
- The README generator originally updated only the marker contents and left duplicate `## Manifests` sections outside the markers.
- Changed the generator to replace the complete `## Manifests` section between the start and end markers.
- Removed duplicate and empty generated table sections from the README.

#### Manifest sorting work
- Added date sorting support:
  - Newest first (default)
  - Oldest first
- Added alphabetical name sorting support:
  - A–Z
  - Z–A
- Iterations that generated multiple visible tables were removed from the final README layout.
- The final design keeps a single visible manifest table and retains sorting links in the table header.
- Separate generated views are stored under `docs/` so the README itself does not contain duplicated full tables.

#### Relevant workflow runs
- Run 36639080509 — CI failure caused by `spacedrive.json` validation.
- Run 36643258424 — CI failure caused by missing final newline in `spacedrive.json`; schema validation itself passed.
- Run 36643573924 — CI success after the newline fix.
- Run 36643982015 — README table workflow success.
- Run 36644154237 — README table workflow success.
- Run 36644990100 — README table workflow success.

### 2026-10-08

#### UniGetUI manifest and workflow fixes
- Added/updated `bucket/unigetui.json` for UniGetUI `2026.3.1`, matching the official Scoop Extras manifest while keeping UniGetUI data in the normal user AppData location instead of Scoop's `persist` directory.
- Removed `pre_install` creation of `ForceUniGetUIPortable` and removed `persist: "Settings"` so UniGetUI does not run in forced portable mode.
- Fixed CI failure caused by `unigetui.json` missing the required final CRLF newline; the manifest schema itself was valid.
- Fixed a race in `format-manifests.yml` where simultaneous workflow pushes could fail with `fetch first`.
- Updated manifest normalization to fetch/rebase against the latest `master` before pushing.
- Updated CI triggering so normalization can explicitly dispatch a follow-up CI run after it changes manifests.

#### Relevant workflow runs
- Run 37833777695 — normalization failed because another workflow had already advanced `master`; push was rejected with `fetch first`.
- Run 37834096226 — CI failed only because `unigetui.json` lacked the required final newline; schema validation passed.
- Run 37834096251 — normalization succeeded for the corrected manifest formatting.
- Run 37835084703 — CI started from the workflow fix commit.
- Run 37835120920 — normalization workflow running with the race-condition fix.
- Run 37835121006 — CI running on commit `986ed518862eb3d8e39ea14654a552aed19af9a8`.

### Current workflow behavior

The manifest-table workflow:
1. Reads all manifests in `bucket/`.
2. Extracts version, description, and last modification date.
3. Generates the README table with the newest updates first.
4. Keeps sorting links for Name and LAST UPDATE.
5. Maintains the generated section using explicit start/end markers.
6. Commits README changes automatically when the generated content changes.

The repository CI remains responsible for validating manifest syntax and schema correctness.

### 2026-10-10

#### Manifest archive/path validation
- Added `.github/workflows/validate-manifest-archives.yml` to inspect changed manifests' actual downloadable archives after newline normalization.
- The validator verifies static hashes when available, confirms configured `extract_dir` entries exist, and checks declared `bin` and shortcut paths against the files that remain after extraction.
- Updated `format-manifests.yml` to pass the pre-change commit SHA to the validator after normalization.
- Updated `ci.yml` to start from the `archives-validated` dispatch, so Scoop's standard tests run after archive/path checks succeed rather than in parallel.
- The validator can also be run manually for one manifest by providing a path such as `bucket/winzenith.json`.
- Validation intentionally does not execute downloaded installers or manifest install scripts. Non-archive installers and paths that may be generated by install hooks are reported as unverified warnings.

#### Archive validator test results
- Run 38025650597 exposed a checker bug: nested `shortcuts` arrays were flattened and the shortcut label was mistaken for a file path. The validator was fixed to preserve nested arrays.
- Run 38025720619 — archive validation succeeded for `bucket/winzenith.json`: downloaded the v1.3.5 ZIP, verified its SHA-256, and confirmed the declared `bin` and shortcut paths exist in the archive contents; 0 validation failures.
- Run 38025734499 — the official CI matrix passed after the archive validator dispatched it.
- Added a direct-push gate in `ci.yml` so a push containing any `bucket/*.json` change cannot start Scoop tests before archive validation. README/docs/log-only changes are ignored by the direct CI trigger; successful archive validation triggers CI with the `archives-validated` event.
- The archive path filter is case-insensitive so uppercase manifest extensions such as `FoliCon.JSON` are included.

#### `format-manifests.yml` dispatch fix
- Fixed the PowerShell dispatch step to avoid the malformed multiline SHA regex that caused earlier workflow runs to fail during workflow parsing before any jobs started.
- Moved GitHub event and commit-message values into environment variables, then validates the base commit SHA in PowerShell using the anchored 40-character hexadecimal pattern.
- Kept a guarded fallback to the parent commit when the push event does not provide a valid base SHA; the step fails explicitly if a valid SHA still cannot be determined.
- Runs 38025532072, 38025537807, 38025539515, and 38025581234 are historical failures from the earlier broken workflow revisions.
- Run 38025708738 — `Normalize manifest newlines` succeeded after the fix.

#### CI trigger order and safeguards
- For pushes affecting `bucket/**`, `format-manifests.yml` runs first and normalizes manifest JSON files to exactly one trailing CRLF. It commits and pushes only when normalization changes file contents.
- After normalization, `format-manifests.yml` sends the `manifests-normalized` repository dispatch with the pre-change base SHA to `validate-manifest-archives.yml`.
- The archive validator checks changed manifests' downloadable archives, static hashes, and statically verifiable `extract_dir`, `bin`, and shortcut paths. Only after successful validation does it send the `archives-validated` dispatch that starts `ci.yml`.
- The direct `push` trigger in `ci.yml` ignores `bucket/**` and `.github/workflows/format-manifests.yml` (as well as README, docs, and logs). Its gate also prevents direct-push test jobs from running when changed manifest JSON files have not passed the archive-validation path.
- `Register PSGallery` remains in the CI test job before the dependency-installation and Scoop test steps.
- Run 38025708738 — the normalization workflow succeeded, but reported that manifests already had exactly one CRLF, so this run did not demonstrate a normalization commit.
- Run 38025720619 — archive validation succeeded for `bucket/winzenith.json`, including SHA-256 and declared `bin`/shortcut path checks; the validator dispatched CI after the checks passed.
- Run 38025734499 — both CI matrix jobs (`powershell` and `pwsh`) passed, including `Register PSGallery` and Scoop tests.
- These results verify the formatter workflow, archive validator, and dispatched CI success. They do not, by themselves, establish that one newly modified manifest was pushed and observed completing the entire end-to-end sequence in a single test.

### 2026-10-11

#### ALLPlayer manifest and Inno Setup archive validation
- Fixed `bucket/allplayer.json` installation metadata by assigning the downloaded setup a distinct local filename (`ALLPlayer-setup-$version.exe`) so it cannot collide with the extracted `ALLPlayer.exe` application executable.
- Added the static SHA-256 for the current 9.6 installer: `239deb29411cffcc716718ed7fd16a2db7afa7f903c2b1ccc54b8b4bda2d8a65`.
- Added a short manifest comment explaining why the local setup filename differs from the remote filename.
- Updated `.github/workflows/validate-manifest-archives.yml`: it verifies static hashes for Inno Setup EXEs, but skips launch-path inspection when 7-Zip exposes PE sections instead of the files extracted by Scoop's `innounp`. This avoids treating the executable's PE sections as an archive file list; it does not constitute a runtime installation test.
- Run 38107881846 — archive validation passed for `bucket/allplayer.json`: SHA-256 OK, 0 failures; the workflow dispatched CI run 38107896724.
- Earlier runs 38107473777 and 38107600546 failed because the validator tried to infer extracted application paths from 7-Zip's PE-section listing, not because of a checksum mismatch.

### 2026-10-11

#### ALLPlayer executable collision fix
- The earlier fix that only changed the local installer filename did not resolve shim creation: Scoop's `bin` still pointed to `ALLPlayer.exe`, which was not present after Inno Setup extraction.
- Updated archive validation to use the same `innounp` extraction style Scoop uses for Inno Setup installers and to report executable architecture and version metadata.
- Confirmed from the actual v9.6.0.0 installer that `ALLPlayer,1.exe` is x64 (22,715,984 bytes), while `ALLPlayer,2.exe` is x86 (17,049,168 bytes). Both report the original filename `ALLPlayer.exe`.
- Updated `bucket/allplayer.json` with a guarded `pre_install` hook that renames the x64 `ALLPlayer,1.exe` to the expected `ALLPlayer.exe` before Scoop creates the shim and shortcut. The hook fails explicitly if the x64 executable is missing or if a target file already exists.
- Run 38109276051 — archive validation succeeded; the installer SHA-256 and innounp helper SHA-256 matched. The validator found both executable architectures and reported 0 failures. Launch-path presence is warned rather than asserted at archive-inspection time because the pre-install hook creates the canonical `ALLPlayer.exe` name.
- Run 38109309430 — CI passed after archive validation; both `powershell` and `pwsh` matrix jobs succeeded, including `Register PSGallery` and Scoop tests.

#### ALLPlayer 32-bit `lib` exclusion (latest manifest adjustment)
- Updated `bucket/allplayer.json` in commit `9ed1030cb242e684dd0099f5d13e7792a247b92f`.
- Extended `pre_install` to require the `lib64` directory and remove only the exact `$dir\lib` directory when it exists; `lib64` is intentionally preserved.
- This is a manifest install-hook change; `.github/workflows/ci.yml` and the archive-validation workflow were not changed for this adjustment.
- Validation status: no CI/archive-validation run has yet been confirmed for commit `9ed1030cb242e684dd0099f5d13e7792a247b92f`. The existing archive validator inspects extracted files but deliberately does not execute install hooks, so the new directory cleanup still needs runtime verification.

#### ALLPlayer x86 executable cleanup and shortcut icon
- Updated `bucket/allplayer.json` in commit `bb4530a2f270512e00019c9587c40d426978fbf9`.
- Extended `pre_install` to remove `ALLPlayer,2.exe` (the x86 executable) after renaming `ALLPlayer,1.exe` to `ALLPlayer.exe`; the existing cleanup still removes only `lib` and preserves `lib64`.
- Initially configured a single `ALLPlayer.ico` shortcut icon, then corrected the approach in commit `42cb22bf8f4417f03bca0c9cf026cc56eb9e3def` to use the bundled `allplayer-radio,1.ico` instead of generating an icon from the executable.
- The selected ICO is renamed to `ALLPlayer.ico`, its ICO header is validated, and `allplayer-radio,2.ico` is removed so only the selected bundled icon remains. The shortcut points to `ALLPlayer.ico`.
- CI workflow definitions were not changed by these manifest updates. The archive validator does not execute `pre_install`, so successful archive validation alone cannot prove the x86 file is removed or the icon is generated; those actions need runtime verification on Windows. No CI result for the follow-up commit has been confirmed yet.


#### ALLPlayer bundled ICO selection correction
- Commit `42cb22bf8f4417f03bca0c9cf026cc56eb9e3def` updates `pre_install` to keep the bundled `allplayer-radio,1.ico` as `ALLPlayer.ico`, remove `allplayer-radio,2.ico`, and validate the ICO header before keeping the shortcut reference.
- The same hook removes `ALLPlayer,2.exe` and `lib`, while requiring and preserving `lib64`.
- No CI run has been confirmed for this latest commit. Archive validation does not execute `pre_install`, so the cleanup and ICO selection need installation-time verification.

### 2026-10-14

#### Manifest table category mappings
- Added explicit category mappings in `.github/workflows/manifest-table.yml` for existing manifests that previously fell back to `Other Utilities`.
- Removed eight obsolete category keys that no longer matched a current manifest filename: `crapcheckthis`, `developer-placeholder`, `pdfcraft`, `pdfcraft-exe`, `ram-cleaner-flusher-pro`, `timescribe-portable`, `unigetuiglobal`, and `windhawk-alpha`.
- Kept the original fallback behavior at the user's request: unmapped future manifests are categorized as `Other Utilities`; the workflow does not warn or fail because of a missing category mapping.
- The workflow regenerated `README.md` and the six generated manifest-view files under `docs/`.
- [Manifest-table workflow run 38484025594 — success](https://github.com/kiro5678/kirobucket/actions/runs/38484025594).
- [CI run 38484025576 — success](https://github.com/kiro5678/kirobucket/actions/runs/38484025576).

#### Archive validation and Scoop autoupdate validation
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

#### Log file location
- Consolidated this record into `logs/workflows.md`, alongside the existing workflow history. The temporary duplicate `docs/workflow-change-log.md` was removed after its information was incorporated here.

#### MuMuPlayer manifest
- Added `bucket/mumuplayer.json` for the current international NX-main installer build `1.8.5.5748`, included in the MuMu Player 12 global release `6.8.5` published on 2026-10-13.
- Set the official CDN download URL and the SHA-256 reported for that exact installer by the release mirror: `dd5be7411c9a3ccf78ddaaaea89b295260ceb527713ae66b82d2a82f730919c9`.
- Configured `checkver` to discover the newest `nxmain` asset from `LOVECHEN/mumu-release` global-release metadata; `autoupdate` builds the matching official CDN URL from the detected version and build number.
- Added the explicit `mumuplayer` category mapping as `Emulators & Compatibility` in `.github/workflows/manifest-table.yml`.
- The manifest retains the referenced installer switches, shortcut target, and `configs`/`vms` persistence. The shortcut target is installer-generated and still needs runtime verification; archive validation alone cannot prove it exists after installation.

#### Scoop Autoupdate Validation parser correction
- Fixed a PowerShell parser error in `.github/workflows/scoop-autoupdate-validation.yml`: changed `$manifestName:` to `${manifestName}:` so the variable is delimited before the colon.
- Fixed the isolated Scoop checkver invocation to pass the copied manifest's full path as the positional `App` argument. Passing the manifest basename together with `-Dir` caused Scoop to interpret the basename as a directory during parameter validation.
- Changed the invocation again to pass `-App`, `-Update`/`-ForceUpdate`, and `-ThrowError` as explicit named parameters. Passing the switch names inside a string array caused PowerShell to bind `-Update` positionally to `Dir`.
- Run [38495030674](https://github.com/kiro5678/kirobucket/actions/runs/38495030674) failed before running manifest checks because of that parser error; it did not indicate a `mumuplayer` version, URL, or hash failure.
- Expanded the MuMuPlayer release metadata query from 30 to 100 releases so newer non-global tags are less likely to push the latest global release outside the response window.

- Latest verification after the fixes: [Scoop Autoupdate Validation run 38495845346 — success](https://github.com/kiro5678/kirobucket/actions/runs/38495845346), [archive validation run 38495811462 — success](https://github.com/kiro5678/kirobucket/actions/runs/38495811462), and [CI run 38495846052 — success](https://github.com/kiro5678/kirobucket/actions/runs/38495846052).
- The checkver script found the current MuMuPlayer NX asset with no failures. The upstream version already matched the manifest, so `-Update` reported the URL/hash update path as **not exercised**; this run does not prove a future release will automatically refresh the URL and hash.

#### MuMuPlayer online installer update
- Replaced the single-engine `NXMAIN` offline installer in `bucket/mumuplayer.json` with the international online installer `MuMu_6.0.2_gw-overseas12_all_1786519314.exe`, SHA-256 `552d4729428664d76dbd2aa2bce64db9ad9a923ac4be3209f3c76064e5aac095`.
- The online installer is a small downloader that retrieves MuMuPlayer's install payload from NetEase; the manifest passes the international channel and silent-install arguments so setup can provision the engine components in one installation.
- Updated `checkver` to locate the newest international online-installer asset, skipping Chinese-only online installer releases, and configured the matching official CDN URL template in `autoupdate`.
- Kept `configs` and `vms` persistence and the existing `MuMuNxMain.exe` shortcut target. The workflow can verify URL/hash and manifest schema, but only a runtime installation test can confirm both engine instances are available and the shortcut launches the intended manager.

#### MuMuPlayer manifest split
- Restored `bucket/mumuplayer.json` to the dedicated international NX-main offline installer, build `1.8.5.5748`, with its matching SHA-256 and NX-main release discovery/update template.
- Created `bucket/mumuplayer-online.json` as a separate manifest for the international `gw-overseas12_all` online installer `MuMu_6.0.2_gw-overseas12_all_1786519314.exe`, SHA-256 `552d4729428664d76dbd2aa2bce64db9ad9a923ac4be3209f3c76064e5aac095`. This is a small online downloader, not the multi-hundred-megabyte offline package; it retrieves the installation payload during setup.
- Added the `mumuplayer-online` category mapping as `Emulators & Compatibility` in `.github/workflows/manifest-table.yml`; the README manifest-table workflow will regenerate the manifest views.
- [Archive-validation run 38497203542 — success](https://github.com/kiro5678/kirobucket/actions/runs/38497203542). The validator treated the online `.exe` as an installer rather than an archive, so executable-path inspection was skipped; this does not prove runtime installation behavior.
- [Scoop autoupdate-validation run 38497224351 — success](https://github.com/kiro5678/kirobucket/actions/runs/38497224351). `checkver` found the current asset with no failures, but the URL/hash update path was not exercised because the version matched. The CI run associated with the new split is tracked separately and must be checked for its final result.


#### MuMuPlayer Android 15 engine manifest
- Added `bucket/mumuplayer-android15.json` for the international MUMU15 Android 15 engine, version `15.8.5.5750`, from the `win-global-offline-6.8.5` release.
- Set the official CDN URL to `MuMu-setup-mumu15-V15.8.5.5750-overseas-1013104801.exe` and its release-mirror SHA-256 to `cc21f4f886e5a5edcc8ab311cdee80f41fba30d6dfc3d0c28db3885cd455aaec`.
- Declared `mumuplayer` as a dependency because MUMU15 is an engine component that shares the NX-main installation directory; the manifest stages the installer with `/action=install_prepare` and then `/action=commit`, passing `/silent=1`, the matching product version, international channel, and shared install directory.
- Added the manifest to the `Emulators & Compatibility` category in `.github/workflows/manifest-table.yml`; the README table workflow will regenerate the index.
- Added a pre-uninstall hook that launches the engine-specific uninstaller if present. The actual install/uninstall behavior has not been runtime-tested; archive/manifest validation cannot prove the emulator launches or that the engine uninstaller exits silently.
- Source release: https://github.com/LOVECHEN/mumu-release/releases/tag/win-global-offline-6.8.5


#### MuMuPlayer NX-main installer failure and correction
- User-provided installation log showed the original `/S` invocation did not create `nx_main\\MuMuNxMain.exe`; Scoop nevertheless continued far enough to report the package as installed, while shortcut creation failed and cleanup complained that root-level `uninstall.exe` did not exist.
- Replaced the single `/S` invocation in `bucket/mumuplayer.json` with the documented two-stage installer orchestration: `/action=install_prepare`, then `/action=commit`, using `/from_orchestrator=1`, `/silent=1`, a shared transaction ID, international channel `gw-overseas12`, and `/auto_run=false`. Product version is derived from the NXMAIN engine version (for example, `1.8.5.5748` maps to product version `6.8.5.0`).
- Removed the assumed root-level `uninstall.exe` deletion. The installer hook now checks that `nx_main\\MuMuNxMain.exe` exists and fails the install explicitly if it does not, preventing another false-success installation.
- Runtime installation has not yet been tested on the user's PC; CI and manifest checks must still complete. Reference for the two-stage installation arguments: https://gist.github.com/TameemS/603686cec857ff1f91e68607e374b0d8 and current international-channel command-line observation: https://tria.ge/260825-xwla1ayakg/behavioral1.


#### MuMuPlayer error 10002 follow-up
- User's retry reached `install_prepare` but failed with exit code `10002`. MuMuPlayer's official installation-error guide identifies `10002` as an abnormal/unavailable installation path: https://www.mumuplayer.com/help/win/installation-error-codes.html.
- Changed the NXMAIN installer path argument from the quoted form `/D="...` to the unquoted form `/D=...`, matching the observed MuMuPlayer command line in https://tria.ge/260825-xwla1ayakg/behavioral1.
- The path itself is still Scoop's version directory (`$dir`). This change only fixes the argument formatting; a runtime retry is needed to determine whether MuMuPlayer accepts this Scoop-managed destination.


#### MuMuPlayer install-path collision fix
- Follow-up analysis found that Scoop stages the downloaded installer inside `$dir` and the manifest also passed that same directory as the MuMuPlayer install destination. This means the destination contained the setup executable when `install_prepare` began, which is consistent with MuMuPlayer's documented error `10002` for an abnormal installation path.
- Updated `bucket/mumuplayer.json` to copy the installer to a unique temporary folder under `$env:SCOOP\\cache`, remove the staged copy from the target version directory, and run both `install_prepare` and `commit` from the separate staging folder while keeping `/D=$dir` as the target. The staging folder is removed in a `finally` block.
- Added an explicit check that the target directory is empty before installation and retained a post-setup check for `nx_main\\MuMuNxMain.exe` so Scoop cannot report success when the expected program binary is absent.
- This addresses the identified path collision, but actual installation still requires a fresh runtime attempt. The official help identifies error `10002` as an abnormal installation path: https://www.mumuplayer.com/help/win/installation-error-codes.html.

- Follow-up hardening: derive the Scoop root from the manifest's version directory rather than relying on `$env:SCOOP`, so staging remains under the actual Scoop root even when UniGetUI launches an elevated shell with a different environment.


#### MuMuPlayer installer cache-path refinement
- Confirmed from Scoop's `lib/download.ps1` that `Invoke-CachedDownload` retains the original download under Scoop's cache path and copies it to the version directory for the manifest's pre-install hook. The user's log line `Loading ... from cache` confirms this behavior on their machine.
- Updated `bucket/mumuplayer.json` to use Scoop's `cache_path` helper to locate the original cached installer by app, version, and exact download URL. It removes only the staged copy from the app version directory before installation, avoiding an unnecessary second copy into another cache subfolder.
- Retained a fallback temporary staging directory for cases where the cache file isn't available (for example, when Scoop cache use is disabled). The target directory is still checked to be empty before MuMuPlayer setup runs.
- References: https://github.com/ScoopInstaller/Scoop/blob/develop/lib/download.ps1 and https://github.com/ScoopInstaller/Scoop/blob/develop/lib/core.ps1.


#### MuMuPlayer NXMAIN installer type inspection
- Inspected the exact file referenced by `bucket/mumuplayer.json` in a Windows GitHub Actions runner using Detect It Easy 3.21. The installer was downloaded from the public `LOVECHEN/mumu-release` mirror and its SHA-256 matched the manifest exactly: `dd5be7411c9a3ccf78ddaaaea89b295260ceb527713ae66b82d2a82f730919c9`.
- Detect It Easy reported: `PE32`; compiler `Microsoft Visual C/C++ (19.29.30147) [C]`; installer `Nullsoft Scriptable Install System (27-Feb-2026.cvs) [zlib, solid]`. Thus, the file is an NSIS-based installer, not Inno Setup.
- Authenticode signature status was `Valid`, with signer `Netease Interactive Entertainment Pte. Ltd.`; Windows file metadata identified `MuMuPlayer`, version `1.8.5.5748`.
- Inspection workflow: [run 38522600720 — success](https://github.com/kiro5678/kirobucket/actions/runs/38522600720). The installer was inspected statically and was not executed. The workflow remains in `.github/workflows/inspect-mumuplayer-installer.yml`; the MuMuPlayer installer URL/hash stay pinned, while Detect It Easy's release is now resolved dynamically through the GitHub Releases API.


#### MuMuPlayer offline installer orchestration correction
- Reworked `bucket/mumuplayer.json` to install both official international offline payloads from the same global release: NXMAIN `1.8.5.5748` and MUMU15 `15.8.5.5750`. The two assets have independent SHA-256 pins and are both managed by Scoop's URL/hash arrays.
- Changed the pre-install hook to run the observed four-step order with one shared transaction ID and product version `6.8.5.0`: NXMAIN `install_prepare`, MUMU15 `install_prepare`, MUMU15 `commit`, then NXMAIN `commit`, waiting 12 seconds between stages. Both installer files are staged/used from Scoop's cache rather than left in the installation target directory.
- Reworked `checkver` to locate both assets from the same latest `win-global-offline-*` release and emit a composite match string; `autoupdate` uses the corresponding capture groups to refresh both download URLs.
- Source for the four-command sequence: https://gist.github.com/TameemS/603686cec857ff1f91e68607e374b0d8?permalink_comment_id=6135981. This is community documentation, not an official MuMuPlayer command-line reference; the source demonstrates version `6.5.2.0`, so the arguments and sequence must still be validated against the current `6.8.5.0` installers in a runtime test.
- SHA-256 pins were cross-checked against the `win-global-offline-6.8.5` release metadata: NXMAIN `dd5be7411c9a3ccf78ddaaaea89b295260ceb527713ae66b82d2a82f730919c9`; MUMU15 `cc21f4f886e5a5edcc8ab311cdee80f41fba30d6dfc3d0c28db3885cd455aaec`.


#### MuMuPlayer engine manifest separation correction
- Corrected `bucket/mumuplayer.json` after the prior change had mistakenly combined both NXMAIN and MUMU15 installer payloads in one manifest. It now downloads and installs only the NXMAIN engine again.
- Kept the two-stage `install_prepare` then `commit` invocation for NXMAIN, with the installer staged outside the target directory and the expected `nx_main\\MuMuNxMain.exe` checked after setup.
- MUMU15 remains a separate add-on manifest at `bucket/mumuplayer-android15.json`, as originally requested. The four-step two-engine sequence from a community guide should not be used to silently make the base manifest install MUMU15 as well.
- The two-engine sequence in the linked Gist is community guidance, not official MuMuPlayer documentation; runtime testing is still required to validate this single-engine install orchestration on current builds.
### 2026-10-15

#### TieZ clipboard manager manifest
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

#### Pulse manifest review and service lifecycle
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

### 2026-10-20

#### Excavator API rate-limit and MuMuPlayer checkver correction
- [Excavator run 39372547015 — failed](https://github.com/kiro5678/kirobucket/actions/runs/39372547015/job/118463413112). The job logged multiple GitHub REST API `403 rate limit exceeded` responses; the fatal MuMuPlayer checkver script then reported that no international release was found.
- The upstream releases API now uses tags such as `win-6.8.5` rather than the old `win-global-offline-6.8.5` pattern. The current `win-6.8.5` release (published 2026-10-13) contains the expected overseas NX-main and MUMU15 installer assets, so requiring the obsolete tag prefix was brittle.
- Updated the custom checkver scripts in `mumuplayer.json`, `mumuplayer-android15.json`, and `mumuplayer-online.json` to add an optional Bearer authorization header from `GITHUB_TOKEN`, while preserving local use when the variable is absent.
- Updated the NX-main and Android 15 lookups to select the newest release containing the matching international installer asset, independent of the tag name. The online-installer lookup already searched assets across releases; it now also uses the optional authorization header.
- Updated `docs/manifest-authoring.md` with a general rule to authenticate custom GitHub API checkver calls when a workflow token is available and to filter mixed releases by the intended asset.
- Explicitly passed `${{ github.token }}` as `GITHUB_TOKEN` to the repository-wide checkver and targeted autoupdate validation steps; without this environment mapping, the custom manifest scripts would fall back to anonymous API requests inside those validation workflows.
- The upstream release-list was inspected to confirm the current expected assets. This fixes the identified failure path, but the prior failed run has not been re-executed against the new commit; a successful Excavator run is still required to confirm the workflow end to end.

#### Checkver failure analysis — LiveWallpaper and LynxOptimizer
- [Manual Scoop Checkver Validation run 39100103135](https://github.com/kiro5678/kirobucket/actions/runs/39100103135/job/117594454652) failed on exactly two manifests; the other 304 passed. `mumuplayer.json`, `mumuplayer-android15.json`, and `mumuplayer-online.json` all passed in this run.
- `livewallpaper.json`: the JSONPath read only `$[0].assets[*].browser_download_url`, but the newest upstream release used the `LiveWallpaper_Installer_v...` filename that the regex did not support. The manifest deliberately targets the newer 4.x `GiantappWallpaper_..._x64-setup.exe` / prior `LiveWallpaper.Installer...` asset family, so expanded JSONPath to all assets across the release list while retaining the existing version and verified URL/hash.
- `lynxoptimizer.json`: `checkver` queried `/releases/latest`, which returned the `PREVIEW-0.280.0` channel, while the manifest URL/autoupdate template intentionally use the mutable `PREVIEW-DEV` tag and version `0.216.2`. Changed the API endpoint to `/releases/tags/PREVIEW-DEV`; verified that it returns name `PREVIEW:0.216.2` and the exact asset/hash already pinned in the manifest.
- Updated `docs/manifest-authoring.md` to require release-channel alignment between `checkver` and autoupdate URLs, and to search across the intended release asset family when upstream uses multiple naming schemes.
- The changes have been committed, but the new repository-wide checkver/CI runs must finish before calling these two fixes fully validated.

#### Repository-wide checkver follow-up — 2026-10-20
- [Manual Scoop Checkver Validation run 39388954560](https://github.com/kiro5678/kirobucket/actions/runs/39388954560) confirmed that the two failures from run 39100103135 were corrected: both `livewallpaper` and `lynxoptimizer` passed under pwsh.
- The run still failed on ten other manifests. Eight GitHub-release manifests used URL-fragment regexes such as `tag/v...` even though the current Scoop GitHub API mode applies their regex to the JSON `tag_name` field. Updated the patterns in `adb-device-manager`, `android-dex`, `cooldesk`, `cooldesk-msi`, `ds4windows`, `fluenttweaker`, `mucommander`, and `nightlight-launcher` to match the actual tag value.
- `flow` and `fluentstore` use release channels marked as prereleases, so GitHub's `/releases/latest` endpoint returned 404 even though their published tagged releases and Windows assets exist. Added explicit release-list scripts that select the newest numeric Flow tag with the Windows x64 ZIP and the newest FluentStore beta tag with the x64 installer. Verified Flow v0.7.0 and FluentStore v0.4.0-beta assets exist in upstream release metadata.
- Corrected the Flow description to reflect the current upstream application (calendar/event/time management rather than flowcharts).
- Updated the manifest-authoring rules to document JSON `tag_name` matching and handling of projects that publish only prereleases. These changes are intended to clear the ten newly surfaced failures; the next full checkver run must confirm the result.

#### HelixNotes checkver fallback — 2026-10-20
- [Manual Scoop Checkver Validation run 39390145242](https://github.com/kiro5678/kirobucket/actions/runs/39390145242) showed that the Windows PowerShell job passed all manifests but the pwsh job failed only on `helixnotes.json`; Scoop reported the GitLab API permalink URL as invalid (404). The earlier run `39387739358` used commit `28484002`, before the subsequent fixes to other checkver manifests.
- The official [HelixNotes homepage](https://helixnotes.com/) currently displays `Latest release v1.3.6`, matching the existing manifest version and download URL. Switched `checkver` to the homepage and a regex for that release label, avoiding the GitLab API endpoint that failed under pwsh.
- Updated `docs/manifest-authoring.md` with guidance on using an official homepage release label as a fallback when the upstream API is unreliable, and validating the captured version.
- A repository-wide checkver workflow was triggered by this documentation update; it must finish successfully in both PowerShell and pwsh before the fix is considered validated. The pinned version, installer URL and hash were otherwise left unchanged.


#### Repository-wide checkver — API rate-limit failures on five manifests
- [Validation run 39469049101](https://github.com/kiro5678/kirobucket/actions/runs/39469049101) checked 306 manifests. Windows PowerShell passed, and the pwsh job failed on `spotlight-dimmer.json`, `sucrose-nightly.json`, `tiez-clipboard.json`, `tiro-notes.json`, and `translumo.json`.
- The five errors were all GitHub REST API HTTP 403 rate-limit responses from URL-based `checkver` requests. The workflow already passed `GITHUB_TOKEN`, but Scoop's built-in URL/JSONPath path did not attach it to those requests. The errors therefore did not establish that releases were missing.
- Converted those five manifests to custom `checkver.script` lookups that send `Authorization: Bearer $env:GITHUB_TOKEN` when available and retain an anonymous fallback for local use. The scripts preserve each intended release channel: Windows-tagged Spotlight Dimmer releases, Sucrose pre-releases, TieZ portable Windows ZIP assets, Tiro Notes releases with the Windows x64 ZIP, and Translumo's latest release tag.
- Added a rule to `docs/manifest-authoring.md` explaining that built-in `checkver.url`/JSONPath requests do not automatically use the workflow token and that HTTP 403 rate limits should be fixed as authentication problems, not treated as missing releases.
- Validation status: these changes have been committed and need a fresh repository-wide run in both PowerShell and pwsh to confirm that the five checks and the full sweep pass.


#### Follow-up to repository-wide checkver run 39469049101 — 2026-10-20
- [Follow-up run 39471485084](https://github.com/kiro5678/kirobucket/actions/runs/39471485084) confirmed that the five manifest-specific API scripts now use the token, but exposed a broader rate-limit issue: native GitHub API URLs in Scoop's built-in `checkver.url` path do not send `GITHUB_TOKEN`. The pwsh job therefore logged HTTP 403 failures for 19 other API-backed manifests, while the Windows PowerShell job's only failure was `biniware-run.json`.
- Updated `.github/workflows/scoop-checkver-validation.yml` to patch the temporary Scoop checkout's `bin/checkver.ps1` during CI so requests to `api.github.com` receive the supplied Bearer token. This is an ephemeral CI-only change; it does not modify Scoop upstream or the repository's manifests beyond their intended version-detection configuration.
- Updated `bucket/biniware-run.json` to match the current official page's raw HTML. The previous `Current version[^\\d]*...` pattern stopped at digits in HTML attributes before reaching the displayed version. The replacement is bounded and non-greedy; version `7.9.0.0`, the existing download URL, and hash remain unchanged. The official page currently lists Biniware Run 7.9.0.0 and the same SHA-256 pinned in the manifest.
- Updated `docs/manifest-authoring.md` to document the workflow's API authentication shim and safe raw-HTML version matching.
- A separate archive validation job, [run 39471473484](https://github.com/kiro5678/kirobucket/actions/runs/39471473484), failed on `sucrose-nightly.json`: its existing 7z asset contained a Sucrose Bundle setup executable, while the manifest declares `Sucrose.Launcher/Sucrose.Launcher.exe` as if the archive held the application files. The current URL/hash were not changed by the checkver fix. This is a separate packaging/install-layout issue; it is not an API authentication or version-detection failure and remains to be reviewed independently.
- Validation status: a new full checkver run is required to confirm both shell jobs after the workflow authentication and Biniware regex fixes.


#### Sucrose stable/nightly installer payload correction — 2026-10-20
- [Archive validation run 39471473484](https://github.com/kiro5678/kirobucket/actions/runs/39471473484) showed that `sucrose-nightly.json` downloaded a file ending in `.7z` whose actual contents were the Sucrose Bundle setup executable, not the extracted application. The declared in-Scoop `Sucrose.Launcher` path therefore could not exist.
- Checked the [official Sucrose Installation guide](https://github.com/Taiizor/Sucrose/wiki/Installation): it describes Sucrose as a self-extracting per-user Bundle installer, specifies that package managers run the release `.exe` with `/s`, and documents the install path as `%LOCALAPPDATA%\\Sucrose`.
- Updated both `sucrose.json` and `sucrose-nightly.json` to use the corresponding official setup `.exe` assets and verified SHA-256 digests, run each architecture's installer silently using `/s`, and call the official HKCU uninstall entry during Scoop uninstall. Removed invalid `bin` and shortcut targets that incorrectly assumed the application files were extracted inside the Scoop version directory. Updated autoupdate URLs to the official installer filenames.
- The stable manifest is pinned to the official stable release v26.7.5.0. The nightly manifest remains on the latest prerelease v26.10.5.0; its `checkver` now selects prerelease releases containing the x64 Bundle installer, rather than only relying on a numeric tag.
- Both manifests now explicitly note that the official installer installs to the user's profile and that stable and nightly manifests share the same per-user path, so they are not side-by-side installations.
- Updated the authoring rules to warn that a `.7z` extension alone does not prove the payload is a portable archive or match the paths declared in a manifest.
- The manifest/schema and archive validation workflows must complete against this correction before calling it fully verified; the installer was not run interactively on a user's PC.
### 2026-10-24

#### UniGetUI global-data manifest
- Renamed `bucket/unigetui.json` to `bucket/unigetuiglobal.json` to distinguish regular per-user data storage from the separate portable manifest.
- Removed the post-install migration of existing `Settings` contents from prior UniGetUI Scoop locations; installation no longer copies legacy settings into `%LOCALAPPDATA%\UniGetUI`. The hook only removes `ForceUniGetUIPortable` so UniGetUI uses its normal per-user data directory.
- Removed `ForceUniGetUIPortable` from the installed ZIP so UniGetUI uses its normal per-user data directory instead of storing active configuration and caches inside Scoop.
- Kept `bucket/unigetui-portable.json` as the separate portable variant and updated the manifest category mapping and category documentation.

### 2026-10-29

#### Merge and checkver workflow reconciliation — PR #33 and PR #32

- Merged [PR #33 — Fix checkver detection for affected manifests](https://github.com/kiro5678/kirobucket/pull/33) into `master` first. Merge commit: [`9af68b6`](https://github.com/kiro5678/kirobucket/commit/9af68b63fdfa8f3b8353892d36592078695a82bf).
- Merged [PR #32 — Add categorized manifests from Neuber, Aurelitec, ComputerSluggish, Funk.eu and LopeSoft](https://github.com/kiro5678/kirobucket/pull/32) afterward. Merge commit: [`b1cfaf4`](https://github.com/kiro5678/kirobucket/commit/b1cfaf4ec4ba5af56b03b91a2ed040ed32d46b72).
- Reconciled `.github/workflows/scoop-checkver-validation.yml` after the branch conflict. Push-triggered runs validate only manifests changed by that push; manual full-bucket validation requires the optional repository Actions secret `CHECKVER_GITHUB_TOKEN`.
- Kept the checkver exemption limited to `bucket/kvrt.json`. Failures in any other manifest are recorded as failures and cause the workflow to exit with code 1.
- Updated `docs/manifest-authoring.md` to document use of `CHECKVER_GITHUB_TOKEN` for authenticated requests to unrelated public GitHub repositories, while preserving the existing regex, timeout/retry, and validation guidance.
- Follow-up commits: [workflow reconciliation](https://github.com/kiro5678/kirobucket/commit/3a72558553c33e87be95f9f0e7576b8ba8ed76a0) and [authoring guidance](https://github.com/kiro5678/kirobucket/commit/d2586144c385dcc69100fa40940a7e0d8c90ab43).
- Verification performed: fetched the workflow and authoring guide from `master` and confirmed the optional-token handling, changed-manifest selection, KVRT-only exception, and failure behavior are present.
- CI status: no post-change run result was available during this verification, so the changes are committed and inspected but are not recorded as CI-passing.

#### muCommander stable-only manifest — nightly package retired

- Investigated [checkver validation run 40860770065, job 123403114234](https://github.com/kiro5678/kirobucket/actions/runs/40860770065/job/123403114234). The original failure was in `bucket/mucommander-nightly.json`: the official `nightly` release endpoint returned `404 Not Found`.
- Inspected the upstream [nightly workflow](https://github.com/mucommander/mucommander/blob/master/.github/workflows/nightly.yml), which deletes the previous `nightly` release/tag while rebuilding and uploading replacement assets. The earlier retry-based checkver attempt was superseded because [archive validation run 40885487833](https://github.com/kiro5678/kirobucket/actions/runs/40885487833) also confirmed the portable ZIP URL returned 404.
- The user requested a stable-only manifest. Removed `bucket/mucommander-nightly.json` so it no longer causes nightly release checks.
- Kept `bucket/mucommander.json` at the official stable version `1.6.2-1`; changed its description to `Dual-pane file manager (stable release).` The initial checkver run [40893847999](https://github.com/kiro5678/kirobucket/actions/runs/40893847999) showed the old GitHub HTML detector no longer matched the releases page. Replaced it with the official GitHub Releases API endpoint (`/releases/latest`), JSONPath `$.tag_name`, and a version-format regex in commit [`6a56ee1`](https://github.com/kiro5678/kirobucket/commit/6a56ee112d21c8d2575100d9739f41d0d0499ef9). The official [release page](https://github.com/mucommander/mucommander/releases/tag/1.6.2-1) and release API identify tag `1.6.2-1` as the latest non-prerelease. The official x64 portable ZIP is `https://github.com/mucommander/mucommander/releases/download/1.6.2-1/mucommander-1.6.2-1-portable-x86_64.zip`, and its published SHA-256 `e6769537bbb56cc52c1289ebef2e3d051912bb8b10691d320f28b945f15819a4` matches the manifest.
- Removed the temporary backup file `logs/manifests/mucommander-nightly-1.6.3-2026-10-29.json` at the user's request; no backup is retained. Updated `docs/categories.md` and removed the unused nightly category mapping from `.github/workflows/manifest-table.yml`. A bucket change triggers the manifest-table workflow to regenerate README and manifest-view indexes.
- Validation status: the stable manifest JSON was parsed and its version, official download URL, and SHA-256 were checked against official release metadata. The replacement API-based checkver passed both PowerShell jobs in [run 40894152545](https://github.com/kiro5678/kirobucket/actions/runs/40894152545). Archive validation [run 40894203416](https://github.com/kiro5678/kirobucket/actions/runs/40894203416) and autoupdate validation [run 40894254379](https://github.com/kiro5678/kirobucket/actions/runs/40894254379) also passed on commit `9fa8c45`. The full CI test jobs in [run 40894259968](https://github.com/kiro5678/kirobucket/actions/runs/40894259968) and manifest-table regeneration [run 40894152704](https://github.com/kiro5678/kirobucket/actions/runs/40894152704) subsequently completed successfully. Read back `README.md` and the generated name/category indexes and confirmed that they list only the stable `mucommander` manifest, with no `mucommander-nightly` row.
#### Manual manifest pipeline orchestration

- Added [Manual Manifest Pipeline](https://github.com/kiro5678/kirobucket/blob/master/.github/workflows/manifest-pipeline.yml), which accepts one already-committed `bucket/<name>.json` manifest and dispatches the retained workflows sequentially: normalize the target manifest, Checkver, archive validation, optional FxSound integration test, autoupdate validation, CI, then README/index regeneration.
- The orchestrator waits for each child workflow's actual `workflow_dispatch` run to complete. It stops immediately if a stage fails or times out; it does not start later stages after a failure. The autoupdate template test is forced by default.
- Changed the manifest lifecycle workflows to `workflow_dispatch` only: `format-manifests.yml`, `scoop-checkver-validation.yml`, `validate-manifest-archives.yml`, `scoop-autoupdate-validation.yml`, `ci.yml`, and `manifest-table.yml`. The existing workflows were retained; none were deleted.
- Removed the formatter's automatic archive-validation dispatch and the archive validator's automatic autoupdate/CI dispatch, so only the orchestrator sequences those stages. Added a `manifest` input to Checkver and the formatter so the orchestrator validates and normalizes only the selected manifest.
- Made the dedicated FxSound test, Excavator updater, KVRT verification, SHA-256 calculator, and MuMuPlayer installer inspection manually triggered instead of push/schedule triggered. The separate issue and pull-request event handlers were left unchanged because they respond to issue/PR events rather than direct manifest pushes.
- Added instructions to `docs/manifest-authoring.md`. Validation at edit time: fetched each updated workflow back from `master` and inspected its trigger block and orchestration steps. The orchestration itself has not yet been run end-to-end from GitHub Actions, so its child-dispatch/polling sequence is not claimed as runtime-verified.
#### Fix invalid workflow YAML in manual manifest pipeline

- Investigated the linked failed runs [40915373627](https://github.com/kiro5678/kirobucket/actions/runs/40915373627) and [40916362476](https://github.com/kiro5678/kirobucket/actions/runs/40916362476). Both showed `name` falling back to the workflow file path and no jobs being created, which was consistent with invalid workflow definitions.
- Root cause in `manifest-pipeline.yml`: GitHub expression delimiters had an opening `${{` but only one closing `}` in the concurrency group and `env` values. Fixed them to balanced `${{ ... }}` in commit [`122a94b`](https://github.com/kiro5678/kirobucket/commit/122a94bdd409fb3a1450b059e2c5f3cf5c9e6720).
- The earlier Checkver edit had also left a cut-off regex conditional and leftover push-event selection code in an intermediate revision. Repaired the current `scoop-checkver-validation.yml` in commit [`0878e71`](https://github.com/kiro5678/kirobucket/commit/0878e7110f9942ea6836c77df7aa195d4a0d5f88); the current workflow has `workflow_dispatch` only and a valid optional single-manifest input.
- Re-read all `.github/workflows/*.yml` files through the GitHub connector. No incomplete `${{ ... }}` expressions were found in the current files. Manifest Pipeline, FxSound, and KVRT verification are manual-only; Excavator retains both manual dispatch and its four-hour schedule. `issues.yml` and `pull_request.yml` remain event-driven because they handle issue/PR events, not manifest pushes.
- Validation limitation: the linked runs refer to earlier commits and have no jobs/logs available from the current connector response. The corrected `manifest-pipeline.yml` has not yet been manually dispatched end-to-end; do not claim the orchestration passed until a new manual run completes successfully.

### 2026-10-29 — Temporary automatic-trigger experiment (superseded)

- A temporary revision enabled automatic `push` runs for `bucket/**` changes and retained manual `workflow_dispatch`. That configuration is historical and was later reverted because the user requested manual-only manifest orchestration.
- The current `.github/workflows/manifest-pipeline.yml`, `excavator.yml`, `fxsound.yml`, and `kvrt-update.yml` are manual-only. The pipeline dispatches retained child workflows in order and stops when a validation stage fails.
- The temporary automatic-trigger implementation and its related commits remain in Git history for traceability; they are not the current workflow configuration.

### 2026-10-29 — Excavator false-success and manifest update failures

- Investigated [Excavator run 40934333831](https://github.com/kiro5678/kirobucket/actions/runs/40934333831/job/123660764788). The job's outer conclusion was `success`, even though Scoop printed `ERROR Could not update ...` for multiple manifests. The workflow ran ScoopInstaller/GithubActions with its default non-terminating error handling and did not set `THROW_ERROR`. Added `THROW_ERROR: 1` so checkver/autoupdate errors stop the action with a failing result instead of being treated as a successful maintenance run.
- Fixed the manifest issues found in that run:
  - `aerial.json`: upstream moved to `AerialWindows/Aerial`; releases after v1.3.0 changed from the ZIP asset family this manifest installs. The checkver script now selects only releases containing both supported x64 and ARM64 ZIPs, and digest lookup targets that exact release tag.
  - `crow-translate.json`: directory listing placed 4.0.2 before 4.1.0, so the default first-match checkver selected a stale version. Enabled reverse matching to select the last (newest) version directory.
  - `PdfCraftTool.json`: updated to the verified v2026.10.29-664f501 portable ZIP and its published SHA-256; tightened version detection to capture the complete release tag.
  - `pulse.json`: followed the upstream rename/move from `Regncreative/Pulse` to `Regncreative/PulseDiagnostics`, using the official 1.6.1 ZIP and published SHA-256.
  - `rqbit.json`: updated to the verified 9.1.0 Windows MSI asset and published SHA-256.
  - `nglide.json`: the old version regex matched a bare dot, producing an invalid `nGlide_setup.exe` URL. It now parses the numeric segments from the actual `nGlide210_setup.exe` filename and formats them as `2.10`.
  - `volumey.json`: added the verified architecture-specific hash for 2.1.0.0, avoiding the null hash-property failure in Scoop's architecture-specific updater.
  - `voicestudio.json`: corrected the Windows x64 asset filename for v0.5.7 and set its published SHA-256.
  - `kvrt.json`: the direct Kaspersky endpoint returns HTTP 403 on hosted runners. The manifest now uses the bucket's separately verified KVRT backup release and its matching digest; its version detector reads the `Product/database version` from the verified release metadata so a new database build triggers an update even when the executable version stays unchanged.
  - `wallpaper-changer.json`: upstream v6.0 renamed the application to KokoroPaper and changed the package layout. The existing manifest still expects the legacy `Wallpaper.Changer_*_x64-setup.exe` extraction path, so checkver now selects only releases that actually contain that compatible asset rather than generating a broken URL for v6.0.
  - `winbin2iso.json`: its old download-page regex no longer matches. Checkver now reads the official history page, which identifies version 6.79 as the newest release.
- Seven Eric Zimmerman manifests had no current hash while their update templates attempted architecture-specific hash processing. Added a hash-seeding step to Excavator that downloads each official ZIP, verifies a ZIP header and a plausible file size, computes SHA-256, writes it to the correct property, and commits those changes before Excavator runs. Four were then filled from matching current manifests in ScoopInstaller/Main, ScoopInstaller/Extras, and scoop-lemon: Registry Explorer 2026.10.2, RECmd 2026.10.3, JumpList Explorer 2026.10.2, and ShellBags Explorer 2026.10.2. The remaining three use the hash-seeding step because the published upstream page does not include their current /net archive digests. Adjusted JLECmd and RECmd to use explicit x64 architecture update URLs.
- The isolated autoupdate validation now calculates missing checksums inside its temporary test copy only, so it can exercise Scoop's update logic without silently changing repository files or failing on a missing initial hash.
- A revision temporarily removed schedules from Excavator and KVRT while making the other manifest workflows manual-only. The Excavator schedule was subsequently restored to `20 */4 * * *` while retaining `workflow_dispatch` in commit [`30f1473`](https://github.com/kiro5678/kirobucket/commit/30f14735b8645e4fe27efde18970ccf0a0baa40a). Manifest Pipeline, FxSound, and KVRT remain manual-only; issue and pull-request handlers remain event-driven.
- Follow-up run [40937895613](https://github.com/kiro5678/kirobucket/actions/runs/40937895613) failed on `eric-recmd` before checksum seeding was added to the isolated test path. The later run [40947580501](https://github.com/kiro5678/kirobucket/actions/runs/40947580501) successfully seeded the remaining Eric Zimmerman hashes and then correctly failed at `nglide` when it tried the obsolete `nGlide200_setup.exe` URL (HTTP 404). That run also logged a `registry-finder.com` HTTP 502, which still needs a later recheck.


### 2026-10-29 — Excavator run 40947580501 follow-up fixes

- Run [40947580501](https://github.com/kiro5678/kirobucket/actions/runs/40947580501/job/123706895057) proves that `THROW_ERROR: 1` is working: the `Excavate` step ended with exit code 1 instead of reporting a false success.
- The hash-seeding step calculated and pushed SHA-256 values for `eric-sbecmd`, `eric-lecmd`, and `eric-jlecmd`. Review of commit `e367885` found that string `Replace` modified every identical URL line, placing a fixed hash under `autoupdate.architecture.64bit` for JLECmd. Removed that unsupported template hash and changed the seeding logic to update only the first/current URL occurrence.
- `nglide.json` used the old `/downloads/nglide/nGlide210_setup.exe` URL, while checkver selected the old `nGlide200_setup.exe` entry and then failed with HTTP 404. Updated the current/autoupdate URLs to the official `/files/nglide/nGlide210_setup.exe` asset, changed version detection to read the official page's version label, and used the SHA-256 listed in Microsoft's WinGet manifest for nGlide 2.10.
- Static verification after these commits confirmed that `nglide.json` and `eric-jlecmd.json` parse as JSON, JLECmd's `autoupdate` section no longer contains a hash, and Excavator still has both the four-hour schedule and manual trigger. A regex test against the page's displayed `Version: 2.10` text caught and corrected a double-escaped dot; the check now captures `2.10` in that test. The new manifest fixes have **not** yet been verified by a fresh live workflow run.


### 2026-10-29 — Review of Excavator failures query and run 40949823034

- The linked run [40937895613](https://github.com/kiro5678/kirobucket/actions/runs/40937895613) is **Scoop Autoupdate Validation**, not Excavator. It failed on `eric-recmd.json` with a null-valued `.GetType()` issue at commit `72a1258`, before the temporary hash-seeding fix was present. Treat it as historical, not as evidence against the current fix.
- The failure-filtered Actions history contains older failures [40947580501](https://github.com/kiro5678/kirobucket/actions/runs/40947580501) and [40640731310](https://github.com/kiro5678/kirobucket/actions/runs/40640731310). The latter ran on 2026-10-28 and includes widespread GitHub API 403 rate-limit responses, an obsolete nGlide URL, and unrelated legacy checkver misses.
- Current run [40949823034](https://github.com/kiro5678/kirobucket/actions/runs/40949823034), running commit `606a51f`, completed with **success**. The hash-seeding step and Excavator action both completed successfully, and the run committed updates for RPCS3, SaveState, UniGetUI Portable, and UniGetUI Global.
- That successful run still logged two nonfatal checkver problems: the old nGlide regex did not match the official download page, and `registry-finder.com` returned HTTP 502. Fixed nGlide afterward in commit [37a7353](https://github.com/kiro5678/kirobucket/commit/37a735367c1265addda0ccf2a599224fa0d58723) by reading the version from the official Zeus Software homepage/news listing and confirmed the regex captures `2.10` against the currently published news text. This change has not yet been exercised by a fresh Excavator run.
- The official Registry Finder homepage and `/version_history.html` both returned 502/timeouts during rechecking; left its official URL/source unchanged rather than switching to an unverified mirror. Recheck it in the next run.
- Added an authoring rule clarifying that `THROW_ERROR: 1` makes actual update exceptions fatal, but a Scoop checkver regex no-match or failed source fetch may be logged and skipped without failing the action. A green conclusion alone does not certify every manifest's version lookup.


### 2026-10-29 — Prevent false-success results in Excavator

- Root cause: `THROW_ERROR: 1` alone does not guarantee that every manifest's version check fails the workflow. Scoop's `checkver.ps1` can print a `couldn't match` message or a failed-source URL, then continue through the remaining manifests. Its `next()` helper logs these diagnostics and continues; `ThrowError` mainly makes exceptions during the update path fatal.
- Updated `.github/workflows/excavator.yml` to check out a pinned revision of `ScoopInstaller/GithubActions` (commit `5bceeda181721d9d10a18fdcc3ddca6f33467ae6`), run its `action.ps1` in a child PowerShell process, and capture both stdout and stderr. The workflow now fails if the action exits nonzero **or** the captured log contains a skipped checkver/update diagnostic, including version-regex no-match, an invalid URL, HTTP 403/404/408/429/5xx, or a failed update/hash operation.
- This guard is intended to prevent an Excavator run from showing **success** while known checkver/source errors were logged and skipped. The workflow retains both its manual trigger and four-hour schedule (`20 */4 * * *`).
- Verification status: the change and nGlide detector have been reviewed statically, but no new live Excavator run has yet verified the latest commits. The Registry Finder official site returned HTTP 502/timeouts during the last check, so a subsequent run may fail on that source until it recovers.


### 2026-10-29 — Restore Detect It Easy release API lookup

- Investigation confirmed that `.github/workflows/inspect-mumuplayer-installer.yml` was not deleted. It was added on 2026-10-14 as a static installer-inspection workflow. Its first revision queried `https://api.github.com/repos/horsicq/DIE-engine/releases/latest` to find the latest matching Windows x64 portable asset.
- Commit [`ebc4195`](https://github.com/kiro5678/kirobucket/commit/ebc4195126e7131902e59c387b84bc8e3e46e7ea) replaced that dynamic lookup with a pinned 3.21 URL to avoid API rate limiting. Commit [`643e05f`](https://github.com/kiro5678/kirobucket/commit/643e05f2b23b47d518061590eac1d5e4e832c219) later removed only the workflow's `push` trigger, keeping manual dispatch available.
- Restored the latest-release API lookup in commit [`8b8eeac`](https://github.com/kiro5678/kirobucket/commit/8b8eeaca146e18931fbc7e0516e77dc487d960f7), adding `GITHUB_TOKEN` authentication, bounded retries, matching-asset validation, ZIP-header/size checks, and SHA-256 verification when GitHub publishes an asset digest. Fixed the token-expression escaping in commit [`76d8fa3`](https://github.com/kiro5678/kirobucket/commit/76d8fa3d75e9e2df4385060ad36218a0fb1aa751). The workflow remains manually triggered and continues to scan the verified MuMuPlayer installer without executing it.
- A separate `.github/workflows/detect-it-easy-api.yml` file was not found in the workflow path history. The likely remembered feature was the API-based release lookup embedded in `inspect-mumuplayer-installer.yml`. The restored change has been reviewed statically but has not yet been tested in a new workflow run.

### 2026-10-30 — Multi-engine installer type identification

- Added [.github/workflows/detect-it-easy-api.yml](https://github.com/kiro5678/kirobucket/blob/master/.github/workflows/detect-it-easy-api.yml) as a manual-only workflow (workflow_dispatch; no push or schedule trigger). It accepts a direct HTTPS download URL, an optional local filename, and an optional expected SHA-256.
- The target is downloaded but **never executed or extracted**. The workflow calculates SHA-256 and collects Authenticode status, signer, product name, description, and file version.
- Improved identification beyond a default Detect It Easy scan:
  - Runs the current Windows x64 portable Detect It Easy tool selected from the official latest-release API, validating the archive signature and its published GitHub SHA-256 digest when available.
  - Invokes diec.exe with deep scanning (-d), heuristic scanning (-u), verbose output (-b), and all file types (-a).
  - Performs an independent PowerShell signature pass for PE files, OLE Compound Files, Microsoft CAB, ZIP-compatible archives, 7-Zip and RAR signatures, plus MSIX/APPX manifest entries when the target is a readable ZIP package.
  - Uses Windows Installer COM in read-only mode for .msi, .msp, and .msm files; for MSI files it attempts to read product name/version, manufacturer, and product code.
  - Scans the file in chunks for common installer-family markers, including Inno Setup, NSIS, WiX Burn, InstallShield, Advanced Installer, InstallAware, InstallAnywhere, Wise, InstallForge, Setup Factory, BitRock/InstallBuilder, Qt Installer Framework, Squirrel, 7-Zip SFX, Actual Installer, and Clickteam Install Creator.
- The string markers are explicitly reported as heuristic candidates, not definitive classifications. Container recognition is not taken as proof of a portable application; an EXE or archive signature does not establish install behavior.
- Research notes: the [Detect It Easy project](https://github.com/horsicq/Detect-It-Easy) describes a signature/heuristic-based static file-identification engine, and its CLI documents deep and heuristic scan options. [Universal Extractor 2](https://github.com/Bioruebe/UniExtract2) advertises scan-only identification and lists many installer families in its [format table](https://github.com/Bioruebe/UniExtract2/blob/master/docs/FORMATS.md), but its latest published GitHub release is v2.0.0-rc.3 from 2020 and its release API entry does not publish an asset digest. It was therefore evaluated as a reference, not added as an unverified/stale binary dependency.
- The workflow produces a signature report, a deep/heuristic Detect It Easy report, step summaries, and the downloadable installer-type-inspection-report artifact. Verification so far is static: the latest file was read back from master and the manual trigger, both identification paths, read-only MSI inspection, and report artifact were checked. **No live Actions run has yet tested the full workflow against a user-supplied installer URL.**

### 2026-10-31 — Scoop authentication and GitHub API validation changes

- **Commit `de54ed5`:** Added `CHECKVER_GITHUB_TOKEN` as the preferred token, with fallback to `github.token`, when checking out `ScoopInstaller/Scoop` in:
  - `.github/workflows/ci.yml`
  - `.github/workflows/scoop-checkver-validation.yml`
  - `.github/workflows/scoop-autoupdate-validation.yml`
  The purpose was to address the `Checkout Scoop` failure with `API rate limit exceeded for installation`, which occurred before the Scoop tests began.
  [Commit](https://github.com/kiro5678/kirobucket/commit/de54ed5001db6c0b37eb1be720e652fd97ca934f).

- **Commit `86d2f18`:** Updated the `GITHUB_TOKEN` environment variable in `scoop-checkver-validation.yml` so that Scoop's Checkver script also uses `CHECKVER_GITHUB_TOKEN || github.token` for GitHub API requests, rather than limiting authentication to the checkout step.
  [Commit](https://github.com/kiro5678/kirobucket/commit/86d2f1870d79ba7cb84605c53bb764615cb21dc5).

- **Commit `3de0205`:** Added `.github/workflows/verify-scoop-api-auth.yml` to run CI and then validate Checkver separately for `bucket/fig.json` and `bucket/nook.json`, monitoring the child runs and confirming their completion on `master`.
  [Commit](https://github.com/kiro5678/kirobucket/commit/3de0205d5c0090937da6be35f1e28fd947afdff9).

- **Verification result:** CI ran on commit `3de0205` in [41197637353](https://github.com/kiro5678/kirobucket/actions/runs/41197637353), and both PowerShell and pwsh failed during `Checkout Scoop` with `API rate limit exceeded for installation`. The actual Scoop tests did not start. The new verification workflow started in [41197628621](https://github.com/kiro5678/kirobucket/actions/runs/41197628621), but stopped after CI failed, so it never reached Fig or Nook Checkver validation.
- **Status:** The code changes and test log were added, but the GitHub API rate-limit issue **remained unresolved and had not been proven fixed**. There was no operational evidence yet that `CHECKVER_GITHUB_TOKEN` worked for checkout; the available logs also did not establish whether the secret existed.
- **Note:** Falling back to `github.token` does not guarantee that the rate limit will be avoided if `CHECKVER_GITHUB_TOKEN` is not configured or is not used successfully. Do not consider the verification workflow or checkout successful until Scoop checkout and the CI/Checkver tests complete on the amended commit.



### 2026-10-31 — Pipeline improvements and workflow validation

#### Run CI once per manifest batch
- **Commit [8cf8a91](https://github.com/kiro5678/kirobucket/commit/8cf8a91ebec5ae0283b366528786ba4be1d67105):** Moved the `ci.yml` invocation to after the manifest-processing loop in `manifest-pipeline.yml`.
- Pipeline now runs the validation stages for each manifest first, then invokes CI only once if the manifest list is not empty. This prevents the full CI suite from running once per manifest when a single push contains multiple manifest files.
- **Test status:** The invocation location and `$manifestPaths.Count -gt 0` guard were reviewed statically. No Pipeline run associated with this commit appeared in the available Actions history, so a single push containing multiple manifests has not yet been tested end to end.

#### Prevent cancellation of an active manifest-table update
- **Commit [5f26826](https://github.com/kiro5678/kirobucket/commit/5f26826b907cdf69295b8effbb85ec3636e77244):** Changed `cancel-in-progress` in `.github/workflows/manifest-table.yml` from `true` to `false`, keeping the same concurrency group.
- This prevents a newer run from cancelling a table update that has already started. GitHub Actions still retains only one pending run per concurrency group; a newer run can replace another run that is still pending.
- **Test result:** [Run 41204460600](https://github.com/kiro5678/kirobucket/actions/runs/41204460600) — the manifest-table update workflow completed successfully after the commit. Checkout, table generation, and file commit steps all passed.

#### Unify Checkver authentication and pin the Scoop ref
- **Commit [82534c1](https://github.com/kiro5678/kirobucket/commit/82534c128134b3f4f19c8931cc04712d42ebe4a0):** In `scoop-checkver-validation.yml`:
  - Pinned the `ScoopInstaller/Scoop` checkout reference to the `master` branch instead of relying on checkout to discover the default branch.
  - Unified the `GITHUB_TOKEN` variable in the Checkver step to use `secrets.CHECKVER_GITHUB_TOKEN || github.token`, matching the checkout and Checkver setup steps.
  - Added a separate `CHECKVER_GITHUB_TOKEN` variable to preserve the requirement for a dedicated PAT when requesting a full-repository check; the API-request fallback does not remove that requirement.
- **Test results:**
  - [Run 41204936131](https://github.com/kiro5678/kirobucket/actions/runs/41204936131) — Checkver passed in both PowerShell and pwsh; Scoop checkout, authentication, and validation steps succeeded in both engines.
  - [Run 41205112575](https://github.com/kiro5678/kirobucket/actions/runs/41205112575) and [Run 41205289517](https://github.com/kiro5678/kirobucket/actions/runs/41205289517) — Checkver also completed successfully in both engines on the later branch head.
- These results confirm that the cited runs succeeded without visible checkout or authentication errors. They do not, by themselves, prove that every future GitHub API rate-limit condition has been eliminated.

#### Add an independent validator for GitHub Actions workflow files
- **Commit [60fedd2](https://github.com/kiro5678/kirobucket/commit/60fedd2cb4b9d4c4db62c358345455a733d9cda1):** Added `.github/workflows/validate-workflows.yml`.
- The validator runs on:
  - Pushes to `master` that include changes under `.github/workflows/**`.
  - Pull requests targeting `master` that include changes under the same path.
  - Manual `workflow_dispatch` triggers.
- The workflow installs `actionlint` version `1.7.12` and checks all GitHub Actions workflow files in the repository. Its permissions are limited to `contents: read`; it does not run application workflows or modify manifests.
- **Test result:** [Run 41205075323](https://github.com/kiro5678/kirobucket/actions/runs/41205075323) — installation and validation of all workflow files passed; the job conclusion was `success`.
- **Additional validation runs on the same commit:** [Archive validation 41205166964](https://github.com/kiro5678/kirobucket/actions/runs/41205166964), [Autoupdate validation 41205203402](https://github.com/kiro5678/kirobucket/actions/runs/41205203402), and [Format manifests 41205251867](https://github.com/kiro5678/kirobucket/actions/runs/41205251867) all completed successfully. These were separate runs; they do not mean that actionlint executed the functional tests for those systems.

#### Overall status and verification limits
- The following changes were saved to `master`: run CI once per batch, prevent cancellation of an active table update, unify Checkver token configuration and pin the Scoop reference, and add the independent actionlint check.
- Successful Actions results are recorded for table updates, Checkver, actionlint, archive validation, autoupdate validation, and manifest formatting.
- An end-to-end test is still needed to prove that `ci.yml` runs only once for a single push containing two or more manifest files. The change was implemented, but no run demonstrating this scenario has been recorded here.
- This section was appended to the end of the log. No earlier records or sections were deleted or modified.

### 2026-10-31 — Identify the Now Bar installer type; do not use #/dl.7z

- **Objective:** Identify the type of `nowbar-setup.exe` for release `v0.4.1` before selecting the Scoop installation method.
- **Test file:** `https://github.com/nixesty/now-bar/releases/download/v0.4.1/nowbar-setup.exe`.
- **Verified SHA-256:** `e9c6c29f58b10f8c3ddc7c7c404de971d7036329de0e5493db9fa3f29a06172b`.
- **Detect It Easy 3.21 result** in [Run 41207438698](https://github.com/kiro5678/kirobucket/actions/runs/41207438698):
  - `PE64`
  - `Compiler: Rust`
  - `Library: Direct2D`
  - `Library: OpenGL`
  - `Debug data: Records[codeview]`
  - The DIE result did not identify NSIS or Inno Setup.
- **Authenticode result:** `NotSigned`. The file was downloaded and statically inspected only; it was not executed.
- Upstream source inspection confirms that `setup/src/main.rs`, `setup/src/install.rs`, and `setup/src/uninstall.rs` implement a custom Rust/Slint installer that extracts the payload, copies the EXE, writes startup settings and shortcuts, and records uninstall information. It is not an NSIS or Inno installer.
- A previous 7-Zip 26.04 test recognized the file as a PE and extracted 20 items, but did not reveal `nowbar.exe` or `nowbar-settings.exe`. Do not treat `Type = PE` as proof that the file is an extractable installer archive, and do not add `#/dl.7z` merely because 7-Zip can extract items from a PE file.
- The correct Scoop method for this release is to download the two official release files, `nowbar.exe` and `nowbar-settings.exe`, directly into the same application directory, using each file's published SHA-256. The application requires both files side by side; do not use or execute `nowbar-setup.exe` in the manifest.
- Updated `bucket/now-bar.json` to state that the official installer is a custom Rust/Slint installer and does not use `#/dl.7z`. Classified Now Bar as Portable in `docs/manifest-portability.md` because the manifest downloads the application files directly and does not run the Windows installation routine.
- **Manifest validation results:** [Checkver 41206687666](https://github.com/kiro5678/kirobucket/actions/runs/41206687666), [Archive validation 41206750389](https://github.com/kiro5678/kirobucket/actions/runs/41206750389), [AutoUpdate validation 41206788998](https://github.com/kiro5678/kirobucket/actions/runs/41206788998), and [README manifest table 41206673761](https://github.com/kiro5678/kirobucket/actions/runs/41206673761) all completed successfully.
- A temporary diagnostic workflow was added to run DIE against this file only, then removed after recording the result. The general-purpose `.github/workflows/detect-it-easy-api.yml` workflow remained unchanged.


## 2026-10-31 — Verify the Nook installer type and Scoop packaging method

- **Manifest:** `bucket/nook.json`, version `0.2.1`.
- **Confirmed installer type:** Inno Setup, not NSIS. The source file `installer/nook.iss` at tag `v0.2.1` contains Inno Setup sections such as `[Setup]` and `[Files]`. The `installer/build.ps1` script requires Inno Setup 6.7 or later and invokes `ISCC.exe` to generate `Nook-Setup-0.2.1.exe`.
- **Release verification:** GitHub Release `v0.2.1` publishes `Nook-Setup-0.2.1.exe` with the declared SHA-256 `00d6cc4bd58d3fd14fe6ceef9002f39ef60348dc03aa808dbc9120a1cce03446`, which matches the current manifest value.
- **Appropriate Scoop method:** Keep `innosetup: true`. Scoop uses `Expand-InnoArchive` and the `innounp` helper to extract `{app}` contents into the Scoop version directory instead of running the original installer. Do not use `#/dl.7z` for this file.
- **Expected file layout from the source script:** `nook.exe` and `LICENSE.txt` are at the root of `{app}`, so the current Start Menu shortcut to `nook.exe` matches the path created by the Inno script.
- **System behavior:** The Inno script registers the `nook://` protocol under HKCU and offers a run-at-login task. Scoop's extraction does not execute the installer `[Registry]` or `[Run]` sections; the application itself registers the protocol when launched. The manifest remains **Nonportable** in the project inventory because the application registers the protocol under HKCU at runtime.
- **Operational verification:** Updating the manifest will trigger Manifest Pipeline, which uses the same `innounp` helper and checks the download, SHA-256, presence of `{app}` files, and launch paths. Do not record extraction or installation as successful until Archive Validation has completed.


## 2026-11-01 — Correct a one-character SHA-256 mismatch in Nock

- **Manifest:** `bucket/nock.json`, version `0.12.10`.
- **Problem:** The manifest hash was `21744b1c9c21485d4d7922eecea67367db7870bdc964611108a459d2dbadd5cc`, but the official GitHub release asset `Nock-portable-0.12.10.exe` publishes digest `sha256:21744b1c9c21485d4a7922eecea67367db7870bdc964611108a459d2dbadd5cc`. The two values differ at one hexadecimal character.
- **Cause:** The version/checkver and archive-path tests do not necessarily recompute an existing pinned hash when the version has not changed. A successful checkver result must not be treated as proof that the manifest hash is correct.
- **Resolution:** Updated only the manifest SHA-256 to the exact digest published in the official GitHub Release API. The official asset name, URL, version, `bin`, and shortcut remain unchanged.
- **Required verification:** Run the manifest pipeline after the correction; confirm the official asset download hash and Scoop validation succeed. Do not claim an installation test solely from release metadata.


## 2026-11-01 — Verify Halo portable ZIP layout and bundled .NET runtime

- **Manifest:** `bucket/halo.json`, version `4.2.3`.
- **Original gap:** The manifest downloaded the publisher's portable ZIP but had no `extract_dir`, `bin`, or shortcut because the archive's internal layout had not been independently established. Do not guess an EXE path from a product name.
- **Official asset:** `DynamicWinPortable.zip` from the upstream v4.2.3 GitHub Release. Its published digest `ba3270f23b22344301168239396f00e9f4ace223dd519dc62025e08742faa085` matched the downloaded archive in the Windows extraction workflow.
- **Extraction result:** [Notch Package Extraction Test 41279999730](https://github.com/kiro5678/kirobucket/actions/runs/41279999730) passed. The archive contains `Halo/Halo.App.exe`, `Halo/Halo.Hooks.exe`, and `Halo/Halo.Settings.exe`. Upstream `src/Halo.App/Halo.App.csproj` declares `OutputType=WinExe`, establishing `Halo.App.exe` as the main application executable.
- **Runtime verification:** The extracted `Halo` folder contains `coreclr.dll`, `hostfxr.dll`, `hostpolicy.dll`, and `System.Private.CoreLib.dll`. `Halo.App.runtimeconfig.json` declares `Microsoft.NETCore.App` 9.0.18 in `includedFrameworks`; `Halo.Settings.runtimeconfig.json` declares both `Microsoft.NETCore.App` and `Microsoft.WindowsDesktop.App` 9.0.18 as included frameworks. The package therefore includes its required runtime and does not need a separate Desktop Runtime suggestion.
- **Resolution:** Set `extract_dir` to the actual archive wrapper directory `Halo`, declare `bin: Halo.App.exe`, and create the `Halo` shortcut for that executable. Do not point the shim or shortcut at `Halo.Hooks.exe` or `Halo.Settings.exe`; those are companion processes. The vendor setup executable remains unused.
- **Scope:** The test verified download, checksum, extraction layout, and runtime packaging. It did not execute the application or verify interactive desktop behavior.


## 2026-11-01 — Correct WinDynamicIsland .NET runtime dependency

- **Manifest:** `bucket/windynamicisland.json`, version `1.0.0`.
- **Problem:** The manifest described the release as self-contained and did not declare a .NET prerequisite. The actual extracted `WinDynamicIsland.runtimeconfig.json` declares `Microsoft.NETCore.App` version `8.0.0` under `runtimeOptions.framework`, not under `includedFrameworks`. The package inventory contains the app executable, `.deps.json`, and `.runtimeconfig.json`, but no `coreclr.dll`, `hostfxr.dll`, or `hostpolicy.dll` runtime files.
- **Cause:** The release workflow labels the ZIP self-contained, but runs `dotnet publish ... -p:Platform=x64` without `--self-contained true` or an equivalent property. The project targets .NET 8 and declares `RuntimeIdentifier=win-x64`; starting with .NET 8, a RuntimeIdentifier alone no longer makes the app self-contained. The project property `WindowsAppSDKSelfContained=true` covers the Windows App SDK component, not the separate .NET runtime.
- **Evidence:** The upstream `WinDynamicIsland.csproj` has `TargetFramework=net8.0-windows10.0.19041.0`, `RuntimeIdentifier=win-x64`, and `WindowsAppSDKSelfContained=true`, with no `SelfContained`/ `PublishSelfContained` declaration. The upstream `.github/workflows/release.yml` publishes without `--self-contained true`. The package audit log showed `WinDynamicIsland.runtimeconfig.json` with `framework.name=Microsoft.NETCore.App` and `framework.version=8.0.0`.
- **Resolution:** Removed the unsupported self-contained claim, added the `.NET 8 Runtime` suggestion `versions/windowsdesktop-runtime-8.0`, and documented that the Windows Desktop Runtime installer includes the base .NET Runtime (the app does not itself request `Microsoft.WindowsDesktop.App`). The app EXE path and portable ZIP/hash remain unchanged.
- **Required verification:** Keep an automated check that parses `WinDynamicIsland.runtimeconfig.json` and verifies the external framework name/version. The package extraction workflow does not execute the app.


## 2026-11-01 — Record PILLAR WebView2 runtime prerequisite

- **Manifest:** `bucket/pillar.json`, version `0.1.4`.
- **Problem:** The manifest extracts the NSIS app payload and skips all vendor setup routines. PILLAR is a Tauri 2 application that depends on Microsoft Edge WebView2, so a user on a stripped/custom Windows image without WebView2 may not be able to launch it after Scoop extraction.
- **Evidence:** Upstream `src-tauri/Cargo.toml` uses `tauri = "2"`; `src-tauri/tauri.conf.json` does not set `bundle.windows.webviewInstallMode`, so Tauri v2 uses its default `downloadBootstrapper` installer mode. The package test confirms the extracted NSIS payload contains the app executable but does not execute the installer. Tauri's Windows installer documentation explains the WebView2 bootstrapper behavior and notes WebView2 is distributed with Windows 10 version 1803+ and Windows 11: https://v2.tauri.app/distribute/windows-installer/ and https://v2.tauri.app/start/prerequisites/.
- **Resolution:** Added an explicit manifest note that Scoop does not run the vendor bootstrapper. Documented that WebView2 is normally present on Windows 10 1803+ and Windows 11, and that stripped/custom images may need the Microsoft Evergreen Runtime installed manually: https://developer.microsoft.com/microsoft-edge/webview2/.
- **Scope:** The test confirms the PILLAR installer payload and main EXE path; it does not launch the application or prove WebView2 is available on the target machine.


## 2026-11-01 — Preserve user Snap Layouts preference during Dynamic Island uninstall

- **Manifest:** `bucket/windows-dynamic-island.json`, version `0.8.0`.
- **Problem:** The earlier `pre_uninstall` removed `HKCU\\Software\\Microsoft\\Windows\\CurrentVersion\\Explorer\\Advanced\\EnableSnapBar` whenever the application's `TweaksVersion >= 2`. The upstream application itself documents that a user who changes this setting back after the first run is respected, but the Scoop uninstall script could delete that user change.
- **Resolution:** Added `pre_install` logic that captures whether `EnableSnapBar` existed and its DWORD value before the app's first run, preserving that backup across upgrades. If `TweaksVersion >= 2` already exists before Scoop captures a backup, the manifest marks the prior state as unknown. On uninstall, it restores/removes the original value only when the current value is still the app-applied `0` and a valid first-run backup exists. If the user changed the value, the backup is incomplete, or the app had already applied the tweak before Scoop took ownership, the current value is preserved instead of guessing. The app's user data and remaining notification/scheduled-task state continue to be preserved.
- **Required verification:** Run the manifest pipeline and parse both PowerShell lifecycle scripts with PowerShell's AST parser. The extraction workflow alone does not exercise registry lifecycle behavior.


## 2026-11-01 — Make Dynamic Island uninstall safe when registry keys are absent

- **Manifest:** `bucket/windows-dynamic-island.json`, version `0.8.0`.
- **Problem:** `pre_uninstall` read `TweaksVersion`, `ScoopSnapBarBackupCaptured`, and `EnableSnapBar` before checking whether the corresponding per-user registry keys existed. A package removed before first launch, or an older/manual install without those keys, could emit errors during cleanup.
- **Resolution:** Initialize the values as `$null`, check `Test-Path` for each registry key, and read values only when that key exists. Missing state now follows the preserve-safe path; cleanup commands remain best-effort.
- **Required verification:** PowerShell AST validation runs in the Notch Package Extraction Test workflow. This parser check confirms syntax, not live registry behavior; a real lifecycle test would require a disposable Windows user profile/VM.


### 2026-11-03 — Correct stale MSI filename in the CrowdSec manifest

- **Status:** Resolved, Scoop validation pending.
- **Affected area:** `bucket/crowdsec.json`.
- **Problem:** The manifest's current download URL and SHA-256 were for CrowdSec `1.8.2`, but `installer.file` still named `crowdsec_1.8.1.msi`. The installer file name did not match the versioned MSI asset.
- **Root cause:** The stale literal `installer.file` value was left behind when the download URL moved to `1.8.2`. Inspection of Scoop's current `lib/install.ps1` confirms that it uses `installer.file` literally (or falls back to the downloaded URL filename); it substitutes `$version` in `installer.args`, not in `installer.file`.
- **Resolution:** Removed `installer.file` from the manifest. Because the URL points directly to the correct MSI asset, Scoop can use the downloaded filename automatically. The `/quiet` and `/norestart` arguments remain unchanged.
- **Verification:** Confirmed that the official `v1.8.2` release publishes `crowdsec_1.8.2.msi` and that its SHA-256 matches the manifest. Parsed the edited manifest as JSON and read it back from the PR branch; the stale `installer.file` field is absent. Scoop's checkver/autoupdate pipeline and an actual MSI installation were not run, so the runtime install path remains to be validated.
- **Prevention:** Do not place `$version` in `installer.file`. Omit the property when the downloaded URL is itself the installer; otherwise set the actual extracted filename literally. Check Scoop's current installer implementation when uncertain.

### 2026-11-05 — Extract TwinDesk's nested NSIS application payload without running vendor hooks

- **Manifest:** `bucket/twindesk.json`, version `2.5.3`.
- **Original concern:** The earlier TwinDesk manifest remained under review because the upstream Windows setup performs per-machine system changes and requests elevation. It must not be treated as a portable executable merely because the release asset ends in `.exe`.
- **Installer type:** Upstream `windows/installer/build.js` builds a real NSIS installer with `perMachine: true` and `allowElevation: true`. The v2.5.3 Windows release publishes x64 and ARM64 setup EXEs; no MSI asset is published.
- **System changes in the vendor installer:** The upstream NSIS script adds inbound Windows Firewall rules for TwinDesk, ADB and the input helper; changes `HKLM\SYSTEM\CurrentControlSet\Services\WebClient\Parameters\FileSizeLimitInBytes`; and adds a certificate to the `TrustedPeople` certificate store. Its uninstall hook removes several of these integrations. These operations must not be silently run by Scoop.
- **Extraction evidence:** [KiroBucket NSIS extraction workflow 42105938425](https://github.com/kiro5678/kirobucket/actions/runs/42105938425) downloaded both official v2.5.3 assets and verified the declared SHA-256 values:
  - x64: `cc1fc31912350d6ea513e25e70769aba0d34643ed64ca82a67b8823b2a636b5a`.
  - ARM64: `c91e89462271e027f81bee2bb47cb15775f18d066442de9d7d3a4702dab8559e`.
  - 7-Zip extracted the outer NSIS payload. The actual application is nested under `$PLUGINSDIR/app-64.7z` or `$PLUGINSDIR/app-arm64.7z`; extracting that second-stage archive places `TwinDesk.exe` at the payload root for both architectures.
- **Resolution:** Use the verified setup EXEs with `#/dl.7z`, extract the matching `app-*.7z` from `$PLUGINSDIR` in `pre_install`, verify that `TwinDesk.exe` exists, then remove the NSIS `$PLUGINSDIR` and `$R0` leftovers in `post_install`. Do not add vendor `installer` or `uninstaller` hooks. The Scoop manifest intentionally bypasses the vendor's firewall, registry, and certificate changes.
- **User data:** Upstream sets Electron's user-data directory to `%APPDATA%\MacShare`; settings and pairing data live outside the Scoop app directory and remain after Scoop uninstall.
- **Verification limits:** The workflow downloads, hashes, lists and extracts files only; it does not execute the installer or launch TwinDesk. Scoop's Checkver, manifest archive validation, and autoupdate pipeline have not yet run for this PR; the repository's Manifest Pipeline is configured to run those checks after the active manifest reaches `master`.
- **Prevention:** For NSIS applications with nested payload archives, inspect the build configuration and installer script, then test every architecture through both extraction stages. A successful outer `#/dl.7z` extraction alone does not prove that the main application files have been placed in the Scoop directory.


### 2026-11-06 — Replace Cleanly's TEMP-extracting portable EXE with NSIS payload extraction

- **Manifest:** `bucket/cleanly.json`, version `0.2.0`.
- **Problem:** The manifest used Electron Builder's `Cleanly-portable.exe`. This target extracts the application into a Windows temporary directory when launched, so it does not keep the executable payload in the Scoop app directory as required.
- **Root cause:** The upstream `electron-builder.yml` defines separate Windows `nsis` and `portable` targets. The `portable` target is an SFX-style launcher with a temporary unpack directory; its name alone does not mean that it runs directly from the downloaded executable's location. The upstream NSIS setup is `Cleanly-setup.exe`.
- **Extraction evidence:** [Cleanly NSIS Extraction Test run 42197530617](https://github.com/kiro5678/kirobucket/actions/runs/42197530617) downloaded the official setup, calculated SHA-256 `e5ba6f90f60c39bdd05b1343358bfad3457630cde16424979760ec20d0bb302a`, and successfully listed/extracted it with 7-Zip. The outer NSIS payload exposed `$PLUGINSDIR/app-64.7z`; extracting that archive exposed `Cleanly.exe` and `resources/app.asar` at the application payload root. Neither the installer nor the application was executed.
- **Resolution:** Use the official `Cleanly-setup.exe#/dl.7z` asset with the verified SHA-256. In `pre_install`, extract `$PLUGINSDIR/app-64.7z` into `$dir` with Scoop's `Expand-7zipArchive` helper and verify both `Cleanly.exe` and `resources/app.asar`. In `post_install`, remove the unused NSIS `$PLUGINSDIR` and `$R0` leftovers. Do not run the vendor setup or use the TEMP-extracting portable target.
- **User data and cleanup:** Cleanly stores settings and encrypted API keys in Electron's per-user `userData` folder under `%APPDATA%`, outside Scoop; these data remain after Scoop uninstall. The app permanently deletes selected caches, temporary files, and logs when the user chooses those cleanup categories.
- **Verification limits:** Actionlint passed in [run 42197530631](https://github.com/kiro5678/kirobucket/actions/runs/42197530631). The extraction workflow verifies the installer hash, both extraction stages, and expected app paths only. It does not test an actual Scoop install, launch the app, or prove the app's runtime behavior. The repository Manifest Pipeline will run the Scoop archive, checkver, and autoupdate checks after the manifest is merged.
- **Prevention:** For Electron Builder apps, inspect `electron-builder.yml` and distinguish the `portable` SFX target from the NSIS setup. Test the actual setup with 7-Zip and inspect the nested payload before declaring the manifest portable or choosing an archive extraction hook.

### 2026-11-06 — Fix NectarLink NSIS setup hand-off and Scoop shim failure

- **Manifest:** `bucket/nectarlink.json`, version `0.1.4`.
- **Symptom:** Scoop reported `Can't shim 'nectarlink-desktop.exe': File doesn't exist.`
- **Root cause:** The upstream NSIS `.onInit` starts a second elevated copy with `ExecShell runas` and immediately quits the original process with exit code 0. Scoop waits for only that original process, then tries to create shims before the elevated child has completed. The upstream installer also requires its target directory to be empty before it locks the directory ACL, while Scoop initially places the downloaded setup EXE in that same directory.
- **Resolution in the manifest:** Use `installer.script` to launch a PowerShell wrapper with `RunAs` and `-Wait`. Inside that elevated process, reset the version-directory ACL, move the downloaded setup EXE from the Scoop directory to TEMP, clear stale contents so the NSIS install target is empty, and run NSIS silently with `/S /D=$dir`. After setup, verify `nectarlink-desktop.exe` and grant the original Scoop user's SID Modify permission recursively so Scoop can manage the version directory. Remove the temporary installer afterwards.
- **Uninstall/update handling:** The `uninstaller.script` runs the vendor uninstaller elevated and waits only for explicit uninstall. It skips the vendor uninstaller during `scoop update`, allowing Scoop to replace the old version without the old uninstaller deleting the new shared registry and integration state.
- **Verification limit:** The manifest JSON and source-level control flow were reviewed. A full Windows installation, shim launch, update, and uninstall cycle has not yet been run; do not describe the wrapper as runtime-tested until that cycle passes.


### 2026-11-07 — Fix Autorun Organizer shim target after Inno installation

- **Manifest:** `bucket/autorun-organizer.json`, version `7.02`.
- **Symptom:** The Inno installer returned success and Scoop linked the version directory, but Scoop then failed with `Can't shim 'AutorunOrganizer,1.exe': File doesn't exist.` The subsequent `Get-Command` message was a fallback after the target was not found under the Scoop app directory.
- **Root cause:** The manifest declared the wrong executable filename. The installed application executable is identified as `AutorunOrganizer.exe`; `AutorunOrganizer,1.exe` was an unsupported guess and is not the correct target name.
- **Resolution:** Updated both `bin` and the Start Menu shortcut to `AutorunOrganizer.exe`. Added a `post_install` existence check under `$dir` that reports any discovered EXE paths if the expected target is absent, so an incorrect layout fails before Scoop creates the shim.
- **Evidence:** Independent application inventory records `AutorunOrganizer.exe` under the normal `Autorun Organizer` install directory (https://analysepc.malekal.com/software/autorun-organizer/). Scoop's install implementation confirms that shims are created after the installer and that a missing `bin` target falls through to `Get-Command` (https://github.com/ScoopInstaller/Scoop/blob/master/lib/install.ps1).
- **Verification limits:** The manifest parses as JSON and the target is aligned with the published/observed executable name. The user's installation directory has not been inspected directly, and a second Windows install/update/uninstall cycle is still needed to confirm the actual output layout for v7.02.
- **Prevention:** Never invent EXE names for `bin` or `shortcuts`. Confirm the exact file name and relative path from the current installer payload or installed directory. Add a `post_install` guard when running a vendor installer into `$dir` so path mismatches are reported before shim creation.


### 2026-11-07 — Reconcile the under-review manifests, documentation, and validation workflows

- **Status:** Resolved, verification pending.
- **Affected area:** `docs/manifest-portability.md`, `docs/categories.md`, `.github/workflows/format-manifests.yml`, `.github/workflows/manifest-table.yml`, and `.github/workflows/manifest-pipeline.yml`.
- **Problem:** The review inventory and generated category index were out of sync: the README listed the already-promoted `twindesk`, omitted `crowdsec-windows-firewall-bouncer` and `ipban`, and the portability review table also omitted the three Visual C++ runtime manifests. The obsolete `zenbreak-msix` manifest attempted to treat an MSIX package as a 7-Zip archive without verified launch behavior. Several staged manifests contained internal review-status text in the user-facing `notes` field, contrary to `docs/manifest-authoring.md`. The newline-normalization workflow still targeted an obsolete staging-directory path. The category generator's file-link regex was case-sensitive and therefore failed to parse `FoliCon.JSON`; the manifest pipeline push filter also covered only lowercase `.json`.
- **Root cause:** The review-folder rename was not propagated to every workflow, documentation queues were maintained separately from the actual file list, and the category generator assumed a lowercase extension.
- **Resolution:**
  - Removed the obsolete `zenbreak-msix` manifest and its temporary staging placeholder.
  - Rebuilt the README and portability review tables to match the remaining 18 JSON manifests; removed the stale `twindesk` review entry and added the missing CrowdSec, IPBan, and Visual C++ entries.
  - Updated official release metadata: DeepTutor to `1.7.2`, KeptInFlow to `0.89.0`, and UDM Pro to `2.6.35`, using the official asset URLs and SHA-256 digests from [DeepTutor v1.7.2](https://github.com/HKUDS/DeepTutor/releases/tag/v1.7.2), [KeptInFlow v0.89.0](https://github.com/jwwpua/keptinflow-releases/releases/tag/v0.89.0), and [UDM Pro v2.6.35](https://github.com/Shalaby2/UDM-Pro/releases/tag/v2.6.35).
  - Removed internal review-only notes from staged manifests and kept/reworded only practical user-facing warnings for packages with service or system-wide runtime effects.
  - Restricted the newline-normalization workflow to manifests in `bucket/` only.
  - Made the category-manifest link parser case-insensitive and added an uppercase `bucket/*.JSON` push path to the manifest pipeline so `FoliCon.JSON` receives the same processing as lowercase JSON manifests.
  - Corrected the category index counts: 891 unique manifests, 95 Windows Customization entries, and 59 Sordum Suite entries.
- **Verification:** All 18 remaining review JSON files were fetched from `master` and parsed successfully. The Git tree contains 891 active bucket JSON files and 18 review JSON files. Both review documentation tables contain 18 entries; the obsolete ZenBreak reference is absent from them; the format workflow has no remaining reference to the old folder. The three updated download URLs and SHA-256 values match their exact official GitHub Release assets. Windows Scoop Checkver, archive validation, install/update/uninstall tests, and full GitHub Actions conclusions were not run or independently confirmed as part of this task.
- **Prevention:** Keep the portability review inventory synchronized with the active manifests in `bucket/`; keep CI path filters limited to active manifest locations; use case-insensitive matching for manifest extensions in documentation generation and CI filters; keep internal review reasoning in `docs/manifest-portability.md` rather than in manifest `notes`.

### 2026-11-07 — Correct JSON quoting in the staged TinyWall manifest

- **Problem:** The first committed TinyWall manifest revision was invalid JSON because the Product Id explanation contained unescaped double quotes inside a `notes` string.
- **Root cause:** A quote-bearing XML attribute expression was inserted literally within a JSON string.
- **Resolution:** Reworded the note to describe the wildcard Product Id without nested quotation marks; recorded the remaining MSI hash and elevated-lifecycle concerns in the portability review inventory.
- **Verification:** Refetched the manifest from `master`, parsed it with `JSON.parse`, and confirmed the `checkver` regex captures `3.6.1` from the official download-page version label. Confirmed TinyWall is listed in the README and portability review queue, with the review count updated to 98. No Scoop workflow or MSI installation test was run.
- **Prevention:** Avoid unescaped double quotes inside JSON string values; parse every staged manifest after creating or updating it.

## 2026-11-07 — Verify TinyWall MSI extraction, hashes, and installer side effects

- **Problem:** TinyWall 3.6.1 was staged because its official Windows distribution is MSI-only and the manifest did not yet have verified package hashes, extracted file paths, or an evidence-based install/update/uninstall strategy.
- **Investigation:** Added `.github/workflows/tinywall-msi-extraction-test.yml`. It downloads the official x86/x64 and ARM64 assets through the publisher's download links, validates their Authenticode signatures and SHA-256 values against the staged manifest, checks the official version page against `checkver`, and extracts each MSI with `msiexec /a`. It also retains the MSI files, administrative images, logs, inventories, and relevant upstream installer source files as a GitHub Actions artifact.
- **Resolution:** Updated `bucket/tinywall.json` to version `3.6.1`, the official MSI URLs with `#/dl.msi`, the verified architecture-specific SHA-256 values, and the real executable/shortcut path `ProgramFiles\\TinyWall\\TinyWall.exe`. Deliberately omitted `extract_dir` because the MSI also contains required `CommonAppData\\TinyWall` data. Updated `docs/manifest-portability.md` with the successful extraction evidence and remaining lifecycle constraints.
- **Verified package data:**
  - x86/x64 MSI: 1,847,296 bytes; SHA-256 `3f3bbdf2aef4cda3f18bd1ee7f4357a96b995fd78d98e8fd0889fd3bb592b453`; Authenticode status `Valid`.
  - ARM64 MSI: 1,884,160 bytes; SHA-256 `3cc40d26cef85340584a647f387e615d7066738ebc8743dadb0908897721663a`; Authenticode status `Valid`.
  - Both `msiexec /a` extractions returned exit code 0 and produced 36 files, including `ProgramFiles/TinyWall/TinyWall.exe`, `CommonAppData/TinyWall/profiles.json`, and `CommonAppData/TinyWall/hosts.custom`.
- **Installer behavior found in upstream source:** The WiX package runs `TinyWall.exe /install`, `/uninstall`, and controller-start actions. The service installer registers a LocalSystem service with Automatic startup. The first-run health routine creates a scheduled task for the controller. The uninstall routine asks for user confirmation, stops the service, removes persistent WFP objects, removes the task, restores the original hosts file, and unregisters the service. `AppPaths.cs` places runtime data under `%ProgramData%\\TinyWall` and per-user data under `%APPDATA%\\TinyWall`; plain Scoop extraction leaves the initial `CommonAppData\\TinyWall` files inside the version directory rather than copying them to ProgramData.
- **Verification:** Final Workflow run [42399331556](https://github.com/kiro5678/kirobucket/actions/runs/42399331556) completed successfully. It verified the official page version, both manifest hashes, both Authenticode signatures, both MSI administrative extractions, and all three required payload paths. The artifact `tinywall-msi-extraction` (ID `13584338364`) contains the downloaded MSI files, extracted payloads, source files, logs, and inventories; it is retained through 2026-11-21. LessMSI returned exit code 0 but did not expose TinyWall.exe in its output; it was not needed because the default Scoop MSI extraction path succeeded. No MSI installation, service registration, scheduled-task creation, or firewall-rule change was run on the workflow runner.
- **Promotion status:** Keep TinyWall in **Review**. The extraction and download metadata are verified, but an install/update/uninstall lifecycle that handles ProgramData seeding, the LocalSystem service, scheduled task, interactive uninstall confirmation, and WFP cleanup safely under Scoop has not been established.
- **Prevention:** For MSI manifests, inspect the complete extracted tree, not only the main executable. Do not set `extract_dir` when it would discard sibling support-data folders. Inspect WiX custom actions, service installer configuration, runtime data paths, and uninstall behavior before promoting firewall/security tools. Do not run an actual firewall installer on a generic CI runner merely to test extraction.

### 2026-11-07 — Fix and verify the ShirazAdam TinyWall archive-inspection workflow

- **Affected files:** `.github/workflows/tinywall-shirazadam-archive-inspection.yml`, `bucket/tinywall-shirazadam.json`, and `docs/manifest-portability.md`.
- **Problem:** The first archive-inspection run stopped on the x64 payload after download, SHA-256 verification, ZIP listing, and extraction. The job log showed a PowerShell exception from calling `String.Replace` with an empty old-value. The artifact upload also included downloaded ZIPs and extracted binaries, producing an unnecessarily large artifact.
- **Root cause:** JavaScript template-string escaping removed the intended backslash from the PowerShell path-normalization expression, leaving `.Replace('', '/')`. The workflow also lacked a cleanup step before uploading its report directory.
- **Resolution:** Replaced path normalization with a Windows-safe relative-path calculation using `Substring(...).TrimStart([char]92)`. Added an unconditional cleanup step that removes downloaded ZIPs and extracted payload directories before uploading the remaining CSV/JSON reports.
- **Verification:** Archive-inspection Workflow [42399489583](https://github.com/kiro5678/kirobucket/actions/runs/42399489583) completed successfully, and workflow-definition validation [42399489623](https://github.com/kiro5678/kirobucket/actions/runs/42399489623) also succeeded. The run verified all three release SHA-256 values and extracted:
  - x64: 604 files; `ModernTinyWall.exe` at archive root; PE machine `0x8664`.
  - x86: 564 files; `ModernTinyWall.exe` at archive root; PE machine `0x014C`.
  - ARM64: 600 files; `ModernTinyWall.exe` at archive root; PE machine `0xAA64`.
  - Each archive contained exactly one main executable at the declared shortcut path. No executable matching the TinyWall service host was found in any of the three archives. The final report artifact [13583849297](https://github.com/kiro5678/kirobucket/actions/runs/42399489583/artifacts/13583849297) is 119,289 bytes and contains the inspection JSON plus CSV inventories.
- **Manifest outcome:** Confirmed that the shortcut target `ModernTinyWall.exe` is correct for all three architectures. Updated the staged manifest's user-facing note and the portability inventory with the verified archive layout and the missing service-host dependency. Keep `tinywall-shirazadam.json` in **Review**; no app launch, service installation, or Windows Firewall modification was performed.
- **Prevention:** In PowerShell workflow source embedded through JavaScript/template generation, avoid backslash-sensitive string construction where possible. Keep large downloaded and extracted binaries outside artifact-upload directories or remove them before upload; retain only reports and inventories.

### 2026-11-08 — Fix SystemTrayMenu v1 manifest PR formatting lint

- **Affected files:** `bucket/systemtraymenu-v1.json` and `docs/manifest-authoring.md`.
- **Problem:** The Pull Request Handler reported `Lint: False` even though JSON/Schema, Description, License, Hashes, Checkver, and Autoupdate checks passed.
- **Root cause:** Two formatter normalizations were missing from the submitted JSON. Scoop's `formatjson.ps1` collapses a one-element array of strings (such as a single `notes` entry) into a scalar string. After correcting that field, the formatter comparison still failed because the manifest had no final line ending; `formatjson.ps1` writes the file with one final CRLF.
- **Resolution:** Changed the single `notes` entry to a scalar string and added the required final newline. Updated `docs/manifest-authoring.md` to explain single-value arrays and the final CRLF requirement.
- **Verification:** [Formatter comparison run 42506648947](https://github.com/kiro5678/kirobucket/actions/runs/42506648947) showed that the remaining difference after the `notes` correction was exactly the final line ending (2 bytes). [PR verification run 42506832827](https://github.com/kiro5678/kirobucket/actions/runs/42506832827) passed with `Lint`, `Description`, `License`, `Hashes`, `Checkver`, and `Autoupdate` all `True`. [Archive and repository test run 42505308303](https://github.com/kiro5678/kirobucket/actions/runs/42505308303) also passed archive/hash/path/version checks and Pester (6 passed, 0 failed).
- **Prevention:** Use a string for a single textual value and an array only when multiple values are needed. Ensure every bucket manifest ends with exactly one CRLF, then run the official formatter or the PR `/verify` check before merging.

### 2026-11-09 — Record the verified Pake Desktop Velopack installer type

- **Affected files:** `bucket/pake-desktop.json`, `.github/workflows/manifest-table.yml`, `docs/manifest-authoring.md`, and generated manifest indexes.
- **Problem:** The generated manifest views classified Pake Desktop as `EXE setup (engine unverified)`, even though the official x64 and ARM64 setup files had been independently identified as Velopack 1.2.158.
- **Root cause:** The index generator recognized the Scoop `##` metadata marker for Inno Setup and NSIS only. Pake's EXE URL and installer hooks therefore fell through to the generic unverified EXE label.
- **Resolution:** Added `"##": "Installer Type: Velopack Setup"` to the Pake manifest and taught `manifest-table.yml` to recognize the verified Velopack label. Updated the authoring guide so future verified installer engines are recorded in the manifest and registered with the index generator. Corrected the manual ARM64 download-size entry to match the generated size.
- **Verification:** Pake v1.4.0 x64 and ARM64 installers were statically inspected; both Authenticode signatures and SHA-256 values were verified. The x64 installer was installed and uninstalled on an isolated Windows GitHub Actions runner, with the app files and created shortcuts checked before and after removal. The ARM64 installer was verified by hash, signer, and product metadata but was not executed on an x64 runner.
- **Prevention:** When a new installer engine has been verified, record it with the `##` metadata marker and add a matching classification rule to `manifest-table.yml`. Never infer an engine from the EXE extension alone.

### 2026-11-09 — Switch Prime Files from vendor setup to Inno payload extraction

- **Status:** Resolved and verified.
- **Affected area:** `bucket/prime-files.json`, `docs/manifest-portability.md`.
- **Problem:** The manifest still executed the official Inno Setup installer and its uninstaller hooks, while the requested behavior was to use Scoop's `innosetup: true` extraction mode.
- **Root cause:** Scoop's `innosetup: true` path calls `Expand-InnoArchive` and extracts the `{app}` payload with `innounp`; it does not run the vendor's `[Run]`, shortcut, or uninstall routines. The Prime Files source confirms that its official setup can install the VC++ x64 runtime, enable Media Feature Pack on Windows N, offer optional 7-Zip installation, and create shortcuts. Its built-in updater also checks for `unins000.exe`, which an extracted payload does not create.
- **Resolution:** Added `innosetup: true` and removed the official `installer` and `uninstaller` hooks. Added explicit notes for dependencies/features skipped by extraction and documented that Scoop must manage updates. Reclassified Prime Files as Portable payload extraction in the portability inventory (Portable 808; Nonportable 63).
- **Verification:** [PR #77](https://github.com/kiro5678/kirobucket/pull/77) passed the Pull Request Handler checks (`Lint`, `Description`, `License`, `Hashes`, `Checkver`, `Autoupdate`, and `Autoupdate Hash Extraction` all `True`) and was merged as commit `c7467c6fbfb1f4c532201333f445c79e70e55b45`. [Checkver run 42598870708](https://github.com/kiro5678/kirobucket/actions/runs/42598870708), [archive validation run 42598977711](https://github.com/kiro5678/kirobucket/actions/runs/42598977711), [autoupdate run 42599054330](https://github.com/kiro5678/kirobucket/actions/runs/42599054330), and [CI run 42599133817](https://github.com/kiro5678/kirobucket/actions/runs/42599133817) all succeeded. Archive validation verified the downloaded asset SHA-256, the `innounp` helper hash, and extraction of three `{app}` files. It identified `PrimeFiles.exe` as x64, product/version `Prime Files` / `0.3.9` (42,265,600 bytes), found `prime-files-indexer.exe`, and confirmed the declared `bin` path exists. Pester passed 7 tests with 0 failures in both Windows PowerShell and PowerShell 7. The application GUI, external runtime dependencies, service installation, and real Scoop install/uninstall cycle were not tested.
- **Prevention:** When switching an Inno manifest to `innosetup: true`, remove official setup execution and generated-uninstaller hooks, inspect the upstream install-time actions, record every skipped dependency/integration, verify whether the app's own updater depends on installer-generated files, and run archive validation to confirm the extracted application executable and all declared `bin`/shortcut paths.


### 2026-11-09 — Add the missing Scoop Start Menu shortcut to Prime Files

- **Status:** Manifest and documentation updated; Windows install verification pending.
- **Affected files:** `bucket/prime-files.json`, `docs/manifest-portability.md`.
- **Problem:** Installing Prime Files through Scoop did not create a Start Menu shortcut.
- **Root cause:** The manifest used `innosetup: true`, which extracts the Inno Setup `{app}` payload without running the vendor's shortcut-creation routines, and it had no Scoop `shortcuts` declaration. The existing `bin` entry creates a command shim, not a Start Menu shortcut.
- **Resolution:** Added `shortcuts: [["PrimeFiles.exe", "Prime Files"]]` while retaining `innosetup: true` and the existing `bin` entry. Updated the user-facing note and portability inventory to distinguish the Scoop-managed Start Menu shortcut from vendor-created shortcuts.
- **Verification:** Parsed the updated manifest as JSON and confirmed the shortcut target matches the existing `bin` target. The repository's prior Prime Files archive-validation record confirms `PrimeFiles.exe` exists in the extracted `{app}` payload. A live Scoop install/uninstall test and visual Start Menu check have not been run.
- **Prevention:** When using installer-payload extraction, explicitly declare any required Scoop shortcuts; do not assume the vendor installer's shortcut actions will run. Confirm the shortcut target exists in the extracted payload before committing.

## 2026-11-09 — NetTime manifest autoupdate coverage

- **Problem and symptoms:** `bucket/nettime.json` already existed and had a valid official stable-download URL, SHA-256, Inno Setup extraction declaration, executable shim, shortcut, and stable-version check. It had no `autoupdate` section, so Excavator could detect a newer stable version but could not construct the versioned installer URL automatically.
- **Root cause:** The official installer filename removes the decimal separator from the displayed version (for example, stable version `3.14` is distributed as `NetTimeSetup-314.exe`). A plain `$version` URL template would therefore be incorrect.
- **Resolution:** Added `autoupdate.url` using Scoop's `$cleanVersion` substitution, preserving the stable-only version regex. Added a note that `innosetup: true` extracts the application payload rather than running the vendor setup, so the Windows service is not registered by this manifest; tray-client mode remains the intended extracted-app entry point.
- **Verification:** Confirmed from the official NetTime page that 3.14 is labelled the current stable version, 3.20 Alpha 3 is labelled a test version, and the installer filename is `NetTimeSetup-314.exe`. The existing SHA-256 was independently cross-checked against Microsoft's WinGet installer manifest for `MarkGriffiths.NetTime` 3.14 and matches. Confirmed the shortcut target is `NetTime.exe` and the Scoop autoupdate documentation defines `$cleanVersion` as the version with separators removed. The manifest update was committed as `04ea6803f573a301e13bbfcb80388b77735e3529`. The GitHub Actions workflow is configured to run on pushes to `bucket/*.json`, but no completed Manifest Pipeline result has been retrieved in this task.
- **Prevention / regression check:** Keep the version detector scoped to the explicit current-stable label and use `$cleanVersion` whenever an upstream installer filename omits dots from its version. Run the repository Manifest Pipeline for `bucket/nettime.json` and confirm the archive, checkver, forced autoupdate, and CI stages.
- **Status:** Manifest updated; validation is partial pending the GitHub Actions run.

### 2026-11-09 — Prevent Pake Desktop Velopack Setup from locking its Scoop install directory

- **Status:** Resolved and verified in the Windows installer regression workflow.
- **Affected files:** `bucket/pake-desktop.json`, `.github/workflows/multi-engine-installer-type-inspector.yml`.
- **Problem:** Reinstalling Pake Desktop through Scoop failed with Windows error 32 while Velopack tried to rename the existing version directory. The log showed the setup process running from inside that same directory and explicitly skipping termination of itself.
- **Root cause:** Scoop stages the downloaded installer in the app version directory and runs it there by default. Velopack replaces an existing installation by renaming its installation directory. The running `Tw93.Pake-win-x64-Setup.exe` therefore held a lock on the directory Velopack needed to rename.
- **Resolution:** Replaced the plain `installer.args` invocation with `installer.script`. The script copies the setup EXE to a unique file under `%TEMP%`, removes the copy from the Scoop version directory, then starts the temporary copy with `--silent --installto $dir` and `%TEMP%` as its working directory. It waits for the process and removes the temporary EXE afterward.
- **Verification:** The Windows regression test installed Pake, copied the official Setup EXE into the existing installation directory to simulate Scoop's staging behavior, executed the exact manifest `installer.script` with Scoop's `$dir` and `$fname` variables in scope, verified the in-directory Setup EXE was removed and the Pake/Velopack files remained after the reinstall, then completed Velopack uninstall and shortcut cleanup. [Multi-Engine Installer Type Inspector run 42687239151](https://github.com/kiro5678/kirobucket/actions/runs/42687239151) and [workflow lint run 42687239419](https://github.com/kiro5678/kirobucket/actions/runs/42687239419) passed. [Pull Request Handler run 42686688824](https://github.com/kiro5678/kirobucket/actions/runs/42686688824) also passed the manifest checks.
- **Prevention:** When a Scoop-managed installer replaces its own target directory, never run the installer executable from inside that directory. Stage it outside the target, remove the in-directory copy before launching, and set the child process working directory outside the directory being replaced.
