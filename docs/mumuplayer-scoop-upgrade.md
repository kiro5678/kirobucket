# MuMuPlayer Scoop Upgrade Handling

## Root cause

The MuMuPlayer NX-main installer stores its installation path in uninstall registration, service configuration and JSON configuration files. The earlier manifest attempted to avoid installer error 80011 by moving the complete application payload to:

$persist_dir\install

That avoided the original version-path conflict, but it put program binaries in Scoop's persistent-data directory. As a result, apps\mumuplayer\<version> contained only a launcher and Scoop metadata while the real application lived under persist\mumuplayer\install. This is not the intended Scoop layout.

## Corrected layout

The manifest now separates the stable registration path from the physical versioned payload:

apps\mumuplayer\<version>\       MuMu program files
apps\mumuplayer\current          Scoop junction to the active version
persist\mumuplayer\configs       user configuration
persist\mumuplayer\vms           virtual-machine data
persist\mumuplayer\nx_device     device/engine data

MuMu's Registry entries, service image path, install_config.json, VM configuration references and launcher use apps\mumuplayer\current. Scoop updates that junction to the active version, while the binary files remain in the version directory.

## Upgrade sequence

Scoop removes the old current junction before running the new install hook. The manifest then:

1. Reads the previous root from MuMu's uninstall registration/configuration. If those references are stale because they use the removed current junction, it searches the existing Scoop version directories for a complete MuMu installation.
2. Creates a temporary current junction pointing to the new empty version directory. The hook refuses to replace a non-junction or an unexpected existing target.
3. Moves the previous MuMu program files into the new version directory with Robocopy /MOVE. For installations created by the previous manifest, the source may be persist\mumuplayer\install.
4. Rewrites Registry, service and configuration paths to apps\mumuplayer\current.
5. Temporarily moves the persisted configs, vms and nx_device directories into the new version directory so the MuMu installer can access them through its stable current path.
6. Runs install_prepare and commit using the same final, unquoted NSIS argument: /D=<Scoop app path>\current.
7. After the hook returns, Scoop's normal persist_data stage moves those directories back to persist\mumuplayer and creates the version-local persist junctions. Scoop then links current to the installed version.

The installer executable is staged outside the destination directory so that the NSIS installer does not see its own setup file in the target.

## Rollback and uninstall

Before modifying the installation, the hook snapshots MuMu's uninstall Registry entries, configuration files and service image path. If install_prepare or commit fails, it reverses the program-file move, restores the persisted directories to their original location, restores the prior current link where possible, and restores the snapshots. If rollback is incomplete, the recovery directory is retained and its path is reported.

The legacy persist\mumuplayer\install directory is not recursively deleted during migration. Its program files are moved out; only known data junctions may remain. During full Scoop uninstall, the hook removes MuMu's service and uninstall registration only when they refer to the current or legacy root. It detaches only verified legacy data junctions and removes the legacy directory only if it is empty. Scoop remains responsible for deleting the version directory. The configs, vms and nx_device persist folders are retained.

## Applying the corrected manifest to the existing same-version installation

The upstream version is still 1.8.16.6114; the manifest does not invent a new upstream version just to force a reinstall. After refreshing the bucket, use Scoop's documented force-update option so the same version is reinstalled with the corrected manifest:

    scoop update
    scoop update mumuplayer -f

Do not manually delete persist\mumuplayer\install, configs, vms or nx_device. The migration hook needs the legacy install root and persisted data to move them safely. Do not use scoop uninstall -p for this migration.

## Regression coverage and limitations

.github/workflows/mumuplayer-scoop-upgrade-test.yml validates the manifest with Scoop's official checkver and parses the embedded PowerShell hooks. tests/mumuplayer-stable-root.Tests.ps1 simulates:

- Migration from the previous persist\install layout.
- An injected 80011 failure and reverse-move rollback.
- A successful migration with binaries in the version directory.
- Scoop's persist_data and current junction lifecycle.
- A subsequent upgrade after current has been unlinked.
- The existing 80002 prepare/commit retry paths.
- Preservation of VM, configuration and device data through a full Scoop uninstall.

The regression uses a mock installer. It does not run the real MuMu installer, boot Android, verify host virtualization drivers or validate a Windows reboot. The first real upgrade on the user's machine remains the final integration test.
