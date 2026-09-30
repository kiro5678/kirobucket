param(
    [Parameter(Mandatory)]
    [string]$ProductId,

    [Parameter(Mandatory)]
    [string]$OutputPath,

    [ValidateSet('x64', 'x86', 'arm64')]
    [string]$Architecture = 'x64'
)

$ErrorActionPreference = 'Stop'

$targetArchitecture = @{
    'x64' = 'amd64'
    'x86' = 'x86'
    'arm64' = 'arm64'
}[$Architecture]

$market = (Get-Culture).Name
if ([string]::IsNullOrWhiteSpace($market) -or $market -notmatch '^[A-Za-z]{2}-[A-Za-z]{2}$') {
    $market = 'en-US'
}

$displayCatalogUrl = "https://displaycatalog.mp.microsoft.com/v7.0/products/$ProductId?fieldsTemplate=Details&market=$($market.Split('-')[-1].ToUpperInvariant())&languages=$market,neutral&catalogIds=4"
$displayCatalog = Invoke-RestMethod -Uri $displayCatalogUrl -Method Get -Headers @{ 'Accept' = 'application/json' }

$sku = @($displayCatalog.Product.DisplaySkuAvailabilities) |
    Where-Object { $_.Sku.SkuId -eq '0015' } |
    Select-Object -First 1

if (-not $sku) {
    throw 'Microsoft Store display catalog did not return the expected SKU.'
}

$package = @($sku.Sku.Properties.Packages) |
    Where-Object {
        @($_.Architectures) -contains $Architecture -and
        $_.FulfillmentData.WuCategoryId
    } |
    Select-Object -First 1

if (-not $package) {
    throw "No Microsoft Store package was found for architecture $Architecture."
}

$wuCategoryId = $package.FulfillmentData.WuCategoryId
$sfsBase = "https://storeapps.api.cdp.microsoft.com/api/v2/contents/storeapps/namespaces/default/names/$wuCategoryId"

$versionResponse = Invoke-RestMethod `
    -Uri "$sfsBase/versions/latest?action=select" `
    -Method Post `
    -ContentType 'application/json' `
    -Body '{"TargetingAttributes":{}}'

$version = $versionResponse.ContentId.Version
if ([string]::IsNullOrWhiteSpace($version)) {
    throw 'Microsoft Store SFS did not return an app version.'
}

$fileResponse = Invoke-RestMethod `
    -Uri "$sfsBase/versions/$version/files?action=GenerateDownloadInfo" `
    -Method Post `
    -ContentType 'application/json'

$files = @($fileResponse) | Where-Object {
    $_.FileMoniker -and
    $_.Url -and
    $_.ApplicabilityDetails.Architectures -and
    @($_.ApplicabilityDetails.Architectures) -contains $targetArchitecture -and
    @($_.ApplicabilityDetails.PlatformApplicabilityForPackage) -match '^desktop(?:=|$)'
}

$file = $files |
    Where-Object { $_.FileId -match '.(msixbundle|msix|appxbundle|appx)$' } |
    Select-Object -First 1

if (-not $file) {
    throw "Microsoft Store SFS did not return an applicable MSIX/AppX package for $Architecture."
}

New-Item -ItemType Directory -Force -Path $OutputPath | Out-Null

$destination = Join-Path $OutputPath ([IO.Path]::GetFileName($file.FileId))
Invoke-WebRequest -Uri $file.Url -OutFile $destination

if (-not (Test-Path -LiteralPath $destination)) {
    throw 'The Microsoft Store package download did not produce a file.'
}

$destination
