# Software by Developer

This catalog covers the requested vendor pages and links each included program to its Scoop manifest. Programs are also grouped by their primary function in [KiroBucket Categories](categories.md). EFSoftware was already represented by 13 manifests, so those entries are cross-referenced rather than duplicated.

## Developer Index

| Developer / Suite | Manifests | Link |
| --- | ---: | --- |
| Awesome MyGo Community | 173 | [View](#awesome-mygo-showcase) |
| Aurelitec Suite | 5 | [View](categories.md#aurelitec-suite) |
| Auslogics Suite | 15 | [View](categories.md#auslogics-suite) |
| ChemTable Suite | 5 | [View](categories.md#chemtable-suite) |
| ComputerSluggish Suite | 1 | [View](categories.md#computersluggish-suite) |
| EFSoftware Suite | 13 | [View](categories.md#efsoftware-suite) |
| Eric Zimmerman Suite | 31 | [View](categories.md#eric-zimmerman-suite) |
| Funk.eu Suite | 7 | [View](categories.md#funk-eu-suite) |
| GRC Suite | 18 | [View](categories.md#grc-suite) |
| MiTeC Suite | 22 | [View](categories.md#mitec-suite) |
| Neuber Suite | 2 | [View](categories.md#neuber-suite) |
| Rizonesoft Suite | 14 | [View](categories.md#rizonesoft-suite) |
| SoftwareOK Suite | 81 | [View](categories.md#softwareok-suite) |
| Sordum Suite | 63 | [View](categories.md#sordum-suite) |
| Türkaysoft Suite | 8 | [View](categories.md#turkaysoft-suite) |
| Vovsoft Suite | 174 | [View](categories.md#vovsoft-suite) |

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

## Rizonesoft

| Program | Primary function | Functional category | Manifest |
| --- | --- | --- | --- |
| [BIOS Beep Codes Viewer](https://rizonesoft.com/downloads/bios-beep-codes-viewer/) | BIOS beep-code reference and hardware diagnostics | Forensics & Diagnostics | [bios-beep-codes-viewer](../bucket/bios-beep-codes-viewer.json) |
| [Carbon CD](https://rizonesoft.com/downloads/carbon-cd/) | CD cloning and disc-image creation | Storage & Disk Tools | [carbon-cd](../bucket/carbon-cd.json) |
| [Chromin](https://rizonesoft.com/downloads/firemin/) | Memory optimization for Chrome and Chromium-based browsers | System Monitoring & Hardware | [chromin](../bucket/chromin.json) |
| [Complete Internet Repair](https://rizonesoft.com/downloads/complete-internet-repair/) | Repair common Windows internet connectivity problems | Network & DNS | [complete-internet-repair](../bucket/complete-internet-repair.json) |
| [DVD Drive Repair](https://rizonesoft.com/downloads/dvd-drive-repair/) | Diagnose and repair DVD drive issues | Storage & Disk Tools | [dvd-drive-repair](../bucket/dvd-drive-repair.json) |
| [EdgeMin](https://rizonesoft.com/downloads/firemin/) | Memory optimization for Microsoft Edge | System Monitoring & Hardware | [edgemin](../bucket/edgemin.json) |
| [Firemin](https://rizonesoft.com/downloads/firemin/) | Reduce browser memory usage | System Monitoring & Hardware | [firemin](../bucket/firemin.json) |
| [Notepad3](https://rizonesoft.com/downloads/notepad3/) | Scintilla-based text editor with syntax highlighting | Text Utilities | [notepad3](../bucket/notepad3.json) |
| [Pixel Repair](https://rizonesoft.com/downloads/pixel-repair/) | Detect and attempt to repair stuck display pixels | System Monitoring & Hardware | [pixel-repair](../bucket/pixel-repair.json) |
| [Rizonesoft Office Alpha 5](https://rizonesoft.com/downloads/rizonesoft-office/) | Collection of office and productivity applications | Productivity & Launchers | [rizonesoft-office](../bucket/rizonesoft-office.json) |
| [Resolute](https://rizonesoft.com/downloads/resolute/) | Collection of Windows repair, maintenance, and diagnostic utilities | Other Utilities | [rizonesoft-resolute](../bucket/rizonesoft-resolute.json) |
| [Take Ownership](https://rizonesoft.com/gdm_downloads/take-ownership/) | Add or remove a Windows Take Ownership context-menu action | File Management | [take-ownership](../bucket/take-ownership.json) |
| [USB Repair](https://rizonesoft.com/downloads/usb-repair/) | Diagnose and repair USB device problems | Storage & Disk Tools | [usb-repair](../bucket/usb-repair.json) |
| [Watermin](https://rizonesoft.com/downloads/firemin/) | Memory optimization for Waterfox and compatible browsers | System Monitoring & Hardware | [watermin](../bucket/watermin.json) |

## Awesome MyGo Showcase

[Awesome MyGo](https://awesomemygo.dev/showcase?lang=en) is a community catalog of third-party desktop applications built with the MyGo framework, not a single software publisher. This section lists the 173 MyGo-related Windows manifests currently present in this bucket. Each link opens the corresponding Scoop manifest.

| Manifest |
| --- |
| [agentmeter](../bucket/agentmeter.json) |
| [ally](../bucket/ally.json) |
| [althea](../bucket/althea.json) |
| [anker-prime-desktop](../bucket/anker-prime-desktop.json) |
| [apigo](../bucket/apigo.json) |
| [arcmd](../bucket/arcmd.json) |
| [arion](../bucket/arion.json) |
| [atlas](../bucket/atlas.json) |
| [axonhub](../bucket/axonhub.json) |
| [baggy](../bucket/baggy.json) |
| [baidunetgo](../bucket/baidunetgo.json) |
| [bamboo](../bucket/bamboo.json) |
| [bentomail](../bucket/bentomail.json) |
| [bigo-live-recorder](../bucket/bigo-live-recorder.json) |
| [bili-fm](../bucket/bili-fm.json) |
| [biternet](../bucket/biternet.json) |
| [bootie](../bucket/bootie.json) |
| [ceramic](../bucket/ceramic.json) |
| [chatgo](../bucket/chatgo.json) |
| [cloudshuttle](../bucket/cloudshuttle.json) |
| [countdowner](../bucket/countdowner.json) |
| [courrier](../bucket/courrier.json) |
| [cpa-bar](../bucket/cpa-bar.json) |
| [db-g](../bucket/db-g.json) |
| [deckle](../bucket/deckle.json) |
| [dgopher](../bucket/dgopher.json) |
| [disklens](../bucket/disklens.json) |
| [droi](../bucket/droi.json) |
| [easytier-mygo](../bucket/easytier-mygo.json) |
| [enowx](../bucket/enowx.json) |
| [fnmovie](../bucket/fnmovie.json) |
| [gistmanager](../bucket/gistmanager.json) |
| [glide](../bucket/glide.json) |
| [glint](../bucket/glint.json) |
| [gocompare](../bucket/gocompare.json) |
| [gogo-explorer](../bucket/gogo-explorer.json) |
| [golauncher](../bucket/golauncher.json) |
| [gorequest](../bucket/gorequest.json) |
| [goshell](../bucket/goshell.json) |
| [gosidian](../bucket/gosidian.json) |
| [gotify-desktop](../bucket/gotify-desktop.json) |
| [gotrust](../bucket/gotrust.json) |
| [gzist-netkeeper](../bucket/gzist-netkeeper.json) |
| [he-music](../bucket/he-music.json) |
| [herdr-desktop](../bucket/herdr-desktop.json) |
| [hergo](../bucket/hergo.json) |
| [hop-mygo](../bucket/hop-mygo.json) |
| [hoyo-gacha](../bucket/hoyo-gacha.json) |
| [hyla](../bucket/hyla.json) |
| [imyemail-cloud-mygo](../bucket/imyemail-cloud-mygo.json) |
| [jianshan](../bucket/jianshan.json) |
| [kando](../bucket/kando.json) |
| [kero](../bucket/kero.json) |
| [kite](../bucket/kite.json) |
| [kivrix](../bucket/kivrix.json) |
| [klip](../bucket/klip.json) |
| [kopi](../bucket/kopi.json) |
| [kotae](../bucket/kotae.json) |
| [kube-desk](../bucket/kube-desk.json) |
| [kura](../bucket/kura.json) |
| [kyokai](../bucket/kyokai.json) |
| [launchr](../bucket/launchr.json) |
| [leaflet](../bucket/leaflet.json) |
| [leafmark](../bucket/leafmark.json) |
| [lilt](../bucket/lilt.json) |
| [liubai](../bucket/liubai.json) |
| [live-mygo](../bucket/live-mygo.json) |
| [locus](../bucket/locus.json) |
| [lorca](../bucket/lorca.json) |
| [lslan](../bucket/lslan.json) |
| [lucia](../bucket/lucia.json) |
| [lumiwerk](../bucket/lumiwerk.json) |
| [lunabox](../bucket/lunabox.json) |
| [lzsync](../bucket/lzsync.json) |
| [magpie-native-routing](../bucket/magpie-native-routing.json) |
| [mami](../bucket/mami.json) |
| [mayoi](../bucket/mayoi.json) |
| [mcl](../bucket/mcl.json) |
| [meiro](../bucket/meiro.json) |
| [melo](../bucket/melo.json) |
| [miguwave](../bucket/miguwave.json) |
| [minicode](../bucket/minicode.json) |
| [mira](../bucket/mira.json) |
| [mixmusic](../bucket/mixmusic.json) |
| [mojian](../bucket/mojian.json) |
| [moko](../bucket/moko.json) |
| [moniflip](../bucket/moniflip.json) |
| [monitorbar](../bucket/monitorbar.json) |
| [motrix-mygo](../bucket/motrix-mygo.json) |
| [mouse-mapper](../bucket/mouse-mapper.json) |
| [muo](../bucket/muo.json) |
| [my-vm](../bucket/my-vm.json) |
| [mygo-launcher](../bucket/mygo-launcher.json) |
| [mygost](../bucket/mygost.json) |
| [mylock](../bucket/mylock.json) |
| [mypack](../bucket/mypack.json) |
| [myshoes](../bucket/myshoes.json) |
| [myspotify](../bucket/myspotify.json) |
| [mytoken](../bucket/mytoken.json) |
| [mytools](../bucket/mytools.json) |
| [myvnc](../bucket/myvnc.json) |
| [nanoapi](../bucket/nanoapi.json) |
| [nekossh](../bucket/nekossh.json) |
| [nemorous](../bucket/nemorous.json) |
| [neohm](../bucket/neohm.json) |
| [new-century-renamer](../bucket/new-century-renamer.json) |
| [nomo-mygo](../bucket/nomo-mygo.json) |
| [opendl](../bucket/opendl.json) |
| [oriel](../bucket/oriel.json) |
| [osprey](../bucket/osprey.json) |
| [otool](../bucket/otool.json) |
| [outrash](../bucket/outrash.json) |
| [pickphoto](../bucket/pickphoto.json) |
| [pitstop](../bucket/pitstop.json) |
| [pomodoro](../bucket/pomodoro.json) |
| [pomodoro-mygo](../bucket/pomodoro-mygo.json) |
| [portproxy](../bucket/portproxy.json) |
| [pudmusic](../bucket/pudmusic.json) |
| [qmdr](../bucket/qmdr.json) |
| [quarry](../bucket/quarry.json) |
| [quesora-native](../bucket/quesora-native.json) |
| [quick-scan](../bucket/quick-scan.json) |
| [quosparr](../bucket/quosparr.json) |
| [rainforest](../bucket/rainforest.json) |
| [raydock](../bucket/raydock.json) |
| [rclonedrive](../bucket/rclonedrive.json) |
| [resobackup](../bucket/resobackup.json) |
| [ringo](../bucket/ringo.json) |
| [rivu](../bucket/rivu.json) |
| [rnaxray](../bucket/rnaxray.json) |
| [sakamoto](../bucket/sakamoto.json) |
| [saundo](../bucket/saundo.json) |
| [see](../bucket/see.json) |
| [sessionary](../bucket/sessionary.json) |
| [sift](../bucket/sift.json) |
| [silverwing](../bucket/silverwing.json) |
| [sona](../bucket/sona.json) |
| [sshgo](../bucket/sshgo.json) |
| [sshyard](../bucket/sshyard.json) |
| [stage-manager-for-windows](../bucket/stage-manager-for-windows.json) |
| [sunvale](../bucket/sunvale.json) |
| [sweep](../bucket/sweep.json) |
| [tangit](../bucket/tangit.json) |
| [tcpconnbenchmark](../bucket/tcpconnbenchmark.json) |
| [textviewer](../bucket/textviewer.json) |
| [thesio](../bucket/thesio.json) |
| [tiktok-live-recorder](../bucket/tiktok-live-recorder.json) |
| [titen](../bucket/titen.json) |
| [translator233](../bucket/translator233.json) |
| [type](../bucket/type.json) |
| [universal-s3-ui](../bucket/universal-s3-ui.json) |
| [video-player](../bucket/video-player.json) |
| [videodown](../bucket/videodown.json) |
| [viper](../bucket/viper.json) |
| [vocabox](../bucket/vocabox.json) |
| [voke](../bucket/voke.json) |
| [vray](../bucket/vray.json) |
| [wagyu-music](../bucket/wagyu-music.json) |
| [wallpaper](../bucket/wallpaper.json) |
| [win-xinai-de-tools-mygo](../bucket/win-xinai-de-tools-mygo.json) |
| [winswx](../bucket/winswx.json) |
| [withdo](../bucket/withdo.json) |
| [wslpilot](../bucket/wslpilot.json) |
| [xiangqi](../bucket/xiangqi.json) |
| [yeek](../bucket/yeek.json) |
| [yoho-music](../bucket/yoho-music.json) |
| [yolomcl](../bucket/yolomcl.json) |
| [yourun](../bucket/yourun.json) |
| [yt-music-player](../bucket/yt-music-player.json) |
| [ytbplus](../bucket/ytbplus.json) |
| [yunji-uml](../bucket/yunji-uml.json) |
| [zakki](../bucket/zakki.json) |
| [zeokeel-super-agent](../bucket/zeokeel-super-agent.json) |

## Checksum and update limitations

Thumbico's SHA-256 comes from the digest published with its official GitHub release. Other added downloads do not publish checksums on their official pages, so their manifests state that SHA-256 is not pinned. The Funk.eu manifests also need manual URL maintenance if the publisher changes a Download Monitor file ID.
