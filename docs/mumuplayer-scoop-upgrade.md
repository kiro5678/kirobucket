# MuMuPlayer Scoop Upgrade Handling

## Problem

The MuMuPlayer NX-main installer is orchestrated through `install_prepare` and `commit`. A plain Scoop `persist` declaration is not sufficient for this installer when the existing persisted directories already exist: Scoop's `persist_data` keeps the old persist target and moves any newly created version-local source directory to `.original`. That can leave old NX-device files active after an upgrade.

The installer also stores absolute install paths in `configs` and VM configuration files. Scoop changes the version directory on every update, so those references must be migrated. A fixed delay between installer phases is not a readiness check.

## Implemented behavior

- Keep `configs`, `vms`, and `nx_device` in the manifest's `persist` list.
- Use Scoop's resolved `$persist_dir` variable instead of inferring the persist location from `$dir`; this supports custom and global Scoop layouts where the persist directory is not a sibling of the app root.
- Before invoking MuMu, create temporary version-local junctions from the new Scoop version directory to each existing `persist\mumuplayer\<folder>` target. The installer therefore operates on the real persisted files, including updating the persisted `nx_device` binaries.
- Remove only those temporary junctions after the installer completes. The source paths are absent when Scoop's own `persist_data` runs, so Scoop recreates its managed junctions without producing `.original` folders.
- Read the previous product version and installation directory from persisted `configs\main\install_config.json`. Migrate old absolute paths in known text configuration formats before and after the installer phases, and update `install_config.json` to the new Scoop version path.
- Pass NSIS `/D=` as the final command-line argument and without quote characters. NSIS accepts spaces in the destination path; quotes are not permitted.
- Keep the MuMu installer executable outside the `/D=` installation target. Reuse `cache_path` when the Scoop download is cached; otherwise stage a transaction-specific copy under the Scoop cache, remove the copy from `$dir`, and verify the target root has no files before creating persist junctions. Never launch the installer from `$dir` while also passing `$dir` as `/D=`.
- Wait for `Start-Process -Wait` to complete, then poll the installer output tree until its metadata remains stable. Enforce a timeout and verify `nx_main\MuMuNxMain.exe` after commit; do not use a fixed 12-second sleep.
- Handle MuMu error `80002` once in `install_prepare` using the persisted version, and once in `commit` using the version actually written by the prepare phase. Refuse a downgrade or ambiguous version state. Never delete or rename `%PUBLIC%\.MUMUVMM` automatically because that directory may belong to another MuMu installation.

## Regression coverage

`.github/workflows/mumuplayer-scoop-upgrade-test.yml` validates the manifest with Scoop's official `checkver`, parses the embedded PowerShell hook, and executes a deterministic mock-installer scenario. It simulates a first install and an upgrade, injects `80002` once, uses a Scoop root containing spaces, verifies persisted VM/config/device marker retention, checks that `nx_device` binaries are updated, and verifies that the absolute paths are migrated.

The regression test deliberately places the persist root outside the Scoop app root, to cover a global/custom Scoop layout.

The GitHub-hosted test does not boot the Android VM, install/validate the actual MuMu hypervisor drivers, or reboot Windows. Those checks require a Windows host with hardware virtualization and a reboot-capable test environment. The workflow must not be treated as proof of real emulator boot after restart.
