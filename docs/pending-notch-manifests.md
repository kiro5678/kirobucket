# Pending Dynamic Island manifests

These two projects were requested for the notch shortlist but are not added as Scoop manifests yet. Their source repositories describe Windows downloads, but the current upstream package assets could not be retrieved and verified during manifest authoring. Do not invent release URLs, extraction paths, or hashes.

| Application | Source repository | Current evidence | Blocker |
| --- | --- | --- | --- |
| Smart Notch | https://github.com/Avenger11764/Dynamic_island | The upstream README describes an `Installers/App_Installer.zip` containing `Smart Notch Setup 1.0.4.exe` and a Store `.appx` package. | The current repository files and ZIP asset could not be fetched from GitHub to inspect the actual setup type, internal payload, and checksum. |
| WinIsland | https://github.com/WinIslandProject/WinIsland | The upstream project is GPL-3.0 and its release page lists v1.5.3 as the latest stable release in the source snapshot checked on 2026-10-31. | The current release asset names, download URLs, package type, and SHA-256 could not be retrieved for inspection. The existing `bucket/winisland.json` points to a different upstream project (`zHeuzy2/WinIsland`) and is intentionally unchanged. |

Revisit these entries when the upstream package assets are accessible. For Smart Notch, inspect `App_Installer.zip` before choosing an installer extraction method. For WinIsland, inspect the v1.5.3 release assets and actual installer/archive structure before writing a manifest.
