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


## Awesome MyGo System category (checked 2026-11-13)

### Projects not added

- **MyCast** — [feiniao233/MyCast](https://github.com/feiniao233/MyCast). The current Windows release is `v0.1.0-alpha`; the upstream README identifies it as an alpha candidate and says key Windows behaviors (IME, tray/hotkey, clipboard return, DPI and multi-monitor) have not completed real-device acceptance. Revisit after a stable Windows release and acceptance.
- **Mochi** — [maximousblk/mochi](https://github.com/maximousblk/mochi). The available Windows assets are published through a mutable `canary` pre-release; upstream describes the app as alpha. Do not track the canary as a stable Scoop release.
- **Chrome Profile Router** — [chinnsenn/chrome-profile-router](https://github.com/chinnsenn/chrome-profile-router). Its README describes Windows support as experimental and not tested on native Windows; the repository has no declared license. Revisit after Windows support and licensing are clarified.
- **MyClip** — [L92-Labs/myclip](https://github.com/L92-Labs/myclip). The current GitHub release does not provide a usable Windows desktop package; do not build a manifest from source alone.
- **Shixin Input** — [shixin-labs/shixin-input](https://github.com/shixin-labs/shixin-input). The latest Windows assets are explicitly unsigned preview installers, not a verified stable Windows distribution.
- **Clipboard-go**, **Locklark** and **Tendedero** — the project repositories currently expose no versioned GitHub Windows release asset suitable for a pinned manifest. Revisit when a versioned Windows package and checksum are published.

## Awesome MyGo showcase — audit of the previously reported 46 candidates

**Checked:** 2026-11-13

The earlier filename comparison overstated the number of missing manifests. Four projects already have matching manifests under different Scoop names:

| Showcase name | Existing manifest | Upstream |
| --- | --- | --- |
| Gist | `gistmanager` | [Oranjekop/GistManager](https://github.com/Oranjekop/GistManager) |
| RNAxRay Desktop | `rnaxray` | [Vicky-0256/RNAxRAY](https://github.com/Vicky-0256/RNAxRAY) |
| Nomo | `nomo-mygo` | [ZeroDevi1/nomo-mygo](https://github.com/ZeroDevi1/nomo-mygo) |
| Xiangqi Go | `xiangqi` | [ch1y1z1/xiangqi_go](https://github.com/ch1y1z1/xiangqi_go) |

The remaining 41 names do not currently qualify for a new active manifest based on the Windows release assets and upstream documentation checked. They are listed here to prevent duplicate research and placeholder manifests.

| Category | Candidate | Current blocker |
| --- | --- | --- |
| Agents | [omo](https://github.com/QinYangWang/omo), [Mux](https://github.com/nomyfan/mux), [GoCode](https://github.com/ijry/GoCode), [Cyrene Terminal](https://github.com/YanChenBai/cyrene-terminal), [DeepSeek Harness](https://github.com/dhx007/mygo-dsh) | No versioned GitHub Windows release asset was published. |
| Dev | [SBDb](https://github.com/congthien2003/dbl), [Patch](https://github.com/darylcecile/patch), [Twill](https://github.com/ziludev/twill), [MyCode](https://github.com/hunghg255/mycode) | No versioned Windows release asset was published. |
| Dev | [Zeus](https://github.com/J4ck1e2000/Zeus) | The checked release contains a macOS DMG only. |
| Dev | [KeyDepot](https://github.com/tbdsux/keydepot) | The available Windows package is a beta; upstream explicitly says its Windows build is untested, and asks users to try it only with backup copies of their keys. Revisit after Windows acceptance and security review. |
| AI | [HyperAI](https://github.com/lesenelir/hyperai-desktop) | No versioned Windows release asset was published. |
| AI | [InferYard Studio](https://github.com/sunny0826/inferyard/tree/main/studio) | The checked release contains a Python wheel and source archive, not the Windows desktop application. |
| Network | [Jalin](https://github.com/firdausmntp/Jalin), [MyGo Browser](https://github.com/cecil-su/mygo-browser), [Site Sucker](https://github.com/maksqi/site-sucker) | No versioned Windows application package was published. MyGo Browser is currently source-only. |
| Network | [WGM](https://github.com/qmaru/wgm) | The checked release tag has no downloadable assets. |
| Network | [Meridian](https://github.com/alanbulan/meridian-vpn) | The Windows installer belongs to an alpha whose Windows build has the interface but no VPN backend. |
| Notes | [Kata](https://github.com/yaffalhakim1/kata) | No versioned Windows release asset was published. |
| System | [Desk](https://github.com/jitunayak/android-desk), [Sokki](https://github.com/sorrycc/Sokki), [Floater](https://github.com/Uninen/floater) | The checked project/release evidence is macOS-only; no suitable Windows package was found. |
| System | [MyCast](https://github.com/feiniao233/MyCast) | A Windows alpha ZIP exists, but upstream documents the release as an alpha candidate and lists uncompleted real-device acceptance for IME, tray/hotkey, clipboard return, DPI and multi-monitor behavior. Do not promote it to an ordinary package before acceptance. |
| System | [Clips](https://clips.5km.tech/) | No version-pinned Windows download with a verifiable checksum and inspectable package layout was confirmed. |
| System | [Firn](https://github.com/frostyard/firn) | The checked releases publish Linux packages only. |
| System | [MyClip](https://github.com/L92-Labs/myclip) | The checked release publishes Linux and macOS assets, but no Windows build. |
| System | [Locklark](https://github.com/jihuayu/locklark), [Calculus](https://github.com/tortoise10h/calculus), [Downloader](https://github.com/josexy/go-downloader), [Clipboard-go](https://github.com/1e4DouWine/clipboard_go), [OpenUXP Installer](https://github.com/Moonvy/UPX-Installer-GO), [Tendedero in MyGo](https://github.com/HycJack/mygo-tendedero) | No versioned GitHub Windows release asset was published. |
| System | [Chrome Profile Router](https://github.com/chinnsenn/chrome-profile-router) | A Windows ZIP exists, but upstream labels Windows experimental and untested on native Windows; the repository also has no declared license. |
| Devices | [beekb](https://github.com/Kutius/beekb-driver), [NVR Status](https://github.com/dongsheng512/NVR-Status-Go) | No versioned Windows release asset was published. |
| Media | [Ottr](https://github.com/QinYangWang/ottr), [Dual PNG](https://github.com/SinarPandora/dual-png), [MujicaCut](https://github.com/HycJack/mujicacut), [SmartImage Toolkit](https://github.com/Shirolin/SmartImage-Toolkit) | No versioned Windows release asset was published. MujicaCut is explicitly a timeline/demo project without a decoder or finished video renderer. |
| Media | [Haruhikage](https://github.com/yxxbc/haruhikage-app) | The checked Windows release metadata contains updater files, but no Windows executable or archive asset. |
| Game | [lom-dx2metal](https://github.com/li-yifei/lom-dx2metal) | This converts Direct3D 11 game assets for Apple's Metal player; the checked project has no Windows release package. |

Open Aria Exporter is now available as [`open-aria-exporter`](../bucket/open-aria-exporter.json), using the published Windows amd64 release and its GitHub SHA-256 digest. Its license is recorded as `Unknown`; the manifest links directly to the upstream installer and does not rehost it.

No JSON placeholders were created. A candidate can move into `bucket/` only after a current official Windows artifact, version mapping, architecture, SHA-256, package type, executable paths and install/uninstall behavior are established. Record a missing or unclear license as `Unknown`; public availability does not make a package open source. Beta packages, where deliberately accepted, must be named and tracked as beta manifests rather than presented as stable releases.
