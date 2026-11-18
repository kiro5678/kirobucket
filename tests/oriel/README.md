# Oriel Notch installer experiments

These files are **temporary test manifests**, not production Scoop packages. They are intentionally stored outside `bucket/` and must not be promoted unless a method passes installation and uninstall checks.

Target: [Niix-x/Oriel-Releases](https://github.com/Niix-x/Oriel-Releases), official Windows setup `OrielSetup-1.1.1.exe`.

Pinned SHA-256:

```text
808ec378fcc90c8ae90ace3628596d8819ae728796a1229ff0cf5505ceb8d954
```

| Candidate | Scoop mechanism | Hypothesis |
| --- | --- | --- |
| `oriel-notch-exp-s` | `installer.args` | `/S` |
| `oriel-notch-exp-silent` | `installer.args` | `/silent` |
| `oriel-notch-exp-quiet` | `installer.args` | `/quiet` |
| `oriel-notch-exp-script` | `installer.script` | PowerShell invokes `--silent --install-dir $dir` with a timeout |
| `oriel-notch-exp-7zip` | URL fragment extraction | `#/dl.7z` |
| `oriel-notch-exp-managed-external` | `installer.script` + `post_install` junction + `uninstaller.script` | Installs to the publisher's per-user path and attempts to manage the registered uninstall command |
| `oriel-notch-exp-managed-external-sync` | `installer.script` + junction + registry-aware uninstaller | Waits for Oriel's uninstall registry entry to disappear before Scoop proceeds with a forced update |

All command-line switches are unverified hypotheses. Each candidate runs on its own disposable Windows runner. The workflow checks installation exit status, application EXEs inside Scoop's version directory, common external install locations, uninstall registry entries, and whether `scoop uninstall` removes the version directory.

The static inspection job verifies the download hash, scans embedded strings, probes common help switches with timeouts, and records the 7-Zip extraction contents. The managed-external candidate is intentionally separate: the earlier `--silent --install-dir` probe installed to `%LOCALAPPDATA%\\Programs\\Oriel` and registered an uninstall command, so this candidate tests whether a junction and that registered uninstaller can make this external install controllable by Scoop.

## Promotion rule

Do not promote a candidate into `bucket/` unless it exits without interactive UI, provides a working Scoop launch path, and is removed cleanly by `scoop uninstall`. The managed-external candidate has a stricter alternate check: it must create the expected junction, use the exact uninstall command recorded by Oriel, and remove both the external app folder and Windows uninstall registration. Even if it passes, it remains a non-portable option and must be assessed against Oriel's built-in self-updater before production use.

The managed-external candidate uses `uninstall.exe --uninstall` only because that exact command was observed in the installer's Windows uninstall registry entry. A successful setup launch alone is not sufficient.


A forced same-version `scoop update -f` test exposed a race in the original managed-external candidate: Oriel's files disappeared but its uninstall registry entry was still present when Scoop started the replacement install. The synchronized candidate waits up to 30 seconds for both states to clear and fails closed if they do not.