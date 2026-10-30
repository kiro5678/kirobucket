$ErrorActionPreference = 'Stop'

$maxConcurrentRequests = 20
$scoopRoot = Join-Path $env:USERPROFILE 'SCOOP'
$scoopShim = Join-Path $scoopRoot 'shims\scoop.ps1'

if (-not (Test-Path -LiteralPath $scoopShim -PathType Leaf)) {
    throw "Scoop is not installed at the expected path: $scoopShim"
}

$scoopHome = Join-Path $scoopRoot 'apps\scoop\current'
$checkverPath = Join-Path $scoopHome 'bin\checkver.ps1'
if (-not (Test-Path -LiteralPath $checkverPath -PathType Leaf)) {
    throw "Scoop checkver.ps1 was not found: $checkverPath"
}

$source = [System.IO.File]::ReadAllText($checkverPath)
$newLine = [string][char]10
$crlf = [string][char]13 + [string][char]10
if ($source.Contains($crlf)) { $newLine = $crlf }

function Replace-Once {
    param(
        [Parameter(Mandatory)][string]$Text,
        [Parameter(Mandatory)][string]$Old,
        [Parameter(Mandatory)]
        [AllowEmptyString()]
        [string]$New,
        [Parameter(Mandatory)][string]$Label
    )
    $count = ([regex]::Matches($Text, [regex]::Escape($Old))).Count
    if ($count -ne 1) {
        throw "Expected exactly one occurrence of '$Label' in Scoop checkver.ps1; found $count. No patch was written."
    }
    return $Text.Replace($Old, $New)
}

$queueStartMarker = '# start all downloads'
$queueEndMarker = 'function next($er) {'
$queueStart = $source.IndexOf($queueStartMarker, [System.StringComparison]::Ordinal)
$queueEnd = $source.IndexOf($queueEndMarker, $queueStart, [System.StringComparison]::Ordinal)

if ($queueStart -lt 0 -or $queueEnd -lt 0 -or $queueEnd -le $queueStart) {
    throw 'Scoop checkver.ps1 has an unrecognized download-queue layout. No patch was written.'
}

