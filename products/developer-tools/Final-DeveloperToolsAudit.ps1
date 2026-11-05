#Requires -Version 7.0

<#
.SYNOPSIS
    Finaler lokaler Audit fuer CoreCraft Genesis Developer Tools.

.DESCRIPTION
    Prueft:
    - erwartete Developer-Tools-Seiten
    - erwartete Assets
    - leere Dateien
    - JSON-Syntax
    - interne HTML-Links
    - CSS- und JavaScript-Referenzen
    - Developer-Tools-Navigation

    Das Skript veraendert keine Projektdateien.

.EXITCODES
    0 = PASS
    1 = FAIL
#>

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

# ============================================================
# KONFIGURATION
# ============================================================

$RepositoryRoot = "C:\corecraftgenesis-github"
$DeveloperToolsRoot = Join-Path $RepositoryRoot "products\developer-tools"

$ExpectedPages = @(
    "index.html"
    "automation\index.html"
    "validators\index.html"
    "validators\json\index.html"
    "validators\schema\index.html"
    "validators\file\index.html"
    "generators\index.html"
    "diagnostics\index.html"
    "diagnostics\sha256\index.html"
    "diagnostics\manifest-inspector\index.html"
    "data-tools\index.html"
    "data-tools\json-formatter\index.html"
    "data-tools\data-inspector\index.html"
    "web-tools\index.html"
    "web-tools\route-checker\index.html"
    "web-tools\link-checker\index.html"
    "developer\index.html"
)

$ExpectedAssets = @(
    "assets\css\developer-tools.css"
    "assets\js\developer-tools.js"
    "assets\js\ui.js"
    "data\tools.json"
    "data\capabilities.json"
    "data\architecture.json"
)

$ExpectedRoutes = @(
    "/products/developer-tools/"
    "/products/developer-tools/automation/"
    "/products/developer-tools/validators/"
    "/products/developer-tools/validators/json/"
    "/products/developer-tools/validators/schema/"
    "/products/developer-tools/validators/file/"
    "/products/developer-tools/generators/"
    "/products/developer-tools/diagnostics/"
    "/products/developer-tools/diagnostics/sha256/"
    "/products/developer-tools/diagnostics/manifest-inspector/"
    "/products/developer-tools/data-tools/"
    "/products/developer-tools/data-tools/json-formatter/"
    "/products/developer-tools/data-tools/data-inspector/"
    "/products/developer-tools/web-tools/"
    "/products/developer-tools/web-tools/route-checker/"
    "/products/developer-tools/web-tools/link-checker/"
    "/products/developer-tools/developer/"
)

# ============================================================
# HELPER
# ============================================================

function Write-Section {

    param(
        [Parameter(Mandatory)]
        [string]$Title
    )

    Write-Host ""
    Write-Host $Title -ForegroundColor Cyan
    Write-Host "------------------------------------------------------------"
}

function Write-Result {

    param(
        [Parameter(Mandatory)]
        [ValidateSet("PASS", "FAIL", "INFO")]
        [string]$Status,

        [Parameter(Mandatory)]
        [string]$Message
    )

    $Color = switch ($Status) {
        "PASS" { "Green" }
        "FAIL" { "Red" }
        "INFO" { "Cyan" }
    }

    Write-Host "[$Status] $Message" -ForegroundColor $Color
}

# ============================================================
# HEADER
# ============================================================

Write-Host ""
Write-Host "============================================================" -ForegroundColor Cyan
Write-Host " CORECRAFT GENESIS - FINAL DEVELOPER TOOLS AUDIT" -ForegroundColor Cyan
Write-Host "============================================================" -ForegroundColor Cyan

# ============================================================
# ROOT VALIDATION
# ============================================================

Write-Section "ROOT VALIDATION"

if (-not (Test-Path -LiteralPath $RepositoryRoot -PathType Container)) {
    Write-Result "FAIL" "Repository-Root fehlt."
    exit 1
}

Write-Result "PASS" "Repository-Root vorhanden."

