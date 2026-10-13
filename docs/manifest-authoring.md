# Manifest Authoring and Maintenance Rules

This is the repository's mandatory reference for creating, changing, troubleshooting, or reviewing any Scoop manifest. Read it before working on manifests. When a real failure reveals a missing rule, update this document in the same task so the lesson is not lost.

## 1. Non-negotiable rule: automatic updates must work

A manifest is not finished merely because the current version installs. By default, every manifest must support automatic version and download updates.

- Configure a working `checkver` that detects the intended release channel and extracts the version correctly.
- Configure `autoupdate` templates for the download URL and every version-dependent field, including `extract_dir` when the archive's root folder changes with the version.
- Ensure the hash will be refreshed correctly by the current Scoop updater. Never leave an old fixed hash in place while allowing the URL to move to a new version.
- Test the entire version → URL → hash update path with Scoop's actual `checkver.ps1 -Update`. A successful version lookup alone does **not** prove that automatic updating works.
- If upstream genuinely provides no reliable automatic version source, investigate the official API, release feed, or a custom `checkver.script` before considering a manual-only manifest. State the limitation explicitly rather than silently omitting update support.

`autoupdate` is a template, not a background scheduler. GitHub updates the repository manifest only when an updater such as the repository's Excavator workflow runs successfully and commits the result. User machines receive the updated manifest after their bucket is pulled with `scoop update`.

## 2. Research the upstream package before writing JSON

Use the project's official release page, repository, documentation, and release API as the source of truth.

1. Identify the latest intended stable release. Do not accidentally use a pre-release, development build, unrelated tag, or stale release.
2. Inspect the actual Windows asset names and architecture. Verify the exact URL, release tag, and available checksum/digest.
3. Determine what the downloaded file actually is: a portable archive, an installer, an Inno Setup installer, an MSI, or a standalone executable. An `.exe` extension does not prove that a file is portable.
4. Verify the archive or installer contents before choosing `bin`, `shortcuts`, `extract_dir`, `innosetup`, `depends`, or installer extraction options. Never guess internal paths or executable names.
5. Preserve the application's real settings/data location. Add `persist` only for the correct data directory or files. Migration logic must not delete or overwrite the old data; copy only when appropriate and preserve the original if copying fails.

Do not copy an existing manifest blindly. Use it as a reference only after verifying it against the current release and current Scoop behavior.

- When a canonical upstream repository or download page returns 404, verify whether the project has officially moved and whether the new location has real releases/assets. Do not replace a missing source with an unverified fork or hard-code a fake `checkver` result just to make validation pass. If no verifiable canonical download/update source remains, remove the obsolete manifest or report it as blocked.

## 3. Version detection: `checkver`

- Choose a version source that reliably follows the intended release channel.
- For GitHub releases, prefer the explicit current syntax:
  ```json
  "checkver": {
      "github": "https://github.com/OWNER/REPOSITORY"
  }
  ```
  Use the actual upstream owner and repository. Do not point it at this bucket or a fork unless that fork is the true source.
- For non-GitHub releases, use a reliable official release/download page, JSON API, XML feed, or a script. Use a regular expression or JSONPath that matches the real response and captures the intended version only.
- If `checkver` uses JSONPath, make sure the configured source actually returns JSON. With GitHub, the repository URL normally makes Scoop read the HTML `releases/latest` page; use an explicit API URL such as `https://api.github.com/repos/OWNER/REPOSITORY/releases/latest` when parsing a JSON response. Never combine an HTML source with `jsonpath`/`jp` and assume it will work.
- Make sure the extracted version matches the values used in `autoupdate`.
- Scoop's `checkver.github` mode automatically supplies a default version regex when no regex is set, including when its value is an API URL. If a JSONPath selects a non-version field such as a release name or `updated_at`, that implicit regex can cause a false no-match. For such API lookups, use an explicit `checkver.url` with `jsonpath` and define a matching regex/replacement as needed; don't assume an API URL under `github` disables GitHub defaults.
- The implicit `/releases/latest` endpoint normally skips pre-releases. For nightly, release-candidate, or other non-default channels, use an explicitly verified releases page/API and test that it selects the intended channel.
- For a mutable alias asset URL (for example, a fixed `nightly` URL), a constant manifest version will not signal that the bytes changed, so the hash may never refresh automatically. Derive the Scoop version from a reliable build/update timestamp or commit identifier when the same URL is republished, and verify that `checkver.ps1 -Update` refreshes the hash. Keep the version string compatible with Scoop/Windows version handling. For example, if `checkver` returns `2.0.1` while the release tag is `v2.0.1`, the URL template may need `v$version`. Do not add or remove a `v` without checking the actual tag and output.
- Validate version detection with the current Scoop `checkver.ps1`; do not infer success from reading the JSON.

- When matching an HTML page, write the regex against the raw HTML response that Scoop actually downloads, not a text-rendered search result. Table columns may be separate tags or whitespace rather than literal separators such as `|`; use a bounded, case-insensitive single-line pattern where necessary, then validate the extracted version with Scoop.

- Prefer native `jsonpath` plus `regex`/`replace` when those fields can extract both the release tag and app version; reserve `checkver.script` for cases the built-in fields cannot express. This reduces duplicate requests and makes normal version checks easier to debug.

## 4. Automatic URL and hash updates

