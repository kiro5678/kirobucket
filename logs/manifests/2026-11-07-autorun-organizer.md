# Autorun Organizer 7.02 — Nonportable installation

## Previous behavior

The manifest used `innosetup: true`, which extracts the Inno Setup payload instead of running the publisher's normal setup routine. It therefore placed the application files under Scoop and did not create the Windows installation and uninstall registration supplied by the installer.

## Change

- Kept the official 7.02 installer URL and existing SHA-256 value.
- Replaced Inno payload extraction with the publisher's silent setup arguments: `/VERYSILENT /SUPPRESSMSGBOXES /NORESTART`.
- Added an administrator check before installation so the setup is not run from a non-elevated shell.
- Added an uninstaller script that locates the machine-wide uninstall entry under HKLM and runs its registered Inno uninstaller elevated. If no machine-wide entry exists (for example, an older extraction-only install), the script leaves that state untouched.
- Removed `bin` and Scoop `shortcuts` entries because the normal installer places the program outside the Scoop version directory; retaining those paths would create broken shims or shortcuts.
- Reclassified the manifest as **Nonportable** in `docs/manifest-portability.md`. It remains in `bucket/`; this repository tracks portability in the inventory rather than a separate on-disk folder.

## Scope evidence and limitations

- The official ChemTable product page identifies the current release as 7.02 and lists administrator rights in the system requirements: https://www.chemtable.com/autorun-organizer.htm
- Installer metadata for the same product identifies the Inno Setup package as machine-scope and documents the silent switches: https://wingetly.io/apps/chem-table-software/autorun-organizer/silent-install
- Inno Setup's official documentation confirms the silent, message-suppression, and no-restart switches. It also states that `/ALLUSERS` only works when the install script explicitly enables command-line privilege overrides: https://jrsoftware.org/ishelp/topic_setupcmdline.htm
- Scoop supports explicit `installer` and `uninstaller` instructions in app manifests: https://github.com/ScoopInstaller/Scoop/wiki/App-Manifests

The 7.02 installer was not executed in a Windows test environment during this edit. The hash was retained from the existing manifest rather than independently recalculated. Confirm the install path, HKLM uninstall registration, and update/uninstall flow through repository CI or a Windows test before treating runtime installation as verified.
