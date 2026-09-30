param(
    [Parameter(Mandatory)]
    [string]$ProductId,

    [Parameter(Mandatory)]
    [string]$OutputPath
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

$package = $links |
    Where-Object { $_ -match '(?i)(x64|amd64)' } |
    Select-Object -First 1

if (-not $package) {
    $package = $links | Select-Object -First 1
}

$fileName = [IO.Path]::GetFileName(([uri]$package).AbsolutePath)
$destination = Join-Path $OutputPath $fileName

Invoke-WebRequest -Uri $package -OutFile $destination -UseBasicParsing

if (-not (Test-Path -LiteralPath $destination)) {
    throw 'Microsoft Store package download failed.'
}

$destination
