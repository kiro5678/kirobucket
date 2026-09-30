param(
    [Parameter(Mandatory)]
    [string]$ProductId,

    [Parameter(Mandatory)]
    [string]$OutputPath,

    [ValidateSet('x64', 'x86', 'arm64')]
    [string]$Architecture = 'x64'
)

$ErrorActionPreference = 'Stop'

$api = 'https://store.rg-adguard.net/api/GetFiles'

$response = Invoke-WebRequest -Uri $api -Method Post -Body @{
    type = 'ProductId'
    url  = $ProductId
    ring = 'Retail'
    lang = 'en-US'
} -UseBasicParsing

$links = [regex]::Matches($response.Content, 'href=["'']([^"'']+)["'']', 'IgnoreCase') |
    ForEach-Object { [System.Net.WebUtility]::HtmlDecode($_.Groups[1].Value) } |
    Where-Object { $_ -match '(?i)\.(msixbundle|msix)(\?|$)' } |
    Select-Object -Unique

if (-not $links) {
    throw 'No MSIX/MSIXBundle package was returned for the Microsoft Store product.'
}

$pattern = switch ($Architecture) {
    'x64'   { '(?i)(x64|amd64)' }
    'x86'   { '(?i)(x86|x32|32.?bit)' }
    'arm64' { '(?i)(arm64|aarch64)' }
}

$package = $links | Where-Object { $_ -match $pattern } | Select-Object -First 1

if (-not $package) {
    throw "No $Architecture MSIX/MSIXBundle package was returned."
}

$fileName = [IO.Path]::GetFileName(([uri]$package).AbsolutePath)
$destination = Join-Path $OutputPath $fileName

Invoke-WebRequest -Uri $package -OutFile $destination -UseBasicParsing

if (-not (Test-Path -LiteralPath $destination)) {
    throw 'Microsoft Store package download failed.'
}

$destination
