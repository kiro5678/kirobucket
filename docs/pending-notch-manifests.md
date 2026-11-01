# Pending Dynamic Island manifests

This file tracks notch projects mentioned for KiroBucket that do not yet have a verified, installable Scoop manifest. Do not invent release URLs, hashes, archive paths, or executable names. Recheck these entries when upstream publishes a usable Windows asset or when its package can be inspected.

## Added in this update

| Manifest | Upstream project | Verified package |
| --- | --- | --- |
| [lumen](../bucket/lumen.json) | https://github.com/Risuleia/Lumen | v0.2.1 Inno Setup payload; SHA-256 verified. |
| [myisland](../bucket/myisland.json) | https://github.com/xiaoxiaobaijiangjun/MyIsland | v1.0.0 standalone EXE; SHA-256 verified. |
| [nook-agent](../bucket/nook-agent.json) | https://github.com/zubairbinshaukat/nook | v0.2.2 standalone app and relay EXEs; both SHA-256 digests verified. |
| [windows-notch-overlay](../bucket/windows-notch-overlay.json) | https://github.com/Taxperia/windows-notch-overlay | v0.4.0 official Electron Builder portable EXE; SHA-256 verified. |

## Still pending or not suitable as an independent Scoop application

| Application | Source | Blocker / decision |
| --- | --- | --- |
| Smart Notch | https://github.com/Avenger11764/Dynamic_island | The previously supplied repository currently returns HTTP 404. The earlier README reference to `Installers/App_Installer.zip` is not enough to infer a current setup URL, payload layout, or checksum. |
| WinIsland (WinIslandProject) | https://github.com/WinIslandProject/WinIsland | The previously supplied repository currently returns HTTP 404. The existing `bucket/winisland.json` belongs to a different project (`zHeuzy2/WinIsland`) and must not be repointed without evidence. |
| Advanced Dynamic Island | https://github.com/kadrxy/Dynamic-Island | The repository is MIT-licensed, but no GitHub release assets were published in the checked source snapshot. A source-build manifest would require a pinned commit and a successful Windows/.NET build before it can be considered ready. |
| WinNotch (Prasun Debnath) | https://github.com/prasundebnath/WinNotch | v1.1 publishes a ZIP and a digest, but the archive's internal paths were not inspected. Do not assume `WinNotch.exe` is at the archive root. It is distinct from the existing `bucket/winnotch.json` (N3uralCreativity). |
| eIsland | https://github.com/JNTMTMTM/eIsland | The latest v27.0.1 asset is a 402 MiB Setup EXE. The installer's payload and extraction behavior have not been inspected, so no NSIS/Inno extraction method or executable path is assumed. |
| WinIsland fork / Lingyu | https://github.com/TryWorld2026/Lingyu | The previously supplied repository URL currently returns HTTP 404. Do not create a manifest against an inaccessible source. |
| Windows Notch (vyshnav-suresh) | https://github.com/vyshnav-suresh/windows-notch | Source repository found, but no GitHub release assets were published in the checked source snapshot. |
| Notch (Jaswanth1902) | https://github.com/Jaswanth1902/Notch | The v0.1.0 release has no downloadable assets; the project currently requires a source build. |
| Dynamic Island for Windows (Windhawk Mod) | https://github.com/devcode90/Dynamic-Island-for-Windows | This is a Windhawk mod, not a standalone desktop application or binary. Install/manage it through Windhawk; a separate Scoop app manifest would misrepresent its packaging. |
| Dynamic Island Fork (Windhawk) | https://github.com/Adiieeee/Fork-Dynamic-Island-Windhawk | This is also a Windhawk mod, not a standalone application. It is not represented as an independent Scoop app manifest. |

The following projects from the earlier notch list already have manifests in `bucket/` and should not be duplicated: Bloom, Dlives, Halo, Nectar, Nook (Geguchh024 project), PILLAR, QNotch, Quick Pill, V-Notch, Windows Dynamic Island (nazimferragh), WinDynamicIsland (uponatime2019), WinIsland (zHeuzy2), WinIslands, WinNotch (N3uralCreativity), and WNotch.