if (-not (Test-Path -LiteralPath $DeveloperToolsRoot -PathType Container)) {
    Write-Result "FAIL" "Developer-Tools-Root fehlt."
    exit 1
}

Write-Result "PASS" "Developer-Tools-Root vorhanden."

# ============================================================
# PAGE VALIDATION
# ============================================================

Write-Section "DEVELOPER TOOLS PAGE VALIDATION"

$PageResults = @()

foreach ($RelativePath in $ExpectedPages) {

    $FullPath = Join-Path $DeveloperToolsRoot $RelativePath

    if (Test-Path -LiteralPath $FullPath -PathType Leaf) {

        $File = Get-Item -LiteralPath $FullPath

        $Status = if ($File.Length -gt 0) {
            "PASS"
        }
        else {
            "FAIL"
        }

        $PageResults += [pscustomobject]@{
            Status = $Status
            Page   = $RelativePath
            Bytes  = $File.Length
        }
    }
    else {

        $PageResults += [pscustomobject]@{
            Status = "FAIL"
            Page   = $RelativePath
            Bytes  = 0
        }
    }
}

foreach ($Result in $PageResults) {

    $Color = if ($Result.Status -eq "PASS") {
        "Green"
    }
    else {
        "Red"
    }

    Write-Host (
        "[{0}] {1,-32} {2,8} bytes" -f
        $Result.Status,
        $Result.Page,
        $Result.Bytes
    ) -ForegroundColor $Color
}

$PageFailures = @(
    $PageResults |
    Where-Object {
        $_.Status -eq "FAIL"
    }
)

# ============================================================
# ASSET VALIDATION
# ============================================================

Write-Section "DEVELOPER TOOLS ASSET VALIDATION"

$AssetResults = @()

foreach ($RelativePath in $ExpectedAssets) {

    $FullPath = Join-Path $DeveloperToolsRoot $RelativePath

    if (Test-Path -LiteralPath $FullPath -PathType Leaf) {

        $File = Get-Item -LiteralPath $FullPath

        $Status = if ($File.Length -gt 0) {
            "PASS"
        }
        else {
            "FAIL"
        }

        $AssetResults += [pscustomobject]@{
            Status = $Status
            Asset  = $RelativePath
            Bytes  = $File.Length
        }
    }
    else {

        $AssetResults += [pscustomobject]@{
            Status = "FAIL"
            Asset  = $RelativePath
            Bytes  = 0
        }
    }
}

foreach ($Result in $AssetResults) {

    $Color = if ($Result.Status -eq "PASS") {
        "Green"
    }
    else {
        "Red"
    }

    Write-Host (
        "[{0}] {1,-38} {2,8} bytes" -f
        $Result.Status,
        $Result.Asset,
        $Result.Bytes
    ) -ForegroundColor $Color
}

$AssetFailures = @(
    $AssetResults |
    Where-Object {
        $_.Status -eq "FAIL"
    }
)

# ============================================================
# JSON VALIDATION
# ============================================================

Write-Section "JSON VALIDATION"

$JsonFiles = @(
    Get-ChildItem `
        -LiteralPath (Join-Path $DeveloperToolsRoot "data") `
        -Filter "*.json" `
        -File `
        -ErrorAction Stop
)

$JsonResults = @()

