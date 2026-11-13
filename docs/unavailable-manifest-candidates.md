# Software candidates without a current Scoop-ready Windows package

**Last checked:** 2026-11-13

This page records software from repository research that does not currently have a suitable, version-pinned Windows download for a maintainable Scoop manifest. These are documentation-only entries: they are not active manifests and are not kept as placeholder JSON files in `bucket/` or `under review scoop bucket/`.

## Talon — Raven Development Team

- **Source:** [ravendevteam/talon](https://github.com/ravendevteam/talon)
- **Latest GitHub release checked:** `v2026.9.26.18` ([release page](https://github.com/ravendevteam/talon/releases/tag/v2026.9.26.18)); the release has no downloadable assets.
- **Community distribution:** the upstream README directs Community users to run the remote PowerShell command `irm https://debloat.win | iex`. This is a live script/bootstrapper route, not a version-pinned Windows package URL with a static checksum suitable for a normal Scoop download.
- **Legacy direct-download test:** the repository's Review Manifest Installer and Archive Inspector workflow downloaded the legacy `https://raventechnologiesgroup.com/download?product=talon` endpoint and identified the response as a non-7-Zip file; the candidate had no SHA-256. See [workflow run 42837223588](https://github.com/kiro5678/kirobucket/actions/runs/42837223588). The upstream's older README description of a ZIP is not sufficient evidence that the current endpoint still serves that archive.
- **Publisher's distribution tiers:** the [official Talon page](https://raventechnologiesgroup.com/talon/) lists direct prebuilt downloads as a Commercial feature, while the Community option uses the PowerShell method. Building from source is documented, but the current build fetches external scripts and creates a build from the current source rather than providing the missing pinned Community release artifact ([build instructions](https://github.com/ravendevteam/talon/blob/main/DOCUMENTATION.md)).
- **Decision:** do not create or stage a Scoop manifest until the publisher provides a stable, public Community Windows package URL and a verifiable checksum, or publishes a reproducible release artifact that can be validated independently. Do not put the mutable remote PowerShell command in a manifest as a substitute for a pinned package.

## MiaDock — Miamo

- **Source:** [mymiamo/MiaDock](https://github.com/mymiamo/MiaDock)
- **Current upstream distribution:** the repository README identifies source version `1.7.3.0` and says updates are distributed through Microsoft Store. The README's Store badge uses product ID `9pml784d0fdk`.
- **Latest GitHub release checked:** [`v1.6.0.0_Release`](https://github.com/mymiamo/MiaDock/releases/tag/v1.6.0.0_Release), published 2026-08-24, has no downloadable assets. Its release notes explicitly direct users to Microsoft Store for official releases and updates.
- **Older installer:** release [`v1.2.2.0_Release_Emergency`](https://github.com/mymiamo/MiaDock/releases/tag/v1.2.2.0_Release_Emergency) contains `MiaDock.Installer.exe`, but it is an older release and does not match the current source version or current Store distribution. It is not used as the basis for a current manifest.
- **Decision:** do not create a Scoop manifest from an obsolete installer or invent a direct MSIX URL. Revisit only if upstream publishes a current, directly downloadable Windows package with a stable version and verifiable checksum, or a documented distribution path that can be managed correctly by Scoop.

## Awesome MyGo AI category — Windows native apps (checked 2026-11-13)

### AIO Proxy

- **Source:** [aio-proxy/aio-proxy](https://github.com/aio-proxy/aio-proxy)
- **Windows asset:** v0.42.5 publishes `aio-proxy-0.42.5-x64-setup.exe`, an NSIS setup package. The separate `cli-win32-x64` archive is the CLI, not the desktop app.
- **Installation behavior:** the desktop setup installs into the current user's LocalAppData, creates a Start Menu shortcut and HKCU uninstall registration. Its uninstaller includes cleanup logic for the app-owned service/task, user PATH shims, startup value and support directory.
- **Decision:** do not treat the setup EXE as portable or unpack it as a normal archive. A maintainable Nonportable manifest needs tested upgrade/uninstall behavior so Scoop updates do not remove the app's external service state or user data.

### InferYard Studio

- **Source:** [sunny0826/inferyard](https://github.com/sunny0826/inferyard/tree/main/studio)
- **Latest release checked:** v0.0.3 publishes a Python wheel, source archive and runtime constraints; it does not publish a Windows Studio executable or installer.
- **Build requirements:** Studio is a separate Go/MyGo desktop project. Its README requires Go 1.27.3 and a separately installed InferYard CLI, plus configured local model/engine assets and directories.
- **Decision:** wait for a versioned Windows desktop release or a fully reproducible, tested source-build manifest. Do not use the Python CLI wheel as a substitute for the native Studio app.

### MangaTrans

- **Source:** [roketskiy/mangatrans](https://github.com/roketskiy/mangatrans)
- **Current distribution:** no GitHub Releases or versioned Windows binary assets are published.
- **Build/runtime requirements:** the upstream README requires CUDA 13, cuDNN, a CUDA build of `llama-server.exe`, ONNX Runtime cuda13, a MinGW-w64 toolchain for the engine and multiple separately downloaded OCR, inpainting and translation models.
- **Decision:** do not create a Scoop manifest that pretends this is a self-contained Windows app or downloads several gigabytes of model files. Revisit when upstream publishes a versioned Windows package with a documented runtime strategy.

## Reconsideration requirements

Before adding a candidate to `bucket/`, verify the current official Windows artifact, version mapping, architecture, installer/package type, SHA-256, extracted application files, and real launch executable. Use an installer-inspection workflow when the package type cannot be established from upstream documentation. A successful HTTP download alone does not establish that a valid Scoop manifest can be created.

These entries describe why no manifest was created; they do not represent failed or installable manifests.
