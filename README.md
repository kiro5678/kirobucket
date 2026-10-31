KiroBucket is currently a work in progress and is not stable yet. Some manifests may require changes or may stop working when upstream applications are updated.
 I am still learning, testing manifests, fixing problems, and improving the repository over time.

I am not a developer, but I really enjoy using Scoop. It has made managing Windows applications much easier for me, so I decided to create my own Scoop bucket.


Suggestions, bug reports, manifest improvements, and other constructive feedback are very welcome. They can help me improve the bucket and learn more along the way.

Please keep in mind that some manifests may not work perfectly, and changes may sometimes introduce new issues.
Installation

First, make sure Scoop is installed on your system.

Add KiroBucket:

"scoop bucket add kirobucket https://github.com/kiro5678/kirobucket"

To remove KiroBucket:
"scoop bucket rm kirobucket"

If you like the project, don’t forget to support me by giving it a star.

Thank you for taking the time to check out the project.

https://github.com/ScoopInstaller/Scoop

https://github.com/ScoopInstaller/BucketTemplate

[the manifest rules](docs/manifest-authoring.md).



## Software by developer and function

See [the source-site software catalog](docs/software-by-developer.md) for a developer-grouped index, with each app's primary function and manifest link. The [category index](docs/categories.md) lists manifests by function and publisher suite.

## Manifests

The complete, automatically generated manifest inventory is maintained in [`docs/manifests.md`](docs/manifests.md). It includes each app's category, version, installer type, manifest-added date, upstream program-update date, homepage, and description.

Use the links in the inventory to view manifests sorted by name, category, or date. The page is regenerated from the JSON files in `bucket/` by the [manifest documentation workflow](.github/workflows/manifest-table.yml).
