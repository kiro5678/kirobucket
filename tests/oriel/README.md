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

All command-line switches are unverified hypotheses. Each candidate runs on its own disposable Windows runner. The workflow checks installation exit status, application EXEs inside Scoop's version directory, common external install locations, uninstall registry entries, and whether `scoop uninstall` removes the version directory.

The static inspection job verifies the download hash, scans embedded strings, probes common help switches with timeouts, and records the 7-Zip extraction contents.

## Promotion rule

Do not promote a candidate into `bucket/` unless it exits without interactive UI, places the app inside Scoop's version directory, creates no external install or uninstall registration, and is removed cleanly by `scoop uninstall`.

No candidate declares an unverified uninstaller. A successful setup launch alone is not sufficient.
