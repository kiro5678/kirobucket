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

## Current workflow behavior

The manifest-table workflow:
1. Reads all manifests in `bucket/`.
2. Extracts version, description, and last modification date.
3. Generates the README table with the newest updates first.
4. Keeps sorting links for Name and LAST UPDATE.
5. Maintains the generated section using explicit start/end markers.
6. Commits README changes automatically when the generated content changes.

The repository CI remains responsible for validating manifest syntax and schema correctness.
