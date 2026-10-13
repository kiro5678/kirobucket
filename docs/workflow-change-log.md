# Workflow Change Log

Last updated: 2026-10-14 (Africa/Cairo)

This log records the workflow files changed or added during the repository-maintenance work comparing KiroBucket with other Scoop buckets. GitHub Actions run links show the status recorded by GitHub; a passing general CI run is not treated as proof that every new workflow has run end to end.

## Summary

| File | Change | Current behavior |
| --- | --- | --- |
| `.github/workflows/manifest-table.yml` | Modified | Added category mappings for existing manifests, removed eight stale mapping entries, and restored the original fallback behavior. A manifest without an explicit mapping is categorized as `Other Utilities`; it does not emit a missing-category warning or fail the workflow. |
| `.github/workflows/validate-manifest-archives.yml` | Modified | Continues validating changed/manual manifest archives and their declared paths. After a successful validation, it outputs the manifest list and the exact commit checked, dispatches an autoupdate-validation event, and still dispatches `archives-validated` for the existing CI workflow. |
| `.github/workflows/scoop-autoupdate-validation.yml` | Added | Tests the Scoop `checkver.ps1 -Update` path against a disposable copy of each supplied manifest. It can be triggered by the archive-validation dispatch or manually with `workflow_dispatch`. |
| `docs/manifest-authoring.md` | Documentation changed (not a workflow) | Documents when `-Update` exercises the URL/hash path, how to use `-ForceUpdate` safely in a disposable copy, and how the new workflows fit together. |

## 1. Manifest table workflow

File: [manifest-table.yml](../.github/workflows/manifest-table.yml)

Changes made:
- Added explicit category mappings for existing manifests that previously fell back to `Other Utilities`, including `adb-device-manager`, `astel`, `bloatynosy`, and `encryphix`, plus other previously unmapped entries.
- Removed eight stale mapping keys that did not match current manifest filenames: `crapcheckthis`, `developer-placeholder`, `pdfcraft`, `pdfcraft-exe`, `ram-cleaner-flusher-pro`, `timescribe-portable`, `unigetuiglobal`, and `windhawk-alpha`.
- A temporary strict check for unmapped categories was added during the work, then removed at the user's request. **It is not part of the current workflow.** The workflow retains its original fallback: unknown categories are labeled `Other Utilities`, without warnings or failure.

Relevant commits:
- [Add category mappings and strict check](https://github.com/kiro5678/kirobucket/commit/88d9074838448a82bbaeac0308cb886ce653c658)
- [Add additional category mappings](https://github.com/kiro5678/kirobucket/commit/738b2909ad8aab90e764c83c135e51bfef44f968)
- [Remove stale category entries](https://github.com/kiro5678/kirobucket/commit/45e0c9bcd079ffe8f88cbc2e968043251963f68c)
- [Restore non-failing category fallback](https://github.com/kiro5678/kirobucket/commit/f8c44882d5e00fa8ee2efc3a172bcfca855ff821)

Validation:
- [Latest manifest-table workflow run: success](https://github.com/kiro5678/kirobucket/actions/runs/38484025594)
- [CI after restoring the fallback: success](https://github.com/kiro5678/kirobucket/actions/runs/38484025576)

The successful table workflow regenerated `README.md` and the six generated manifest-view files under `docs/`.

## 2. Archive validation workflow

File: [validate-manifest-archives.yml](../.github/workflows/validate-manifest-archives.yml)

Changes made:
- Captures the SHA of the commit checked after resetting the working copy to the current `origin/master`.
- Exposes `validated_manifests` and `validated_head_sha` as step outputs.
- After the archive/path validation succeeds, sends a `repository_dispatch` event named `manifests-archives-validated` to start the new autoupdate-validation workflow. The payload contains the validated manifest paths and the checked commit SHA.
- Preserves the separate `archives-validated` dispatch that starts the existing CI workflow.

Relevant commits:
- [Connect archive validation to autoupdate validation](https://github.com/kiro5678/kirobucket/commit/4bffa6b1c83ed8484872bcec28749578628be18c)
- [Rebuild and repair the validated-commit output](https://github.com/kiro5678/kirobucket/commit/317ccf3ded611703729358116259c8cb6483e5d9)

Implementation history:
- Two intermediate attempts to wire the commit output produced failed workflow-file runs: [run 38441504477](https://github.com/kiro5678/kirobucket/actions/runs/38441504477) and [run 38441685973](https://github.com/kiro5678/kirobucket/actions/runs/38441685973). The file was subsequently rebuilt and the commit-capture block repaired.
- [CI after the rebuild: success](https://github.com/kiro5678/kirobucket/actions/runs/38442021855).

Caveat: the successful general CI run validates the normal bucket CI job; it does not itself prove that the archive-validation-to-autoupdate dispatch has completed successfully on a real changed manifest. That end-to-end check remains to be observed.

## 3. New Scoop autoupdate validation workflow

File: [scoop-autoupdate-validation.yml](../.github/workflows/scoop-autoupdate-validation.yml)

Behavior:
- Triggers on the `manifests-archives-validated` repository-dispatch event, or manually through `workflow_dispatch`.
- Checks that each supplied manifest has both `checkver` and `autoupdate`.
- Copies each manifest to a unique temporary directory and invokes Scoop's own `checkver.ps1 -Update -ThrowError`; it uses `-ForceUpdate` when the manual `force_update` input is enabled. The repository copy is not the target of the update operation.
- Reports cases where checkver succeeds but no newer upstream version exists, because a normal `-Update` does not exercise URL/hash templates unless an update is available. The manual forced mode is provided for this case.

File history:
- [Add the autoupdate-validation workflow](https://github.com/kiro5678/kirobucket/commit/b4dbec3546c2748f47b96a2d7a6ebdd8acf8f2ee)
- [Fix PowerShell path/regex escaping](https://github.com/kiro5678/kirobucket/commit/548e7aa6d03d7d6724a721fa9a8c69bacefc724c)
- [Correct the autoupdate failure-pattern escaping](https://github.com/kiro5678/kirobucket/commit/b69b787366c13215430dce9f0f63b8abf08b64d2)

Validation status: the new workflow has passed repository CI's ordinary checks for the workflow-file changes, but no end-to-end run of this workflow against a manifest sent by the archive-validation workflow has been confirmed yet. Do not interpret the general CI result as proof that a real `-Update` or `-ForceUpdate` test succeeded.

## Related workflow that was not modified

`.github/workflows/scoop-checkver-validation.yml` was not changed during this task; it was run to verify version detection across the bucket. Both its PowerShell 5 and PowerShell 7 jobs passed in [run 38440879693](https://github.com/kiro5678/kirobucket/actions/runs/38440879693). That run checks version detection, not the full URL/hash update path.

## Scope notes

- `.github/workflows/ci.yml` was not edited as part of these workflow changes; the archive workflow still dispatches its existing `archives-validated` event.
- The autoupdate workflow is currently a validation report, not a required gate that blocks the existing CI workflow. A dispatch is sent after archive validation, but the archive workflow does not wait for the new workflow's result.
