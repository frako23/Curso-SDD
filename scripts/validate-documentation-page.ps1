[CmdletBinding()]
param(
    [string]$RootPath = (Get-Location).Path,
    [string]$IndexPath
)

$ErrorActionPreference = 'Stop'
$RootPath = (Resolve-Path -LiteralPath $RootPath).Path
if ([string]::IsNullOrWhiteSpace($IndexPath)) {
    $IndexPath = Join-Path $RootPath 'index.html'
} elseif (-not [System.IO.Path]::IsPathRooted($IndexPath)) {
    $IndexPath = Join-Path $RootPath $IndexPath
}

$manifestPath = Join-Path $RootPath 'content\documentation-manifest.json'
$generatorPath = Join-Path $RootPath 'scripts\build-documentation-page.ps1'
if (-not (Test-Path -LiteralPath $manifestPath -PathType Leaf)) { throw "No se encontró el manifiesto: $manifestPath" }
if (-not (Test-Path -LiteralPath $IndexPath -PathType Leaf)) { throw "No se encontró la página generada: $IndexPath" }

$manifest = Get-Content -Raw -Encoding UTF8 -LiteralPath $manifestPath | ConvertFrom-Json
$html = [System.IO.File]::ReadAllText($IndexPath, [System.Text.Encoding]::UTF8)
$rootPrefix = $RootPath.TrimEnd([char[]]@('\', '/'))
$allowedTypes = @('.txt', '.md', '.yaml', '.pdf')

function Get-RelativeRepositoryPath {
    param([string]$FullPath)
    $full = [System.IO.Path]::GetFullPath($FullPath)
    return $full.Substring($rootPrefix.Length).TrimStart([char[]]@('\', '/')) -replace '\\', '/'
}

function Encode-Html {
    param([AllowNull()][string]$Value)
    if ($null -eq $Value) { return '' }
    return [System.Net.WebUtility]::HtmlEncode($Value)
}

function Get-SourceFiles {
    $result = @()
    foreach ($sourceRoot in @($manifest.sourceRoots)) {
        $path = Join-Path $RootPath ([string]$sourceRoot)
        if (-not (Test-Path -LiteralPath $path)) { throw "No existe la raíz fuente: $sourceRoot" }
        $item = Get-Item -LiteralPath $path
        if ($item.PSIsContainer) {
            $result += @(Get-ChildItem -LiteralPath $path -File -Recurse)
        } else {
            $result += $item
        }
    }
    return @($result | Sort-Object FullName)
}

function Assert-Condition {
    param([bool]$Condition, [string]$Message)
    if (-not $Condition) { throw $Message }
}

$sourceFiles = @(Get-SourceFiles)
$actualPaths = @($sourceFiles | ForEach-Object { Get-RelativeRepositoryPath $_.FullName })
$manifestDocuments = @($manifest.documents)
$manifestPaths = @($manifestDocuments | ForEach-Object { [string]$_.path })

Assert-Condition ($sourceFiles.Count -eq 53) "El inventario de fuentes contiene $($sourceFiles.Count) archivos; se esperaban 53."
Assert-Condition (($manifestDocuments.Count -eq 53)) "El manifiesto contiene $($manifestDocuments.Count) documentos; se esperaban 53."
Assert-Condition ((@($actualPaths | Sort-Object) -join '|') -eq (@($manifestPaths | Sort-Object) -join '|')) 'Las rutas reales y las rutas del manifiesto no coinciden.'

$counts = @($sourceFiles | Group-Object Extension | ForEach-Object { "$(($_.Name).ToLowerInvariant())=$($_.Count)" } | Sort-Object)
$expectedCounts = @('.md=5', '.pdf=1', '.txt=46', '.yaml=1') | Sort-Object
Assert-Condition ((@($counts) -join '|') -eq (@($expectedCounts) -join '|')) "Conteos inesperados: $($counts -join ', ')"

foreach ($section in @($manifest.sections)) {
    $sectionMarker = 'id="section-' + [string]$section.id + '"'
    Assert-Condition ($html.Contains($sectionMarker)) "Falta la sección generada: $($section.id)"
}

foreach ($document in $manifestDocuments) {
    $encodedPath = Encode-Html ([string]$document.path)
    Assert-Condition ($html.Contains($encodedPath)) "Falta la ruta en index.html: $($document.path)"
    $sourceFile = $sourceFiles | Where-Object { (Get-RelativeRepositoryPath $_.FullName) -eq [string]$document.path } | Select-Object -First 1
    if ($document.type -ne 'pdf') {
        $source = [System.IO.File]::ReadAllText($sourceFile.FullName, [System.Text.Encoding]::UTF8)
        Assert-Condition ($html.Contains((Encode-Html $source))) "El contenido original no aparece completo: $($document.path)"
    } else {
        Assert-Condition ($html.Contains('href="misc/Claude_Course_Course_-_Prompts_Workflow_2026_.pdf"')) 'Falta el enlace relativo al PDF.'
    }
}

$documentCount = ([regex]::Matches($html, '\sdata-document\s')).Count
Assert-Condition ($documentCount -eq 53) "index.html contiene $documentCount tarjetas documentales; se esperaban 53."

$copyMatches = [regex]::Matches($html, 'data-copy-target="([^"]+)"')
Assert-Condition ($copyMatches.Count -gt 0) 'No se encontraron botones de copia.'
$copyIds = @{}
foreach ($match in $copyMatches) {
    $target = $match.Groups[1].Value
    Assert-Condition (-not $copyIds.ContainsKey($target)) "ID de bloque copiable duplicado: $target"
    $copyIds[$target] = $true
    $targetMarker = 'id="' + $target + '"'
    Assert-Condition ($html.Contains($targetMarker)) "Falta el bloque asociado al botón: $target"
}

Assert-Condition (-not [regex]::IsMatch($html, '<script\s+[^>]*src=', [System.Text.RegularExpressions.RegexOptions]::IgnoreCase)) 'La página incluye un script externo.'
Assert-Condition (-not [regex]::IsMatch($html, '<link\s+[^>]*href=', [System.Text.RegularExpressions.RegexOptions]::IgnoreCase)) 'La página incluye una hoja de estilos externa.'
Assert-Condition (-not [regex]::IsMatch($html, '<img\s+[^>]*src=', [System.Text.RegularExpressions.RegexOptions]::IgnoreCase)) 'La página incluye una imagen externa.'
Assert-Condition ($html.Contains('navigator.clipboard.writeText')) 'Falta la implementación de copia con Clipboard API.'
Assert-Condition ($html.Contains('No se pudo confirmar la copia automática')) 'Falta el fallback manual de copia.'
Assert-Condition ($html.Contains('id="search-input"')) 'Falta el campo de búsqueda.'
Assert-Condition ($html.Contains('id="clear-search"')) 'Falta la acción de limpiar búsqueda.'

$temporaryPath = Join-Path ([System.IO.Path]::GetTempPath()) ("curso-sdd-index-" + [guid]::NewGuid().ToString('N') + '.html')
try {
    & powershell.exe -NoProfile -ExecutionPolicy Bypass -File $generatorPath -RootPath $RootPath -OutputPath $temporaryPath | Out-Null
    $expectedBytes = [System.IO.File]::ReadAllBytes($IndexPath)
    $actualBytes = [System.IO.File]::ReadAllBytes($temporaryPath)
    Assert-Condition (($expectedBytes.Length -eq $actualBytes.Length) -and ([System.Linq.Enumerable]::SequenceEqual($expectedBytes, $actualBytes))) 'La generación no es determinista: index.html cambia al regenerarse.'
} finally {
    if (Test-Path -LiteralPath $temporaryPath) {
        Remove-Item -LiteralPath $temporaryPath -Force
    }
}

Write-Output 'VALIDATION_OK'
Write-Output "Fuentes: $($sourceFiles.Count)"
Write-Output "Tarjetas documentales: $documentCount"
Write-Output "Bloques copiables: $($copyMatches.Count)"
Write-Output 'Conteos: md=5, pdf=1, txt=46, yaml=1'
