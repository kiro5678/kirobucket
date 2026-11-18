# Local Scoop Installation Comparison

This workflow compares the manifests in this repository's bucket directory with the Scoop apps installed on the Windows machine that hosts the repository's self-hosted GitHub Actions runner.

## Run

1. Keep the Windows self-hosted runner online.
2. Open **Actions → Local Scoop Installation Comparison → Run workflow**.
3. Run it from the master branch.
4. Open the local report on the runner machine:

   **D:\Scoop\reports\kirobucket-installation-report.html**

The report lists each bucket manifest as installed from kirobucket, installed from another source, or not installed. It also shows the bucket and installed versions.

## Privacy

The comparison must run on a self-hosted Windows runner because a GitHub-hosted runner cannot inspect the Scoop installation on the user's PC.

The workflow reads the Scoop export in memory and writes the detailed HTML report directly to the local Scoop root. It does **not** upload the report or the Scoop export, create a workflow artifact, or print installed application names, versions, or sources in the Actions log. GitHub receives only normal workflow execution metadata and generic status messages.

The workflow is manual-only, restricted to master, and has read-only repository permissions. It does not run for pull requests.

## Requirements

- A connected Windows x64 self-hosted runner for this repository.
- Scoop installed under D:\Scoop.
- The runner service account must be able to read the Scoop root and execute Scoop.

If the Scoop root changes, update the fixed path in .github/workflows/local-scoop-installation-comparison.yml.

## Run locally without GitHub Actions

From the repository root in PowerShell 7:

~~~powershell
pwsh -NoProfile -File .\bin\compare-scoopbucket-installation.ps1 -BucketPath .\bucket -BucketName kirobucket -ScoopRoot D:\Scoop
~~~

The same local report is generated. No installed-app list is sent anywhere.
