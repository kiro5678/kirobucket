# Notch manifest additions — 2026-11-01

## Added

- `bucket/windows-notch-overlay.json` — Windows Notch Overlay 0.4.0, official Electron Builder portable EXE and upstream SHA-256.
- `bucket/lumen.json` — Lumen 0.2.1, Inno Setup payload extraction; executable and payload path confirmed from upstream `setup.iss`.
- `bucket/myisland.json` — MyIsland 1.0.0, official standalone EXE and upstream SHA-256.
- `bucket/nook-agent.json` — Nook 0.2.2 from `zubairbinshaukat/nook`; the two official binaries and their SHA-256 digests are included. The manifest is named `nook-agent` to avoid colliding with the existing `bucket/nook.json` for `Geguchh024/nook`.

## Already present; not duplicated

Bloom, Dlives, Halo, Nectar, PILLAR, QNotch, Quick Pill, V-Notch, WNotch, Windows Dynamic Island (nazimferragh), WinDynamicIsland (uponatime2019), WinIsland (zHeuzy2), WinIslands, WinNotch (N3uralCreativity), and Nook (Geguchh024) already have manifests in `bucket/`.

## Deferred

Smart Notch and WinIslandProject/WinIsland currently return HTTP 404 at the supplied repository URLs. Advanced Dynamic Island, Jaswanth1902/Notch, and vyshnav-suresh/windows-notch have no verified Windows release assets in the checked source snapshot. The Prasun Debnath WinNotch ZIP digest is published, but its archive paths were not inspected. eIsland publishes a large Setup EXE whose payload has not been inspected. The two Windhawk projects are mods, not independent desktop applications. Reasons and source URLs are tracked in `docs/pending-notch-manifests.md`.

## Validation boundary

- New manifest JSON syntax was parsed before writing.
- Package URLs and SHA-256 digests were taken from upstream GitHub Release metadata; Lumen's Inno Setup type and executable path were checked against its upstream installer script.
- The Windows extraction workflow was extended to download, verify, and inspect the four added packages on GitHub-hosted Windows runners.
- No claim is made that the Windows extraction workflow has completed successfully yet. Scoop install/run/uninstall smoke tests remain outstanding.
