# Software by Developer and Function

This catalog covers the requested vendor pages and links each included program to its Scoop manifest. Programs are also grouped by their primary function in [KiroBucket Categories](categories.md). EFSoftware was already represented by 13 manifests, so those entries are cross-referenced rather than duplicated.

## Aurelitec

| Program | Primary function | Functional category | Manifest |
| --- | --- | --- | --- |
| [cinemadrape](https://www.aurelitec.com/cinemadrape/) | Focus / dim inactive screen areas | Productivity & Launchers | [aurelitec-cinemadrape](../bucket/aurelitec-cinemadrape.json) |
| [injuredpixels](https://www.aurelitec.com/injuredpixels/) | Display pixel testing | System Monitoring & Hardware | [aurelitec-injuredpixels](../bucket/aurelitec-injuredpixels.json) |
| [pixelhealer](https://www.aurelitec.com/pixelhealer/) | Attempt to recover stuck/hot pixels | System Monitoring & Hardware | [aurelitec-pixelhealer](../bucket/aurelitec-pixelhealer.json) |
| [thumbico](https://www.aurelitec.com/thumbico/) | Preview/export Windows thumbnails and icons | Images & Photos | [aurelitec-thumbico](../bucket/aurelitec-thumbico.json) |
| [portmarks](https://www.aurelitec.com/portmarks/) | Portable bookmark/link files | Browsers & Communication | [aurelitec-portmarks](../bucket/aurelitec-portmarks.json) |

## ComputerSluggish

| Program | Primary function | Functional category | Manifest |
| --- | --- | --- | --- |
| [CS Easy Unlocker](https://computersluggish.com/cs-easy-unlocker/) | Find and release file/folder locks | File Management | [computersluggish-cs-easy-unlocker](../bucket/computersluggish-cs-easy-unlocker.json) |

Other main desktop products listed by ComputerSluggish currently link to MSI installers (Easy Gamer Utility, Easy System Utility, Ultimate Power Assistant, Phoenix Customizer, Blocker Web, Distraction Blocker, and Computer Game Booster). They are not included yet because their MSI layouts and Scoop-managed install/uninstall behavior have not been validated. Easy Browser Cleaner is a browser extension, not a standalone Windows desktop program. aSysPanel and AceShutdown need a verified current version/download source before they can be packaged.

## EFSoftware

The order/download page is already represented by 13 manifests; creating them again would duplicate existing packages.

| Program | Primary function | Functional category | Manifest |
| --- | --- | --- | --- |
| EF Commander | Dual-pane file management and network transfers | File Management | [ef-commander](../bucket/ef-commander.json) |
| EF AutoSync | File synchronization | Sync & Backup | [ef-autosync](../bucket/ef-autosync.json) |
| EF Checksum Manager | File checksum generation and verification | Security | [ef-checksum-manager](../bucket/ef-checksum-manager.json) |
| EF Duplicate Files Manager | Duplicate file detection | File Management | [ef-duplicate-files-manager](../bucket/ef-duplicate-files-manager.json) |
| EF Duplicate MP3 Finder | Duplicate audio detection | Media & Audio/Video | [ef-duplicate-mp3-finder](../bucket/ef-duplicate-mp3-finder.json) |
| EF File Catalog | File cataloging | File Management | [ef-file-catalog](../bucket/ef-file-catalog.json) |
| EF Find | File search | File Management | [ef-find](../bucket/ef-find.json) |
| EF Mailbox Manager | Mailbox management | Browsers & Communication | [ef-mailbox-manager](../bucket/ef-mailbox-manager.json) |
| EF Multi File Renamer | Batch renaming | File Management | [ef-multi-file-renamer](../bucket/ef-multi-file-renamer.json) |
| EF Process Manager | Process management | System Monitoring & Hardware | [ef-process-manager](../bucket/ef-process-manager.json) |
| EF Startup Manager | Startup management | Windows Privacy & Tweaks | [ef-startup-manager](../bucket/ef-startup-manager.json) |
| EF System Monitor | System monitoring | System Monitoring & Hardware | [ef-system-monitor](../bucket/ef-system-monitor.json) |
| EF Talk Scriber | Audio-assisted transcription | Media & Audio/Video | [ef-talk-scriber](../bucket/ef-talk-scriber.json) |

## Funk.eu

| Program | Primary function | Functional category | Manifest |
| --- | --- | --- | --- |
| [SMF](https://funk.eu/smf/) | File search, duplicate detection, and file operations | File Management | [funk-smf](../bucket/funk-smf.json) |
| [HMW](https://funk.eu/hmw/) | Hide Windows applications/windows | Windows Privacy & Tweaks | [funk-hmw](../bucket/funk-hmw.json) |
| [HRC](https://funk.eu/hrc/) | Hotkeys for display resolution switching | Windows Customization | [funk-hrc](../bucket/funk-hrc.json) |
| [COP](https://funk.eu/cop/) | Screen color picker | Images & Photos | [funk-cop](../bucket/funk-cop.json) |
| [ICU](https://funk.eu/icu-icon-configuration-utility/) | Save/restore desktop icon layouts | Windows Customization | [funk-icu](../bucket/funk-icu.json) |
| [BIC](https://funk.eu/bic-batch-image-cropper/) | Batch image cropping | Images & Photos | [funk-bic](../bucket/funk-bic.json) |
| [SSD](https://funk.eu/ssd/) | Switch default Windows audio devices | Media & Audio/Video | [funk-ssd](../bucket/funk-ssd.json) |

Funk.eu uses opaque Download Monitor file IDs instead of versioned URLs. Each manifest documents this limitation; a future change to a file ID will require updating that manifest's URL. The SHA-256 values are not published by Funk.eu and are therefore not pinned.

## Neuber Software

| Program | Primary function | Functional category | Manifest |
| --- | --- | --- | --- |
| [security task manager](https://www.neuber.com/taskmanager/) | Process inspection and security-risk indicators | System Monitoring & Hardware | [neuber-security-task-manager](../bucket/neuber-security-task-manager.json) |
| [fonttwister](https://www.neuber.com/twister/) | Font effects, text graphics, and thumbnails | Images & Photos | [neuber-fonttwister](../bucket/neuber-fonttwister.json) |

Neuber also lists Typograf, Visual TimeAnalyzer, and Learn to Type/TypingCenter. Their current downloads are installer executables, not verified portable payloads; they are not included until unattended installation and uninstallation can be validated. PC On/Off Time, Svchost Process Analyzer, and VoicesInstaller are freeware but do not publish numbered versions. They need a verified version signal before being added under the bucket's update-tracking rules.

## Checksum and update limitations

Thumbico's SHA-256 comes from the digest published with its official GitHub release. Other added downloads do not publish checksums on their official pages, so their manifests state that SHA-256 is not pinned. The Funk.eu manifests also need manual URL maintenance if the publisher changes a Download Monitor file ID.
