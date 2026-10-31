# Microsoft Store-only notch apps

These two applications were part of the Windows notch shortlist, but no independent Windows installer, portable archive, or publicly downloadable MSIX asset is published for the listed Store distributions.

| Application | Publisher | Microsoft Store Product ID | Store listing |
| --- | --- | --- | --- |
| Smart Notch | Dev_avinash | `9N1D46F5X565` | https://apps.microsoft.com/detail/9N1D46F5X565 |
| WinIsland | Deep Skylabs | `9NZS0L1XTQ8Q` | https://apps.microsoft.com/detail/9NZS0L1XTQ8Q |

Scoop manifests in this bucket require a real downloadable package or installer asset. Do not substitute the Microsoft Store HTML page for an installer, invent an MSIX URL, or create a fake hash. These listings should be installed through Microsoft Store or WinGet's `msstore` source, which handles Store package registration and updates.

The existing [winisland.json](../bucket/winisland.json) is a different project (`zHeuzy2/WinIsland`) distributed as a portable GitHub ZIP. It is deliberately retained unchanged and must not be confused with Deep Skylabs' Store app.
