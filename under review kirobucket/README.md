# KiroBucket — Under Review

This folder is the staging area for manifests that are not ready for the active Scoop bucket.

A manifest belongs here when it is newly added but still needs verification, when maintenance or validation has failed, or when its installer, extraction method, launch path, checksum, or update behavior is uncertain.

**Files in this folder are outside `bucket/` and are not installable through KiroBucket.** Keep them here until the review is complete. Do not copy them back into `bucket/` until the manifest has been validated.

## Review checklist

1. Confirm the upstream project and official release asset.
2. Validate the JSON and the Scoop manifest schema.
3. Verify the release URL and SHA-256 checksum.
4. Inspect the actual installer/archive payload and confirm the executable path.
5. Confirm install, update, uninstall, persistence, and architecture behavior.
6. Run the relevant KiroBucket manifest validation workflows.
7. Move the manifest back to `bucket/` only after the checks pass, then update the relevant documentation.

## Current review queue

| Manifest | Reason |
| --- | --- |
| [go-away-edge-installer](go-away-edge-installer.json) | Installer type and extraction behavior are unknown; the manifest declares a shortcut but no verified setup or payload handling. |
| [motrix-next](motrix-next.json) | Deprecated manifest for the Rayburst rename; its current extracted launch path and Scoop installation behavior are not sufficiently verified. |
| [quanto-flx](quanto-flx.json) | Rainmeter RMSKIN add-on, not a standalone application; it requires Rainmeter's SkinInstaller workflow. |
| [zenbreak-msix](zenbreak-msix.json) | MSIX file is being unpacked as a 7-Zip archive; the unpackaged executable still needs a runtime/launch test. |
| [anton](anton.json) | Official endpoint redirects to a setup EXE, but the publisher checksum and installer/uninstaller behavior are not verified. |
| [pulse-launcher](pulse-launcher.json) | Only a pre-release setup EXE is published; installer engine, payload layout, and uninstall behavior are unverified. |
| [taskslinger](taskslinger.json) | Official setup has no verified Scoop-contained install path or portable extraction method. |
| [layer](layer.json) | Tauri/NSIS setup has no separate portable build; its custom install directory and included EULA terms remain unresolved. |