foreach ($JsonFile in $JsonFiles) {

    try {

        $RawJson = Get-Content `
            -LiteralPath $JsonFile.FullName `
            -Raw `
            -ErrorAction Stop

        if ([string]::IsNullOrWhiteSpace($RawJson)) {
            throw "JSON-Datei ist leer."
        }

        $null = $RawJson |
            ConvertFrom-Json -ErrorAction Stop

        $JsonResults += [pscustomobject]@{
            Status  = "PASS"
            File    = $JsonFile.Name
            Message = "Gueltiges JSON"
        }
    }
    catch {

        $JsonResults += [pscustomobject]@{
            Status  = "FAIL"
            File    = $JsonFile.Name
            Message = $_.Exception.Message
        }
    }
}

foreach ($Result in $JsonResults) {

    if ($Result.Status -eq "PASS") {
        Write-Result "PASS" (
            "{0} - {1}" -f
            $Result.File,
            $Result.Message
        )
    }
    else {
        Write-Result "FAIL" (
            "{0} - {1}" -f
            $Result.File,
            $Result.Message
        )
    }
}

$JsonFailures = @(
    $JsonResults |
    Where-Object {
        $_.Status -eq "FAIL"
    }
)

# ============================================================
# HTML FILES
# ============================================================

$HtmlFiles = @(
    Get-ChildItem `
        -LiteralPath $DeveloperToolsRoot `
        -Filter "index.html" `
        -File `
        -Recurse `
        -ErrorAction Stop
)

# ============================================================
# INTERNAL LINK AUDIT
# ============================================================

Write-Section "INTERNAL LINK AUDIT"

$LinkResults = @()

$HrefPattern = 'href\s*=\s*["'']([^"'']+)["'']'

foreach ($HtmlFile in $HtmlFiles) {

    $Html = Get-Content `
        -LiteralPath $HtmlFile.FullName `
        -Raw `
        -ErrorAction Stop

    $Matches = [regex]::Matches(
        $Html,
        $HrefPattern,
        [System.Text.RegularExpressions.RegexOptions]::IgnoreCase
    )

    foreach ($Match in $Matches) {

        $Href = $Match.Groups[1].Value.Trim()

        if ([string]::IsNullOrWhiteSpace($Href)) {
            continue
        }

        $IgnoreLink = (
            $Href.StartsWith("#") -or
            $Href.StartsWith(
                "http://",
                [System.StringComparison]::OrdinalIgnoreCase
            ) -or
            $Href.StartsWith(
                "https://",
                [System.StringComparison]::OrdinalIgnoreCase
            ) -or
            $Href.StartsWith(
                "mailto:",
                [System.StringComparison]::OrdinalIgnoreCase
            ) -or
            $Href.StartsWith(
                "tel:",
                [System.StringComparison]::OrdinalIgnoreCase
            ) -or
            $Href.StartsWith(
                "javascript:",
                [System.StringComparison]::OrdinalIgnoreCase
            )
        )

        if ($IgnoreLink) {
            continue
        }

        $CleanHref = ($Href -split '[?#]')[0]

        if ([string]::IsNullOrWhiteSpace($CleanHref)) {
            continue
        }

        if ($CleanHref.StartsWith("/")) {

            $RelativeTarget = (
                $CleanHref.TrimStart("/") -replace '/', '\'
            )

            $Target = Join-Path `
                $RepositoryRoot `
                $RelativeTarget
        }
        else {

            $RelativeTarget = $CleanHref -replace '/', '\'

            $Target = Join-Path `
                $HtmlFile.DirectoryName `
                $RelativeTarget
        }

        if (
            $CleanHref.EndsWith("/") -or
            (Test-Path -LiteralPath $Target -PathType Container)
        ) {
            $Target = Join-Path $Target "index.html"
        }

        try {
            $ResolvedTarget = [System.IO.Path]::GetFullPath($Target)

            $Exists = Test-Path `
                -LiteralPath $ResolvedTarget `
                -PathType Leaf
        }
        catch {
            $ResolvedTarget = $Target
            $Exists = $false
        }

        $LinkResults += [pscustomobject]@{
            Status = if ($Exists) {
                "PASS"
            }
            else {
                "FAIL"
            }

            Page = $HtmlFile.FullName.Substring(
                $DeveloperToolsRoot.Length
            ).TrimStart("\")

            Link = $Href
            Target = $ResolvedTarget
        }
    }
}

$BrokenLinks = @(
    $LinkResults |
    Where-Object {
        $_.Status -eq "FAIL"
    }
)

$PassedLinks = @(
    $LinkResults |
    Where-Object {
        $_.Status -eq "PASS"
    }
)

Write-Host (
    "HTML pages checked : {0}" -f
    $HtmlFiles.Count
)

Write-Host (
    "Links checked      : {0}" -f
    $LinkResults.Count
)

Write-Host (
    "Links passed       : {0}" -f
    $PassedLinks.Count
) -ForegroundColor Green

$LinkFailureColor = if ($BrokenLinks.Count -eq 0) {
    "Green"
}
else {
    "Red"
}

Write-Host (
    "Links failed       : {0}" -f
    $BrokenLinks.Count
) -ForegroundColor $LinkFailureColor

if ($BrokenLinks.Count -gt 0) {

    Write-Host ""
    Write-Host "BROKEN LINKS" -ForegroundColor Red
    Write-Host "------------------------------------------------------------"

    $BrokenLinks |
        Format-Table `
            Status,
            Page,
            Link,
            Target `
            -AutoSize `
            -Wrap
}

if ($BrokenLinks.Count -eq 0) {
    Write-Result "PASS" "Keine kaputten internen Links gefunden."
}

# ============================================================
# DEVELOPER TOOLS ROUTE AUDIT
# ============================================================

Write-Section "DEVELOPER TOOLS ROUTE AUDIT"

$RouteResults = @()

foreach ($Route in $ExpectedRoutes) {

    $RelativeRoute = $Route.TrimStart("/") -replace '/', '\'
    $Target = Join-Path $RepositoryRoot $RelativeRoute

    if ($Route.EndsWith("/")) {
        $Target = Join-Path $Target "index.html"
    }

    $Exists = Test-Path `
        -LiteralPath $Target `
        -PathType Leaf

    $RouteResults += [pscustomobject]@{
        Status = if ($Exists) {
            "PASS"
        }
        else {
            "FAIL"
        }

        Route  = $Route
        Target = $Target
    }
}

foreach ($Result in $RouteResults) {

    $Color = if ($Result.Status -eq "PASS") {
        "Green"
    }
    else {
        "Red"
    }

    Write-Host (
        "[{0}] {1}" -f
        $Result.Status,
        $Result.Route
    ) -ForegroundColor $Color
}

$RouteFailures = @(
    $RouteResults |
    Where-Object {
        $_.Status -eq "FAIL"
    }
)

# ============================================================
# ASSET REFERENCE AUDIT
# ============================================================

Write-Section "HTML ASSET REFERENCE AUDIT"

$AssetReferenceResults = @()

$AssetPattern = '(?:src|href)\s*=\s*["'']([^"'']+\.(?:css|js)(?:[?#][^"'']*)?)["'']'

foreach ($HtmlFile in $HtmlFiles) {

    $Html = Get-Content `
        -LiteralPath $HtmlFile.FullName `
        -Raw `
        -ErrorAction Stop

    $Matches = [regex]::Matches(
        $Html,
        $AssetPattern,
        [System.Text.RegularExpressions.RegexOptions]::IgnoreCase
    )

    foreach ($Match in $Matches) {

        $Reference = $Match.Groups[1].Value.Trim()

        if ([string]::IsNullOrWhiteSpace($Reference)) {
            continue
        }

        $IsExternal = (
            $Reference.StartsWith(
                "http://",
                [System.StringComparison]::OrdinalIgnoreCase
            ) -or
            $Reference.StartsWith(
                "https://",
                [System.StringComparison]::OrdinalIgnoreCase
            ) -or
            $Reference.StartsWith("//")
        )

        if ($IsExternal) {
            continue
        }

        $CleanReference = ($Reference -split '[?#]')[0]

        if ($CleanReference.StartsWith("/")) {

            $RelativeTarget = (
                $CleanReference.TrimStart("/") -replace '/', '\'
            )

            $Target = Join-Path `
                $RepositoryRoot `
                $RelativeTarget
        }
        else {

            $RelativeTarget = $CleanReference -replace '/', '\'

            $Target = Join-Path `
                $HtmlFile.DirectoryName `
                $RelativeTarget
        }

        try {
            $ResolvedTarget = [System.IO.Path]::GetFullPath($Target)

            $Exists = Test-Path `
                -LiteralPath $ResolvedTarget `
                -PathType Leaf
        }
        catch {
            $ResolvedTarget = $Target
            $Exists = $false
        }

        $AssetReferenceResults += [pscustomobject]@{
            Status = if ($Exists) {
                "PASS"
            }
            else {
                "FAIL"
            }

            Page = $HtmlFile.FullName.Substring(
                $DeveloperToolsRoot.Length
            ).TrimStart("\")

            Reference = $Reference
            Target = $ResolvedTarget
        }
    }
}

$BrokenAssetReferences = @(
    $AssetReferenceResults |
    Where-Object {
        $_.Status -eq "FAIL"
    }
)

$PassedAssetReferences = @(
    $AssetReferenceResults |
    Where-Object {
        $_.Status -eq "PASS"
    }
)

Write-Host (
    "Asset references : {0}" -f
    $AssetReferenceResults.Count
)

Write-Host (
    "Asset PASS       : {0}" -f
    $PassedAssetReferences.Count
) -ForegroundColor Green

$AssetFailureColor = if ($BrokenAssetReferences.Count -eq 0) {
    "Green"
}
else {
    "Red"
}

Write-Host (
    "Asset FAIL       : {0}" -f
    $BrokenAssetReferences.Count
) -ForegroundColor $AssetFailureColor

if ($BrokenAssetReferences.Count -gt 0) {

    Write-Host ""
    Write-Host "BROKEN ASSET REFERENCES" -ForegroundColor Red
    Write-Host "------------------------------------------------------------"

    $BrokenAssetReferences |
        Format-Table `
            Status,
            Page,
            Reference,
            Target `
            -AutoSize `
            -Wrap
}

if ($BrokenAssetReferences.Count -eq 0) {
    Write-Result "PASS" "Keine kaputten lokalen Asset-Verweise gefunden."
}

# ============================================================
# FINAL SUMMARY
# ============================================================

$TotalFailures = (
    $PageFailures.Count +
    $AssetFailures.Count +
    $JsonFailures.Count +
    $BrokenLinks.Count +
    $RouteFailures.Count +
    $BrokenAssetReferences.Count
)

Write-Host ""
Write-Host "============================================================" -ForegroundColor Cyan
Write-Host " FINAL DEVELOPER TOOLS AUDIT SUMMARY" -ForegroundColor Cyan
Write-Host "============================================================" -ForegroundColor Cyan

Write-Host ("Expected pages        : {0}" -f $ExpectedPages.Count)
Write-Host ("Page failures         : {0}" -f $PageFailures.Count)

Write-Host ("Expected assets       : {0}" -f $ExpectedAssets.Count)
Write-Host ("Asset failures        : {0}" -f $AssetFailures.Count)

Write-Host ("JSON files            : {0}" -f $JsonFiles.Count)
Write-Host ("JSON failures         : {0}" -f $JsonFailures.Count)

Write-Host ("HTML pages            : {0}" -f $HtmlFiles.Count)

Write-Host ("Internal links        : {0}" -f $LinkResults.Count)
Write-Host ("Broken links          : {0}" -f $BrokenLinks.Count)

Write-Host ("Expected routes       : {0}" -f $ExpectedRoutes.Count)
Write-Host ("Route failures        : {0}" -f $RouteFailures.Count)

Write-Host ("Asset references      : {0}" -f $AssetReferenceResults.Count)
Write-Host ("Broken asset refs     : {0}" -f $BrokenAssetReferences.Count)

Write-Host ("Total failures        : {0}" -f $TotalFailures)

Write-Host ""
Write-Host "============================================================"

if ($TotalFailures -eq 0) {

    Write-Host "[PASS] DEVELOPER TOOLS LOCAL AUDIT COMPLETE" -ForegroundColor Green
    Write-Host "============================================================"

    exit 0
}

Write-Host "[FAIL] DEVELOPER TOOLS LOCAL AUDIT FAILED" -ForegroundColor Red
Write-Host "============================================================"

exit 1





