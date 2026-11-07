# Autorun Organizer 7.02 — system-scope Inno Setup inside Scoop

## Verified design

The official ChemTable page identifies version 7.02 and lists Administrator rights in the system requirements. The previous manifest used `innosetup: true`, which extracted the payload and did not run the publisher's normal setup routine. That was insufficient for the requested system installation.

Inno Setup's documented default for `PrivilegesRequired` is `admin`; this runs Setup in administrative install mode and requests elevation when needed. Its `/DIR` switch overrides the application destination directory. Scoop officially substitutes `$dir` in `installer.args` and provides `uninstaller` handling for both uninstall and update operations.

## Manifest change

- Runs the official Inno Setup file with `/VERYSILENT /SUPPRESSMSGBOXES /NORESTART /SP- /DIR="$dir"`.
- Requires an elevated Scoop session before installation and uninstallation.
- Exposes the verified application executable `AutorunOrganizer.exe` through `bin` and the Start Menu shortcut. The former `AutorunOrganizer,1.exe` target was incorrect and caused Scoop's post-install shim failure.
- Adds a `post_install` guard that checks `AutorunOrganizer.exe` under `$dir` and lists any discovered EXE files if the target is absent.
- Uses the Inno uninstaller under `$dir\unins000.exe`; safely skips it only for an older extraction-only installation that has no registered Inno uninstaller.
- Does not add `/ALLUSERS`: Inno documents that it only has an effect when the installer script enables `PrivilegesRequiredOverridesAllowed=commandline`. The default `admin` mode already selects administrative installation.
- Adds the Scoop-supported `##` comment marker `Installer Type: Inno Setup` so the generated inventory records the verified engine without setting `innosetup: true` (which would select extraction rather than normal setup execution).
- Keeps the manifest classified as **Nonportable**. The quoted `/DIR="$dir"` keeps the installed application files under the Scoop version directory, including when the Scoop root contains spaces, but normal setup registration is still performed in Windows.

## Documentation and references

- Official ChemTable product page (7.02; Administrator rights): https://www.chemtable.com/autorun-organizer.htm
- Inno Setup `/DIR`, `/VERYSILENT`, `/SUPPRESSMSGBOXES`, `/NORESTART`, and `/SP-`: https://jrsoftware.org/ishelp/topic_setupcmdline.htm
- Inno Setup default `PrivilegesRequired=admin`: https://jrsoftware.org/ishelp/topic_setup_privilegesrequired.htm
- Scoop installer/uninstaller args and `$dir`: https://github.com/ScoopInstaller/Scoop/wiki/App-Manifests
- Scoop script path variables and `$dir` version-path behavior: https://github.com/ScoopInstaller/Scoop/wiki/Pre-Post-%28un%29install-scripts

The installer was not executed in a Windows test environment during this documentation and manifest edit. The hash was retained from the previous manifest. CI and a Windows install/update/uninstall test are still required to confirm the actual output paths and registry behavior.

## Follow-up fix — incorrect shim target

The first live Scoop installation reached shim creation but failed because the manifest declared `AutorunOrganizer,1.exe`, which is not the application's executable name. Changed the shim and shortcut target to `AutorunOrganizer.exe` and added a post-install file check under `$dir`. The exact file name is supported by independent installed-file inventory; the user's local directory has not yet been inspected, so the next Windows installation is still the decisive runtime check.
