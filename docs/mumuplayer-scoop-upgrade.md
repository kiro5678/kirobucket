# MuMuPlayer Scoop Upgrade Handling

## Root cause

MuMuPlayer's NX-main installer stores its install root in its uninstall registration and configuration files. During the attempted Scoop upgrade from `1.8.5.5748` to `1.8.16.6114`, the installer accepted the new NSIS `/D=` destination but rejected it with `80011`.

The installation log identified the conflict directly:

- The requested destination was the new version directory under `apps\\mumuplayer\\1.8.16.6114`.
- The registered existing installation still pointed to `apps\\mumuplayer\\1.8.5.5748`.
- The installer reported `reason=existing_root_locked`.

This was not an NSIS quoting failure. The unquoted `/D=` argument was read correctly; changing its quoting again would not solve the root mismatch.

## Stable install-root design

The MuMu program files now live at the version-independent path:

```text
$persist_dir\\install
```

The resolved Scoop `$persist_dir` variable is used rather than assuming that persist is beside the app directory. The manifest continues to persist `configs`, `vms`, and `nx_device`.

On the first migration:

1. The hook reads the existing MuMu uninstall registration and stored install paths.
2. It refuses conflicting registrations or a source directory outside the current Scoop app.
3. It validates the registered root, then **moves** the program files to `$persist_dir\\install` with Robocopy `/MOVE`. The old Scoop version directory can remain temporarily, but its MuMu program binaries are no longer in it; the existing persist junctions stay attached to Scoop's persist folders.
4. It creates junctions under the stable root for `configs`, `vms`, and `nx_device`, each pointing to the corresponding Scoop persist folder.
5. It updates MuMu's uninstall registration, AppData and persisted absolute paths, and the `MuMuPlayerRemoteService` image path to the stable root.
6. It starts `install_prepare` and `commit` with the same fixed, unquoted, final NSIS argument: `/D=$persist_dir\\install`.

The installer executable is staged outside the target directory. The versioned Scoop directory receives a small `MuMuPlayer.cmd` launcher and the Start Menu shortcut targets that launcher. This keeps Scoop's version-specific paths separate from the path recorded by MuMu.

Scoop creates its own version-local persist junctions after `pre_install`. The hook therefore does not pre-create `configs`, `vms`, or `nx_device` in the new version directory.

## Rollback and uninstall behavior

Before changing files, the hook snapshots the relevant uninstall Registry keys, configuration files, and the remote-service image path. If installer preparation or commit fails, it restores those snapshots. If rollback itself fails, it retains the recovery directory and reports its path instead of deleting the recovery copies.

The old versioned program files are moved, not copied. If setup fails after the move, the hook moves the program files back to the original version directory before restoring Registry, configuration, and service paths. Persisted VM data is not deleted or renamed, and the hook does not manipulate `%PUBLIC%\\.MUMUVMM`.

The `post_uninstall` hook checks Scoop's documented `$cmd` value. During `scoop update`, it removes only the old version's shortcuts and leaves the shared stable root intact. During `scoop uninstall`, it removes the service and uninstall registration only when they point to this stable root, detaches only verified junctions, and deletes the stable program files. The persisted `configs`, `vms`, and `nx_device` folders are retained. Do not use Scoop's purge option unless you intend to delete all persisted VM and configuration data as well.

## Regression coverage

`.github/workflows/mumuplayer-scoop-upgrade-test.yml` runs Scoop's official `checkver`, parses the embedded PowerShell, and executes `tests/mumuplayer-stable-root.Tests.ps1`.

The regression test covers:

- A prior install registered in a versioned Scoop directory.
- Injected `80011` and restoration of Registry, configuration, and service paths.
- A true move into the stable root, with reverse-move rollback after the injected `80011` failure.
- First upgrade and subsequent updates using the same `/D=` destination.
- Existing `80002` retry paths in `install_prepare` and `commit`.
- Preservation of VM data, configuration markers, and device-engine data.
- Keeping the stable root during `scoop update`, then removing only program files and registration on `scoop uninstall`.

The current GitHub regression is a deterministic mock-installer test. It does not run the actual MuMu installer, boot an Android VM, verify the host virtualization drivers, or test a Windows reboot. A real-machine update and reboot validation are still required before claiming the emulator itself has been verified.