- Put the current, verified download URL and SHA-256 in the applicable manifest architecture.
- Add matching `autoupdate.url` templates, using supported Scoop version variables and the actual upstream naming convention.
- Keep architecture-specific URLs and update templates aligned. Include other architectures only when the corresponding assets are actually published and verified.
- For GitHub release download URLs, check whether the current Scoop implementation can retrieve the asset digest using its native GitHub hash mode. Do not add a custom `autoupdate.hash` block by habit when native handling already works.
- For other hosting providers, only configure a hash extraction method after verifying it against the current Scoop schema and implementation. Test it. Never assume an undocumented or unsupported manifest property works.
- If the upstream does not publish a usable checksum, verify that the current updater can download the exact new asset and compute its SHA-256. Never reuse the old version's hash.
- Treat GitHub digest values such as `sha256:<hex>` carefully; verify that Scoop resolves them to the expected SHA-256 rather than copying API text into a manifest untested.

## 5. Installer, portable, and archive rules

- Portable archives should be installed from the verified portable asset directly where possible. Do not select a setup installer just because it is easier to find.
- Use `innosetup: true` and `innounp` only after confirming the asset is genuinely an Inno Setup installer and that extraction is the intended installation method.
- Never append `#/dl.7z` to an `.exe` or another URL unless the URL is intentionally handled as an archive and that exact extraction behavior has been verified.
- Set `extract_dir` to the exact directory present in the archive. Confirm the path and capitalization from the actual archive listing. If the root directory is version-dependent, update both the current value and `autoupdate.extract_dir`.
- After any upstream packaging change, rerun archive validation and inspect the reported paths before changing `bin`, `shortcuts`, or `extract_dir`; do not guess executable names or directory prefixes. For MSI assets, a generic archive listing may expose internal file IDs such as `FILE_Exe` instead of the installed target paths. Treat that as an installer payload, not a portable archive, unless a verified extraction or installation method is available.
- Do not call an app portable in the description solely because Scoop extracts an installer. Describe the actual distribution and install behavior accurately.

## 6. Required validation before considering work complete

Run the relevant checks from a disposable checkout or working copy where practical, and inspect the resulting diff.

1. **JSON/schema and bucket CI:** confirm the manifest parses and the repository's CI passes.
2. **Version detection:** run the current Scoop `checkver.ps1` against the manifest and inspect the detected version.
3. **Autoupdate simulation:** run `checkver.ps1 -Update` in a test copy. Confirm that the version, URL, hash, and version-dependent paths update correctly. A manifest that only passes a normal `checkver` lookup has not passed this test.
4. **Archive validation:** run the repository's manifest archive validation workflow. Confirm download, SHA-256, extraction, and executable-path checks succeed where applicable.
5. **Installation behavior:** where practical, install the manifest from its file path and verify that the declared executable and shortcut work. Check persistence/migration behavior when relevant.
6. **Workflow follow-through:** inspect the actual GitHub Actions runs and job logs. Do not claim a check passed while it is queued or running. Do not equate a successful archive check with a successful full CI run.
7. **PowerShell workflow exit handling:** `checkver.ps1` is a PowerShell script, not a native executable. Do not use `$LASTEXITCODE` after invoking it; that variable may be `$null` or stale and can incorrectly mark every manifest as failed. Capture its output, handle terminating exceptions, and detect Scoop's explicit no-match/download/JSON diagnostics (some checkver failures are printed without setting a native process exit code). Confirm the workflow reports realistic per-manifest results instead of counting successful version lookups as failures.
8. **Live automatic update:** inspect the latest successful Excavator run in relation to the upstream release publication time. A scheduled workflow can be delayed or missed; if necessary, manually dispatch Excavator and inspect whether it detects and commits the update.

The repository currently has these related workflows:
- `.github/workflows/excavator.yml`: scheduled/manual manifest updater; requires write permission to commit changes.
- `.github/workflows/scoop-checkver-validation.yml`: manually validates version detection and also runs when that workflow file changes. This does not by itself prove that `-Update` rewrites URLs and hashes correctly.
- `.github/workflows/validate-manifest-archives.yml`: validates downloadable assets, hashes, and archive paths.
- `.github/workflows/ci.yml`: general manifest tests.

For a local update test, run from the bucket repository root in a disposable working copy:

```powershell
$checkver = Join-Path $env:SCOOP 'apps\scoop\current\bin\checkver.ps1'
& $checkver -App taskexplorer -Dir .\bucket -ThrowError
& $checkver -App taskexplorer -Dir .\bucket -Update -ThrowError
git diff -- .\bucket\taskexplorer.json
```

Replace `taskexplorer` with the manifest basename, without `.json`. Review every changed field. Keep valid generated changes; revert accidental or incorrect changes. If Scoop is installed at a nonstandard location, resolve the actual path to its current `bin\checkver.ps1` rather than assuming the example path.

## 7. Repository-specific working rules

- Read this document first for every manifest creation, update, repair, or review task in this repository.
- Prefer verified official Scoop manifest properties and behavior over assumptions, copied snippets, or unsupported fields.
- Check the current Scoop documentation, schema, and implementation whenever a property or update behavior is uncertain.
- Before finishing, explicitly verify automatic updating—not just the current download. If it cannot be made automatic, report exactly what blocks it.
- When a task uncovers a new recurring failure or a correction to these rules, update this document as part of that task and verify the doc change in GitHub.
- Report the commit and validation links, and distinguish successful checks from checks that have not completed.

## Official references

- [Scoop App Manifests](https://github.com/ScoopInstaller/Scoop/wiki/App-Manifests)
- [Scoop App Manifest Autoupdate](https://github.com/ScoopInstaller/Scoop/wiki/App-Manifest-Autoupdate)
- [Scoop manifest schema](https://github.com/ScoopInstaller/Scoop/blob/master/schema.json)
- [Scoop checkver implementation](https://github.com/ScoopInstaller/Scoop/blob/master/bin/checkver.ps1)
- [Scoop autoupdate implementation](https://github.com/ScoopInstaller/Scoop/blob/master/lib/autoupdate.ps1)
- [ScoopInstaller/GithubActions and Excavator](https://github.com/ScoopInstaller/GithubActions)