$queueBlock = $source.Substring($queueStart, $queueEnd - $queueStart)
$queueBlock = Replace-Once -Text $queueBlock -Old '# start all downloads' -New '# Start a bounded queue of Checkver HTTP requests.' -Label 'queue comment'
$queueBlock = Replace-Once -Text $queueBlock -Old '$in_progress = 0' -New '' -Label 'initial in-progress counter'
$queueLoopHeader = @'
function Start-CheckverRequests {
    while ($checkverScheduler.InProgress -lt $checkverScheduler.MaxConcurrent -and $checkverScheduler.Queue.Count -gt 0) {
        $name, $json, $file = $checkverScheduler.Queue.Dequeue()
'@
$queueBlock = Replace-Once -Text $queueBlock -Old '$Queue | ForEach-Object {' -New $queueLoopHeader -Label 'request queue loop'
$queueBlock = Replace-Once -Text $queueBlock -Old '    $name, $json, $file = $_' -New '' -Label 'queued manifest unpack'
$queueBlock = Replace-Once -Text $queueBlock -Old '            return' -New '            continue' -Label 'skip malformed checkver manifest'
$queueBlock = Replace-Once -Text $queueBlock -Old '$in_progress++' -New '$checkverScheduler.InProgress++' -Label 'in-progress increment'
$githubRatePacing = @'
    if ($url -match '(?i)^https://api\.github\.com/') {
        if ($null -ne $checkverScheduler.LastGitHubRequestUtc) {
            $elapsedMilliseconds = ([DateTime]::UtcNow - $checkverScheduler.LastGitHubRequestUtc).TotalMilliseconds
            $waitMilliseconds = [int][Math]::Ceiling($checkverScheduler.GitHubRequestIntervalMilliseconds - $elapsedMilliseconds)
            if ($waitMilliseconds -gt 0) {
                Start-Sleep -Milliseconds $waitMilliseconds
            }
        }
        $checkverScheduler.LastGitHubRequestUtc = [DateTime]::UtcNow
    }
'@
$queueBlock = Replace-Once -Text $queueBlock -Old '    $wc.DownloadDataAsync($url, $state)' -New ($githubRatePacing + $newLine + '    $wc.DownloadDataAsync($url, $state)') -Label 'GitHub API request pacing'
$queueBlock = $queueBlock.TrimEnd() + $newLine + '}'

$schedulerInit = @'
$checkverScheduler = [PSCustomObject]@{
    Queue = [System.Collections.Generic.Queue[object]]::new()
    InProgress = 0
    MaxConcurrent = 20
    LastGitHubRequestUtc = $null
    GitHubRequestIntervalMilliseconds = 100
}
foreach ($item in $Queue) {
    $checkverScheduler.Queue.Enqueue($item)
}

'@

$patchedQueue = $schedulerInit + $queueBlock + $newLine + $newLine
$source = $source.Substring(0, $queueStart) + $patchedQueue + $source.Substring($queueEnd)

$source = Replace-Once -Text $source -Old '        replace  = $replace' -New ('        replace  = $replace' + $newLine + '        webclient = $wc') -Label 'WebClient state reference'
$source = Replace-Once -Text $source -Old '$state = $ev.SourceEventArgs.UserState' -New ('$state = $ev.SourceEventArgs.UserState' + $newLine + '    $wc = $state.webclient') -Label 'event WebClient restoration'
$source = Replace-Once -Text $source -Old 'while ($in_progress -gt 0) {' -New 'while ($checkverScheduler.InProgress -gt 0) {' -Label 'event loop condition'
$source = Replace-Once -Text $source -Old '    $in_progress--' -New '    $checkverScheduler.InProgress--' -Label 'event loop decrement'
$source = Replace-Once -Text $source -Old '$matchesHashtable = @{}' -New ('$matchesHashtable = @{}' + $newLine + $newLine + '    try {') -Label 'event processing try/finally'

$waitMarker = '# wait for all to complete'
$waitIndex = $source.IndexOf($waitMarker, [System.StringComparison]::Ordinal)
if ($waitIndex -lt 0) {
    throw 'Could not find the Checkver event-loop marker. No patch was written.'
}
$source = $source.Substring(0, $waitIndex) + 'Start-CheckverRequests' + $newLine + $newLine + $source.Substring($waitIndex)

$lastBrace = $source.TrimEnd().LastIndexOf('}')
if ($lastBrace -lt 0) {
    throw 'Could not find the end of the Checkver event loop. No patch was written.'
}
$finallyBlock = @'
    } catch {
        error "$app checkver processing failed: $($_.Exception.Message)"
        Write-Host $_.ScriptStackTrace -ForegroundColor DarkRed
    } finally {
        Unregister-Event -SourceIdentifier $ev.SourceIdentifier -ErrorAction SilentlyContinue
        if ($state.webclient) {
            $state.webclient.Dispose()
        }
        Start-CheckverRequests
    }
'@
$source = $source.Substring(0, $lastBrace) + $finallyBlock + $newLine + $source.Substring($lastBrace)

$required = @(
    'MaxConcurrent = 20',
    'GitHubRequestIntervalMilliseconds = 100',
    '$checkverScheduler.LastGitHubRequestUtc = [DateTime]::UtcNow',
    'function Start-CheckverRequests',
    '$state = $ev.SourceEventArgs.UserState',
    '$wc = $state.webclient',
    'while ($checkverScheduler.InProgress -gt 0)',
    'Start-CheckverRequests',
    'Unregister-Event -SourceIdentifier $ev.SourceIdentifier',
    'checkver processing failed:'
)
foreach ($fragment in $required) {
    if (-not $source.Contains($fragment)) {
        throw "Post-patch verification failed: missing '$fragment'."
    }
}
if ($source.Contains('while ($in_progress -gt 0)') -or
    $source.Contains('$Queue | ForEach-Object {') -or
    $source.Contains('$in_progress++') -or
    $source.Contains('$in_progress--')
) {
    throw 'Post-patch verification failed: the unbounded download loop is still present.'
}

[System.IO.File]::WriteAllText($checkverPath, $source, [System.Text.UTF8Encoding]::new($false))
Write-Host "Patched Scoop checkver.ps1: maximum $maxConcurrentRequests concurrent requests."
Write-Host 'GitHub API request start interval: 100 ms (maximum 10 starts per second).'
Write-Host "Patched file: $checkverPath"
