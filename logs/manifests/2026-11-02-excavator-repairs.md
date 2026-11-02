# Excavator manifest repairs — 2026-11-02

## Repairs

- `bucket/bloatynosy.json`: updated to release **1.02.142**; corrected the release asset filename to `Bloatynosy-1.02.142.zip`, pinned the SHA-256 published by GitHub, and corrected the executable shim to `Bloatynosy.exe`.
- `bucket/haruna.json`: updated to **1.9.0**; corrected the Windows archive suffix from `gcc` to `mingw` in both the current and autoupdate URLs, and pinned the matching 7z archive checksum. The checksum was cross-checked against two Scoop manifests carrying the exact same asset URL.
- `bucket/mucommander.json`: removed a regex that expected a browser URL fragment (`tag/...`) while checkver reads GitHub release metadata; the GitHub check now uses the tag field.
- `bucket/sukut.json`: updated to **0.4.2** and replaced the obsolete Inno Setup EXE reference with the current portable Windows x64 ZIP. Removed the incorrect `innosetup` declaration and updated the release URL and SHA-256.
- `bucket/thisismyfile.json`: changed checkver to the SoftwareOK version-history page and its `New in version ...` heading; the current version and download hash remain unchanged.
- `bucket/voicestudio.json`: updated to **0.5.7**, corrected the Windows installer filename to `VoiceStudio-0.5.7-win-x64.exe`, pinned the release asset SHA-256, and aligned autoupdate naming/checksum parsing with the published `SHA256SUMS.txt`.

## Excavator verification behavior

- `.github/workflows/excavator.yml`: DNS resolution failures such as `No such host is known` are now reported as transient network warnings, not manifest failures. HTTP 403/404/408/429/5xx, checkver mismatches, invalid URLs, and explicit update failures remain fatal.
- This keeps a temporary DNS failure for `registry-finder.com` visible in the report without treating it as a broken manifest or failing the entire verification job.

## Source checks

- Bloatynosy release **1.02.142** and its ZIP asset digest: [GitHub Releases API](https://api.github.com/repos/builtbybel/Bloatynosy/releases/latest).
- Haruna 1.9 Windows archive naming: [KDE Haruna 1.9 announcement](https://planet.kde.org/haruna-media-player-blog-2026-10-30-haruna-1-9/).
- muCommander release tag and portable ZIP asset: [GitHub Releases API](https://api.github.com/repos/mucommander/mucommander/releases/latest).
- Sukut 0.4.2 Windows ZIP and digest: [GitHub Releases API](https://api.github.com/repos/altarafiya/Sukut/releases/latest) and [upstream README](https://github.com/altarafiya/Sukut#download).
- ThisIsMyFile version history: [SoftwareOK history page](https://www.softwareok.com/?seite=Freeware/thisismyfile/History).
- VoiceStudio 0.5.7 Windows installer and digest: [GitHub Releases API](https://api.github.com/repos/debpalash/VoiceStudio/releases/latest) and [Windows installation guide](https://github.com/debpalash/VoiceStudio/blob/main/docs/install/windows.md).

## Validation status

- Release metadata and published asset digests were checked against upstream GitHub release metadata where available.
- The Haruna download filename and SoftwareOK version-history source were checked separately.
- The original failed run is historical; its verification job reads the completed Excavator job log from that run, so rerunning only that verification step would replay the same old failures. The repaired manifests and updated verifier require a fresh Excavator run for end-to-end CI confirmation.
- No local Windows installation, extraction, or launch smoke test was performed.
