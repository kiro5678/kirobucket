# Deleted, Retired, Renamed, and Consolidated Manifests

**Audit date:** 2026-10-20
**Source:** Git history and the current `master` bucket inventory.

This document records manifest paths that were deleted, renamed, or consolidated. A deleted manifest does **not** automatically mean the application itself was removed from the bucket. The status below distinguishes retired entries from entries with a current replacement. Dates are taken from the relevant commits (UTC).

## Retired entries or removed variants

| Former manifest | Recorded disposition | Current state / related manifest | Git history |
|---|---|---|---|
| `crapcheckthis.json` | Retired in the cleanup for unavailable upstream manifests. | No replacement manifest was identified in the current bucket. | [2026-10-13 commit](https://github.com/kiro5678/kirobucket/commit/8b6e8da97d85b27e3ddc1d1138e210bce2c11ff9) |
| `ram-cleaner-flusher-pro.json` | Retired in the same cleanup for unavailable upstream manifests. | No replacement manifest was identified in the current bucket. | [2026-10-13 commit](https://github.com/kiro5678/kirobucket/commit/8b6e8da97d85b27e3ddc1d1138e210bce2c11ff9) |
| `minimalfirewall.json` | The removal commit describes this as a duplicate manifest. | No replacement path was specified in that commit; no same-named manifest exists on `master`. | [2026-09-29 commit](https://github.com/kiro5678/kirobucket/commit/d4e4a3074e0d177c7c06ec98a54584f47b2c349a) |
| `widbar.json` | Removed as part of retiring the Store-wrapper manifest path. | No WidBar manifest currently remains in the bucket. The associated Store helper script was also removed as obsolete. | [Manifest removal](https://github.com/kiro5678/kirobucket/commit/6c57ff5fc2e2201ecd2a010c07c1c1b9bd20423d) · [helper cleanup](https://github.com/kiro5678/kirobucket/commit/1066e39e) |
| `widbar-winget.json` | Removed as part of retiring the WinGet-based manifest path. | No WidBar manifest currently remains in the bucket. The associated WinGet helper script was also removed as obsolete. | [Manifest removal](https://github.com/kiro5678/kirobucket/commit/0e48f8593891e804f0620e208996760f50e72c11) · [helper cleanup](https://github.com/kiro5678/kirobucket/commit/1cea0e70) |
| `windhawk-alpha.json` | The separate alpha-channel manifest was removed. | The regular [`windhawk.json`](../bucket/windhawk.json) manifest remains. | [2026-09-30 commit](https://github.com/kiro5678/kirobucket/commit/b56b1a421d9b7e17584d30bd1fc9b93a20084afe) |
| `livewallpaper-nightly.json` | The separate nightly manifest was removed. | The regular [`livewallpaper.json`](../bucket/livewallpaper.json) manifest remains. The removal commit does not record a more specific rationale. | [2026-09-30 commit](https://github.com/kiro5678/kirobucket/commit/ba71ad690c6a1706621cc3e4039de7a9c217fa53) |
| `tcno-acc-switcher-nightly.json` | The separate nightly manifest was removed. | The regular [`tcno-acc-switcher.json`](../bucket/tcno-acc-switcher.json) manifest remains. The removal commit does not record a more specific rationale. | [2026-09-30 commit](https://github.com/kiro5678/kirobucket/commit/a5f4224415d6882fca0d78312dd293f0aac05656) |
| `nomina-setup.json` | The setup-specific manifest was removed. | The [`nomina.json`](../bucket/nomina.json) manifest remains. The removal commit does not record a more specific rationale. | [2026-09-30 commit](https://github.com/kiro5678/kirobucket/commit/c8373c14b9e452c76c20cbd8c7babc40ca8e6adc) |
| `nvidiaprofileinspector-portable.json` | The separately named portable manifest was removed. | The [`nvidiaprofileinspector.json`](../bucket/nvidiaprofileinspector.json) manifest remains. The removal commit does not record a more specific rationale. | [2026-09-30 commit](https://github.com/kiro5678/kirobucket/commit/3d65270e8ad3bc13709f9466967d9631579c77c0) |
| `coodesker-portable.json` | Removed because the commit explicitly identified it as an incorrect portable manifest; the installer must not be assumed to be portable. | [`coodesker.json`](../bucket/coodesker.json) and [`coodesker-github.json`](../bucket/coodesker-github.json) remain. | [2026-09-29 commit](https://github.com/kiro5678/kirobucket/commit/af51833ef75f1e96c12ae6dc65d482ce7da448eb) |
| `motrix-nightly.json` | The separate nightly-channel manifest was removed. | The regular [`motrix.json`](../bucket/motrix.json) manifest remains. The removal commit does not record a more specific rationale. | [2026-09-29 commit](https://github.com/kiro5678/kirobucket/commit/2c723a6cf89f7558cbfed8a9a5fa301091a5f5cf) |
| `spacedrive-alpha.json` | The separate alpha/pre-release manifest was removed. | The regular [`spacedrive.json`](../bucket/spacedrive.json) manifest remains. The removal commit does not record a more specific rationale. | [2026-09-29 commit](https://github.com/kiro5678/kirobucket/commit/079b23aea7178f6432504a6820aeffccc86a1386) |
| `motrix-next-beta.json` | The separate beta-specific manifest was removed. | The [`motrix-next.json`](../bucket/motrix-next.json) manifest remains. The removal commit does not record a more specific rationale. | [2026-09-29 commit](https://github.com/kiro5678/kirobucket/commit/962f6a33971ff4b078267f2d4cc60f29e0be9957) |
| `edge-drop-portable.json` | Removed because the commit explicitly identified it as an invalid portable manifest. | The regular [`edge-drop.json`](../bucket/edge-drop.json) manifest remains. | [2026-09-29 commit](https://github.com/kiro5678/kirobucket/commit/e36af0c696f59ff290c5c0a4421f956e2c3fb230) |

## Consolidated or replaced manifests

| Former manifest(s) | Replacement / disposition | Git history |
|---|---|---|
| `pdfcraft.json`, `pdfcraft-exe.json` | Replaced by one [`PdfCraftTool.json`](../bucket/PdfCraftTool.json) manifest using the portable ZIP release. This is a packaging/manifest consolidation, not removal of PDFCraft itself. | [2026-10-13 commit](https://github.com/kiro5678/kirobucket/commit/2b3a0ab8766bbd74e61aae52eaca965bdb24a3a0) |
| `kudu-portable.json`, `kudu-setup.json` | Consolidated into [`kudu.json`](../bucket/kudu.json), using the portable x64 ZIP. | [2026-09-30 commit](https://github.com/kiro5678/kirobucket/commit/9c15b9b65f7df4e5781687a39a9757a0fdc209c8) |
| `unigetuiglobal.json` | Originally removed as a duplicate on 2026-10-08; restored on 2026-10-24 as a distinct global-data variant. The restored manifest removes `ForceUniGetUIPortable` and copies legacy Scoop-local `Settings` entries to `%LOCALAPPDATA%\UniGetUI` only when corresponding destination entries do not already exist. The separate [`unigetui-portable.json`](../bucket/unigetui-portable.json) remains the portable variant. | [2026-10-08 commit](https://github.com/kiro5678/kirobucket/commit/a782fa2af402dea214bb995bc000b2a5442a6faa) |
| `timescribe-portable.json` | Renamed to [`timescribe.json`](../bucket/timescribe.json); this was a path/name change, not retirement of TimeScribe. | [new name](https://github.com/kiro5678/kirobucket/commit/ca8b072513177d0bae9b54e996362939cf23a7e4) · [old name removed](https://github.com/kiro5678/kirobucket/commit/c764468699ae53ca5bfe798edab0401f261b10df) |
| `glowz-dock-portable.json` | Folded into [`glowz-dock.json`](../bucket/glowz-dock.json); the main manifest was changed to use the portable ZIP release instead of a setup installer. | [2026-10-13 commit](https://github.com/kiro5678/kirobucket/commit/648120727d3c58528680ae4d1a05c94f57d6113a) |
| `glow.json` | Renamed to [`turkaysoft-glow.json`](../bucket/turkaysoft-glow.json) to avoid a Scoop manifest-name collision. | [2026-10-13 commit](https://github.com/kiro5678/kirobucket/commit/d11ccf728f7695f3c149e82de4b593027dc90d0b) |

## Audit notes

- The list above is based on identifiable file-deletion, rename, and consolidation commits in the repository history up to 2026-10-20.
- Where a commit only says that a file was removed, the log does not invent a technical reason; it records the surviving related manifest, if one exists.
- A stale category key such as `developer-placeholder` was not counted as a deleted manifest because this audit did not find a corresponding `bucket/developer-placeholder.json` deletion.
- This document records history only. It does not restore any files or change the current manifest set.


## Addendum — 2026-10-31 manifest removals

| Former manifest | Recorded disposition | Current state / reason | Git history |
|---|---|---|---|
| `wintor.json` | Removed at the user's request. | The manifest installed the Microsoft Store package through winget; no Wintor manifest remains in the bucket. | [2026-10-31 commit](https://github.com/kiro5678/kirobucket/commit/7d9875f86281ae87ee7fa8a9106036c0ac2461fc) |
| `cliptray.json` | Removed at the user's request. | The manifest downloaded a source archive and attempted a local Windows build; the build and runtime had not been verified. No replacement manifest remains. | [2026-10-31 commit](https://github.com/kiro5678/kirobucket/commit/c6ca9b73a69abfa0769cf35ed6985f579e1faf49) |
| `yerel.json` | Removed at the user's request. | The manifest downloaded a source archive and attempted a local build; the Windows build and runtime had not been verified. No replacement manifest remains. | [2026-10-31 commit](https://github.com/kiro5678/kirobucket/commit/bf6214ace5835f05618f6489d0aed34f5c016940) |

- The current bucket inventory after these removals contains 832 manifests: 771 Portable, 56 Nonportable, and 5 Review.
- The ZIP archive installer-type group now contains 560 manifests.
- This addendum is appended history; existing records above were left unchanged.
