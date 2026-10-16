[CmdletBinding()]
param(
    [string]$RootPath = (Get-Location).Path,
    [string]$OutputPath
)

$ErrorActionPreference = 'Stop'

$RootPath = (Resolve-Path -LiteralPath $RootPath).Path
if ([string]::IsNullOrWhiteSpace($OutputPath)) {
    $OutputPath = Join-Path $RootPath 'index.html'
} elseif (-not [System.IO.Path]::IsPathRooted($OutputPath)) {
    $OutputPath = Join-Path $RootPath $OutputPath
}

$manifestPath = Join-Path $RootPath 'content\documentation-manifest.json'
if (-not (Test-Path -LiteralPath $manifestPath -PathType Leaf)) {
    throw "No se encontró el manifiesto: $manifestPath"
}

$manifest = Get-Content -Raw -Encoding UTF8 -LiteralPath $manifestPath | ConvertFrom-Json
$allowedTypes = @('.txt', '.md', '.yaml', '.pdf')
$rootPrefix = $RootPath.TrimEnd([char[]]@('\', '/'))

function Get-RelativeRepositoryPath {
    param([string]$FullPath)

    $full = [System.IO.Path]::GetFullPath($FullPath)
    if (-not $full.StartsWith($rootPrefix, [System.StringComparison]::OrdinalIgnoreCase)) {
        throw "La ruta no pertenece al repositorio: $FullPath"
    }

    return $full.Substring($rootPrefix.Length).TrimStart([char[]]@('\', '/')) -replace '\\', '/'
}

function Read-Utf8File {
    param([string]$Path)

    return [System.IO.File]::ReadAllText($Path, [System.Text.Encoding]::UTF8)
}

function Encode-Html {
    param([AllowNull()][string]$Value)

    if ($null -eq $Value) {
        return ''
    }

    return [System.Net.WebUtility]::HtmlEncode($Value)
}

function New-Slug {
    param([string]$Value)

    $normalized = $Value.Normalize([System.Text.NormalizationForm]::FormD)
    $characters = New-Object System.Collections.Generic.List[char]
    foreach ($character in $normalized.ToCharArray()) {
        if ([System.Globalization.CharUnicodeInfo]::GetUnicodeCategory($character) -ne [System.Globalization.UnicodeCategory]::NonSpacingMark) {
            [void]$characters.Add($character)
        }
    }

    $slug = (-join $characters).ToLowerInvariant() -replace '[^a-z0-9]+', '-'
    $slug = $slug.Trim('-')
    if ([string]::IsNullOrWhiteSpace($slug)) {
        return 'documento'
    }

    return $slug
}

function Test-CommandText {
    param([string]$Text)

    $candidate = $Text.Trim().Trim([char[]]@('`'))
    $prefixes = @(
        '/speckit',
        '/opsx:',
        '$speckit-',
        'specify ',
        'git ',
        'uv ',
        'py ',
        'python ',
        'powershell ',
        'npm ',
        'node '
    )

    foreach ($prefix in $prefixes) {
        if ($candidate.StartsWith($prefix, [System.StringComparison]::OrdinalIgnoreCase)) {
            return $true
        }
    }

    return $false
}

function Add-Snippet {
    param(
        [System.Collections.ArrayList]$List,
        [hashtable]$Seen,
        [string]$Kind,
        [string]$Label,
        [string]$Text,
        [string]$Locator
    )

    if ([string]::IsNullOrWhiteSpace($Text)) {
        return
    }

    $key = "$Kind|$Text"
    if ($Seen.ContainsKey($key)) {
        return
    }

    $Seen[$key] = $true
    [void]$List.Add([pscustomobject]@{
            kind = $Kind
            label = $Label
            text = $Text
            locator = $Locator
        })
}

function Get-Snippets {
    param(
        [string]$Source,
        [string]$CopyMode,
        [string]$DocumentPath
    )

    $list = New-Object System.Collections.ArrayList
    $seen = @{}
    $lines = $Source -split "`r?`n", -1

    if ($CopyMode -eq 'whole') {
        Add-Snippet $list $seen 'prompt' 'Prompt completo' $Source 'archivo completo'
    }

    $inFence = $false
    $fenceLines = New-Object System.Collections.ArrayList
    $fenceStart = 0
    for ($index = 0; $index -lt $lines.Count; $index++) {
        $line = [string]$lines[$index]
        $trimmed = $line.TrimStart()
        if ($trimmed.StartsWith('```')) {
            if (-not $inFence) {
                $inFence = $true
                $fenceStart = $index + 1
                $fenceLines = New-Object System.Collections.ArrayList
            } else {
                Add-Snippet $list $seen 'command' 'Bloque de código' (($fenceLines -join "`n")) ("líneas $fenceStart-" + $index)
                $inFence = $false
            }
            continue
        }

        if ($inFence) {
            [void]$fenceLines.Add($line)
        }
    }

    if ($CopyMode -eq 'code') {
        for ($index = 0; $index -lt $lines.Count; $index++) {
            $line = [string]$lines[$index]
            if (-not ($line.StartsWith('    ') -or $line.StartsWith("`t"))) {
                continue
            }

            $block = New-Object System.Collections.ArrayList
            $start = $index + 1
            while ($index -lt $lines.Count) {
                $current = [string]$lines[$index]
                if ([string]::IsNullOrWhiteSpace($current)) {
                    [void]$block.Add('')
                    $index++
                    continue
                }
                if ($current.StartsWith('    ')) {
                    [void]$block.Add($current.Substring(4))
                    $index++
                    continue
                }
                if ($current.StartsWith("`t")) {
                    [void]$block.Add($current.Substring(1))
                    $index++
                    continue
                }
                break
            }

            while ($block.Count -gt 0 -and [string]::IsNullOrWhiteSpace([string]$block[$block.Count - 1])) {
                $block.RemoveAt($block.Count - 1)
            }
            Add-Snippet $list $seen 'command' 'Bloque de comandos' (($block -join "`n")) ("líneas $start-" + $index)
            $index--
        }
    }

    $inlineMatches = [System.Text.RegularExpressions.Regex]::Matches($Source, '`([^`\r\n]+)`')
    foreach ($match in $inlineMatches) {
        $candidate = $match.Groups[1].Value.Trim()
        if (Test-CommandText $candidate) {
            Add-Snippet $list $seen 'command' 'Comando' $candidate 'comando inline'
        }
    }

    foreach ($line in $lines) {
        $candidate = $line.Trim()
        if (Test-CommandText $candidate) {
            Add-Snippet $list $seen 'command' 'Comando' $candidate 'línea de comando'
        }
    }

    return @($list)
}

function Get-SourceFiles {
    param([pscustomobject]$Manifest)

    $result = @()
    foreach ($sourceRoot in @($Manifest.sourceRoots)) {
        $path = Join-Path $RootPath ([string]$sourceRoot)
        if (-not (Test-Path -LiteralPath $path)) {
            throw "No existe la raíz fuente declarada: $sourceRoot"
        }

        $item = Get-Item -LiteralPath $path
        if ($item.PSIsContainer) {
            $result += @(Get-ChildItem -LiteralPath $path -File -Recurse)
        } else {
            $result += $item
        }
    }

    $invalid = @($result | Where-Object { $allowedTypes -notcontains $_.Extension.ToLowerInvariant() })
    if ($invalid.Count -gt 0) {
        throw "Hay archivos fuera del corpus documental: $($invalid.FullName -join ', ')"
    }

    return @($result | Sort-Object FullName)
}

$sourceFiles = @(Get-SourceFiles $manifest)
$metadata = @{}
foreach ($document in @($manifest.documents)) {
    $metadata[[string]$document.path] = $document
}

$documents = @()
$seenPaths = @{}
foreach ($file in $sourceFiles) {
    $relativePath = Get-RelativeRepositoryPath $file.FullName
    if (-not $metadata.ContainsKey($relativePath)) {
        throw "Falta metadata para el documento: $relativePath"
    }

    $entry = $metadata[$relativePath]
    $seenPaths[$relativePath] = $true
    $source = ''
    if ($entry.type -ne 'pdf') {
        $source = Read-Utf8File $file.FullName
    }

    $documents += [pscustomobject]@{
        path = $relativePath
        title = [string]$entry.title
        type = [string]$entry.type
        sectionId = [string]$entry.sectionId
        explanation = [string]$entry.explanation
        referenceProject = if ($null -eq $entry.referenceProject) { '' } else { [string]$entry.referenceProject }
        source = $source
        copyMode = if ($null -eq $entry.copyMode) { 'none' } else { [string]$entry.copyMode }
        snippets = if ($entry.type -eq 'pdf') { @() } else { @(Get-Snippets $source ([string]$entry.copyMode) $relativePath) }
    }
}

foreach ($entry in @($manifest.documents)) {
    if (-not $seenPaths.ContainsKey([string]$entry.path)) {
        throw "El manifiesto declara una ruta que no existe en las raíces fuente: $($entry.path)"
    }
}

if ($documents.Count -ne 51) {
    throw "El corpus debe contener 51 documentos y contiene $($documents.Count)."
}

$extensionCounts = @($documents | Group-Object type | ForEach-Object { "$(($_.Name).ToLowerInvariant())=$($_.Count)" })
$expectedCounts = @('md=4', 'pdf=1', 'txt=45', 'yaml=1')
if ((@($extensionCounts | Sort-Object) -join '|') -ne (@($expectedCounts | Sort-Object) -join '|')) {
    throw "Conteos de extensión inesperados: $($extensionCounts -join ', ')"
}

$sections = @($manifest.sections | Sort-Object order)
$sectionMap = @{}
foreach ($section in $sections) {
    $sectionMap[[string]$section.id] = $section
}

foreach ($document in $documents) {
    if (-not $sectionMap.ContainsKey($document.sectionId)) {
        throw "El documento $($document.path) apunta a una sección inexistente: $($document.sectionId)"
    }
}

$style = @'
:root {
  color-scheme: light;
  --ink: #17202a;
  --muted: #5d6b78;
  --surface: #ffffff;
  --surface-soft: #f3f6f8;
  --line: #dce3e8;
  --accent: #0f766e;
  --accent-dark: #115e59;
  --accent-soft: #d9f2ee;
  --code: #17212b;
  --code-ink: #eef6f7;
  --shadow: 0 18px 45px rgba(23, 32, 42, .08);
  font-family: Inter, ui-sans-serif, system-ui, -apple-system, BlinkMacSystemFont, "Segoe UI", sans-serif;
}

* { box-sizing: border-box; }
html { scroll-behavior: smooth; }
body { margin: 0; color: var(--ink); background: #edf2f4; line-height: 1.6; }
a { color: var(--accent-dark); }
a:focus-visible, button:focus-visible, input:focus-visible, summary:focus-visible, pre:focus-visible {
  outline: 3px solid #f59e0b;
  outline-offset: 3px;
}
.skip-link { position: fixed; left: 1rem; top: -5rem; z-index: 20; padding: .7rem 1rem; color: white; background: var(--ink); border-radius: .6rem; }
.skip-link:focus { top: 1rem; }
.hero { color: white; background: linear-gradient(135deg, #123b45 0%, #0f766e 58%, #0d9488 100%); }
.hero-inner, .page-main, .footer-inner { width: min(1180px, calc(100% - 2rem)); margin: 0 auto; }
.hero-inner { padding: 4.5rem 0 2.5rem; }
.eyebrow { margin: 0 0 .6rem; font-size: .78rem; font-weight: 800; letter-spacing: .14em; text-transform: uppercase; opacity: .8; }
h1, h2, h3, h4 { line-height: 1.2; }
h1 { max-width: 850px; margin: 0; font-size: clamp(2.2rem, 6vw, 4.7rem); letter-spacing: -.045em; }
.lede { max-width: 780px; margin: 1.2rem 0 0; font-size: clamp(1.05rem, 2vw, 1.3rem); color: #dcf8f4; }
.hero-meta { display: flex; flex-wrap: wrap; gap: .6rem; margin-top: 1.5rem; }
.hero-meta span { padding: .35rem .7rem; color: #d9f2ee; border: 1px solid rgba(255,255,255,.28); border-radius: 999px; font-size: .9rem; }
.search-panel { margin-top: 2rem; padding: 1rem; color: var(--ink); background: rgba(255,255,255,.96); border-radius: 1rem; box-shadow: var(--shadow); }
.search-row { display: flex; gap: .7rem; align-items: end; }
.field { flex: 1; }
.field label { display: block; margin-bottom: .35rem; font-weight: 800; }
.field input { width: 100%; padding: .85rem 1rem; color: var(--ink); background: white; border: 2px solid var(--line); border-radius: .65rem; font: inherit; }
button, .button { display: inline-flex; align-items: center; justify-content: center; min-height: 2.75rem; padding: .65rem .9rem; color: white; background: var(--accent-dark); border: 0; border-radius: .6rem; font: inherit; font-weight: 750; cursor: pointer; text-decoration: none; }
button:hover, .button:hover { background: #0b4f4b; }
.secondary-button { color: var(--ink); background: var(--surface-soft); border: 1px solid var(--line); }
.secondary-button:hover { background: #e5ecef; }
.search-status { min-height: 1.5rem; margin: .6rem 0 0; color: var(--muted); font-size: .92rem; }
.page-main { padding: 2rem 0 4rem; }
.index-card, .section-card, .document-card { background: var(--surface); border: 1px solid var(--line); border-radius: 1rem; box-shadow: 0 8px 25px rgba(23,32,42,.04); }
.index-card { padding: 1.4rem; }
.index-card h2 { margin-top: 0; }
.index-grid { display: grid; grid-template-columns: repeat(auto-fit, minmax(230px, 1fr)); gap: .8rem; padding: 0; margin: 1rem 0 0; list-style: none; }
.index-grid a { display: block; height: 100%; padding: 1rem; color: var(--ink); background: var(--surface-soft); border: 1px solid transparent; border-radius: .8rem; text-decoration: none; }
.index-grid a:hover { border-color: var(--accent); background: var(--accent-soft); }
.index-grid strong { display: block; color: var(--accent-dark); }
.index-grid small { display: block; margin-top: .3rem; color: var(--muted); }
.section-card { margin-top: 2rem; padding: 1.25rem; scroll-margin-top: 1rem; }
.section-heading { display: flex; justify-content: space-between; gap: 1rem; align-items: start; }
.section-heading h2 { margin: 0; }
.section-summary { max-width: 850px; margin: .8rem 0 0; color: var(--muted); }
.section-ref { margin: .4rem 0 0; color: var(--muted); font-size: .9rem; }
.back-link { white-space: nowrap; font-size: .9rem; }
.documents { display: grid; gap: 1rem; margin-top: 1.3rem; }
.document-card { padding: 1.15rem; scroll-margin-top: 1rem; }
.document-card[hidden], .section-card[hidden] { display: none; }
.document-card h3 { margin: 0; font-size: 1.25rem; }
.document-meta { display: flex; flex-wrap: wrap; gap: .45rem; margin: .65rem 0; }
.document-meta span, .document-meta code { padding: .2rem .5rem; color: var(--muted); background: var(--surface-soft); border-radius: .35rem; font-size: .78rem; }
.document-meta code { overflow-wrap: anywhere; }
.explanation { margin: .7rem 0 1rem; color: var(--muted); }
.snippet-list { display: grid; gap: .7rem; margin: 1rem 0; }
.snippet-card { overflow: hidden; border: 1px solid #2c4149; border-radius: .75rem; background: var(--code); }
.snippet-head { display: flex; align-items: center; justify-content: space-between; gap: .7rem; padding: .55rem .7rem; color: #c8e9e5; background: #20333b; font-size: .85rem; }
.snippet-head button { min-height: 2.1rem; padding: .35rem .65rem; color: #10262a; background: #a7e4da; font-size: .82rem; }
.snippet-head button:hover { background: #d2f5ef; }
.snippet-head button.is-success { color: #073b35; background: #b6f0c3; }
.snippet-head button.is-failure { color: #5b1a1a; background: #fecaca; }
pre { margin: 0; overflow-x: auto; white-space: pre-wrap; overflow-wrap: anywhere; }
.snippet-card pre { padding: 1rem; color: var(--code-ink); }
code, pre { font-family: "Cascadia Code", "SFMono-Regular", Consolas, "Liberation Mono", monospace; }
.source-details { margin-top: 1rem; border-top: 1px solid var(--line); }
.source-details summary { padding: .8rem 0; color: var(--accent-dark); font-weight: 800; cursor: pointer; }
.source-content { padding: 1rem; color: #24323b; background: #f8fafb; border: 1px solid var(--line); border-radius: .65rem; font-size: .84rem; }
.pdf-resource { display: flex; flex-wrap: wrap; gap: .7rem; align-items: center; padding: 1rem; background: var(--accent-soft); border-radius: .75rem; }
.pdf-resource p { flex: 1 1 100%; margin: 0; }
.empty-state { padding: 1rem; color: var(--muted); background: var(--surface-soft); border-radius: .7rem; }
.footer { color: #dce7ea; background: #172a31; }
.footer-inner { padding: 2rem 0; font-size: .9rem; }
.footer-inner p { margin: .2rem 0; }
@media (max-width: 620px) {
  .hero-inner { padding-top: 3rem; }
  .search-row { display: grid; grid-template-columns: 1fr; align-items: stretch; }
  .search-row button { width: 100%; }
  .section-heading { display: block; }
  .back-link { display: inline-block; margin-top: .8rem; }
  .snippet-head { align-items: start; flex-direction: column; }
  .snippet-head button { width: 100%; }
}
@media (prefers-reduced-motion: reduce) {
  html { scroll-behavior: auto; }
}
'@

$script = @'
(() => {
  'use strict';

  const input = document.querySelector('#search-input');
  const clearButton = document.querySelector('#clear-search');
  const searchStatus = document.querySelector('#search-status');
  const cards = Array.from(document.querySelectorAll('[data-document]'));
  const sections = Array.from(document.querySelectorAll('[data-section-shell]'));
  const copyButtons = Array.from(document.querySelectorAll('[data-copy-target]'));

  const normalize = (value) => String(value || '')
    .normalize('NFD')
    .replace(/[\u0300-\u036f]/g, '')
    .toLowerCase()
    .replace(/\s+/g, ' ')
    .trim();

  const updateSearch = () => {
    const query = normalize(input.value);
    let visible = 0;

    cards.forEach((card) => {
      const matches = !query || normalize(card.dataset.search).includes(query);
      card.hidden = !matches;
      if (matches) visible += 1;
    });

    sections.forEach((section) => {
      const hasVisibleDocument = section.querySelector('[data-document]:not([hidden])');
      section.hidden = !hasVisibleDocument;
    });

    clearButton.hidden = !input.value;
    if (!query) {
      searchStatus.textContent = `Mostrando ${cards.length} documentos.`;
    } else if (!visible) {
      searchStatus.textContent = `No hay resultados para “${input.value.trim()}”.`;
    } else {
      searchStatus.textContent = `${visible} documento${visible === 1 ? '' : 's'} encontrado${visible === 1 ? '' : 's'}.`;
    }
  };

  input.addEventListener('input', updateSearch);
  clearButton.addEventListener('click', () => {
    input.value = '';
    input.focus();
    updateSearch();
  });

  const resetCopyButton = (button) => {
    window.setTimeout(() => {
      button.textContent = button.dataset.defaultLabel;
      button.classList.remove('is-success', 'is-failure');
    }, 2200);
  };

  copyButtons.forEach((button) => {
    button.dataset.defaultLabel = button.textContent;
    button.addEventListener('click', async () => {
      const source = document.getElementById(button.dataset.copyTarget);
      if (!source) return;
      const text = source.textContent;
      try {
        if (!navigator.clipboard || typeof navigator.clipboard.writeText !== 'function') {
          throw new Error('Clipboard API no disponible');
        }
        await navigator.clipboard.writeText(text);
        button.textContent = 'Copiado';
        button.classList.add('is-success');
        searchStatus.textContent = 'Contenido copiado correctamente.';
      } catch (error) {
        button.textContent = 'Copia manual';
        button.classList.add('is-failure');
        source.focus();
        searchStatus.textContent = 'No se pudo confirmar la copia automática. Selecciona el texto del bloque para copiarlo manualmente.';
      }
      resetCopyButton(button);
    });
  });

  document.querySelectorAll('[data-section-link]').forEach((link) => {
    link.addEventListener('click', () => {
      document.querySelectorAll('[data-section-link]').forEach((item) => item.removeAttribute('aria-current'));
      link.setAttribute('aria-current', 'true');
    });
  });

  updateSearch();
})();
'@

$builder = New-Object System.Text.StringBuilder
[void]$builder.AppendLine('<!doctype html>')
[void]$builder.AppendLine('<html lang="es">')
[void]$builder.AppendLine('<head>')
[void]$builder.AppendLine('  <meta charset="utf-8">')
[void]$builder.AppendLine('  <meta name="viewport" content="width=device-width, initial-scale=1">')
[void]$builder.AppendLine(('  <meta name="description" content="' + (Encode-Html $manifest.inventoryNote) + '">'))
[void]$builder.AppendLine("  <title>$(Encode-Html $manifest.featureTitle)</title>")
[void]$builder.AppendLine('  <style>')
[void]$builder.AppendLine($style)
[void]$builder.AppendLine('  </style>')
[void]$builder.AppendLine('</head>')
[void]$builder.AppendLine('<body>')
[void]$builder.AppendLine('  <a class="skip-link" href="#main">Saltar al contenido</a>')
[void]$builder.AppendLine('  <header class="hero" id="top">')
[void]$builder.AppendLine('    <div class="hero-inner">')
[void]$builder.AppendLine('      <p class="eyebrow">Guía personal &middot; Spec-Driven Development</p>')
[void]$builder.AppendLine("      <h1>$(Encode-Html $manifest.featureTitle)</h1>")
[void]$builder.AppendLine('      <p class="lede">Una lectura guiada del repositorio: aprende qué contiene cada recorrido, conserva el texto original y copia cualquier prompt o comando con un toque.</p>')
[void]$builder.AppendLine('      <div class="hero-meta">')
[void]$builder.AppendLine("        <span>$(($documents.Count)) documentos</span>")
[void]$builder.AppendLine("        <span>$(($sections.Count)) secciones</span>")
[void]$builder.AppendLine("        <span>Inventario: $(Encode-Html $manifest.created)</span>")
[void]$builder.AppendLine('      </div>')
[void]$builder.AppendLine('      <div class="search-panel">')
[void]$builder.AppendLine('        <div class="search-row">')
[void]$builder.AppendLine('          <div class="field">')
[void]$builder.AppendLine('            <label for="search-input">Buscar en títulos, rutas, explicaciones, prompts y comandos</label>')
[void]$builder.AppendLine('            <input id="search-input" type="search" autocomplete="off" placeholder="Ej.: GesFact, speckit, worktree...">')
[void]$builder.AppendLine('          </div>')
[void]$builder.AppendLine('          <button id="clear-search" class="secondary-button" type="button" hidden>Limpiar búsqueda</button>')
[void]$builder.AppendLine('        </div>')
[void]$builder.AppendLine('        <p id="search-status" class="search-status" aria-live="polite"></p>')
[void]$builder.AppendLine('      </div>')
[void]$builder.AppendLine('    </div>')
[void]$builder.AppendLine('  </header>')
[void]$builder.AppendLine('  <main class="page-main" id="main">')
[void]$builder.AppendLine('    <section class="index-card" id="indice" aria-labelledby="indice-title">')
[void]$builder.AppendLine('      <h2 id="indice-title">Índice del recorrido</h2>')
[void]$builder.AppendLine("      <p>$(Encode-Html $manifest.inventoryNote) La página distingue la documentación del curso de la infraestructura que la genera.</p>")
[void]$builder.AppendLine('      <ol class="index-grid">')
foreach ($section in $sections) {
    $sectionDocs = @($documents | Where-Object { $_.sectionId -eq [string]$section.id })
    $plural = if ($sectionDocs.Count -eq 1) { '' } else { 's' }
    $indexLine = '        <li><a data-section-link href="#section-' + $section.id + '"><strong>' + (Encode-Html $section.title) + '</strong><small>' + $sectionDocs.Count + ' documento' + $plural + '</small></a></li>'
    [void]$builder.AppendLine($indexLine)
}
[void]$builder.AppendLine('      </ol>')
[void]$builder.AppendLine('    </section>')

foreach ($section in $sections) {
    $sectionId = [string]$section.id
    $sectionDocs = @($documents | Where-Object { $_.sectionId -eq $sectionId })
    [void]$builder.AppendLine(('    <section class="section-card" id="section-' + $sectionId + '" data-section-shell aria-labelledby="section-title-' + $sectionId + '">'))
    [void]$builder.AppendLine('      <div class="section-heading">')
    $referenceHtml = ''
    if ($section.referenceProject) {
        $referenceHtml = '<p class="section-ref"><strong>Proyecto de referencia:</strong> ' + (Encode-Html $section.referenceProject) + '</p>'
    }
    $sectionHeading = '        <div><h2 id="section-' + $sectionId + '">' + (Encode-Html $section.title) + '</h2><p class="section-summary">' + (Encode-Html $section.summary) + '</p>' + $referenceHtml + '</div>'
    [void]$builder.AppendLine($sectionHeading)
    [void]$builder.AppendLine('        <a class="back-link" href="#indice">Volver al índice &uarr;</a>')
    [void]$builder.AppendLine('      </div>')
    [void]$builder.AppendLine('      <div class="documents">')

    foreach ($document in $sectionDocs) {
        $documentSlug = New-Slug $document.path
        $documentId = "doc-$documentSlug"
        $snippetList = @($document.snippets)
        $searchParts = @($document.title, $document.path, $document.explanation, $document.referenceProject, $section.title, $document.source)
        foreach ($snippet in $snippetList) { $searchParts += $snippet.text }
        $searchText = Encode-Html ($searchParts -join ' ')
        [void]$builder.AppendLine(('        <article class="document-card" id="' + $documentId + '" data-document data-search="' + $searchText + '">'))
        [void]$builder.AppendLine("          <h3>$(Encode-Html $document.title)</h3>")
        [void]$builder.AppendLine('          <div class="document-meta">')
        $documentReference = ''
        if ($document.referenceProject) {
            $documentReference = '<span>' + (Encode-Html $document.referenceProject) + '</span>'
        }
        $metadataLine = '            <code>' + (Encode-Html $document.path) + '</code><span>' + (Encode-Html $document.type.ToUpperInvariant()) + '</span><span>' + (Encode-Html $section.title) + '</span>' + $documentReference
        [void]$builder.AppendLine($metadataLine)
        [void]$builder.AppendLine('          </div>')
        [void]$builder.AppendLine(('          <p class="explanation">' + (Encode-Html $document.explanation) + '</p>'))

        if ($document.type -eq 'pdf') {
            $pdfPath = Encode-Html $document.path
            [void]$builder.AppendLine('          <div class="pdf-resource">')
            $pdfLine = '            <p>Este archivo se conserva como PDF original. Puedes abrirlo en otra pestaña o descargarlo para consultarlo fuera de esta guía.</p><a class="button" href="' + $pdfPath + '" target="_blank" rel="noopener">Abrir PDF</a><a class="button secondary-button" href="' + $pdfPath + '" download>Descargar PDF</a>'
            [void]$builder.AppendLine($pdfLine)
            [void]$builder.AppendLine('          </div>')
        } else {
            if ($snippetList.Count -gt 0) {
                [void]$builder.AppendLine('          <div class="snippet-list" aria-label="Prompts y comandos reutilizables">')
                $snippetIndex = 0
                foreach ($snippet in $snippetList) {
                    $snippetId = "$documentId-snippet-$snippetIndex"
                    $label = Encode-Html $snippet.label
                    $kind = Encode-Html $snippet.kind
                    $snippetText = Encode-Html $snippet.text
                    [void]$builder.AppendLine(('            <div class="snippet-card" data-snippet data-kind="' + $kind + '">'))
                    $snippetTypeLabel = if ($snippet.kind -eq 'prompt') { 'Prompt' } else { 'Comando' }
                    $snippetHead = '              <div class="snippet-head"><span>' + $snippetTypeLabel + ' · ' + $label + '</span><button type="button" data-copy-target="' + $snippetId + '" aria-label="Copiar ' + $label + ' de ' + (Encode-Html $document.title) + '">Copiar</button></div>'
                    [void]$builder.AppendLine($snippetHead)
                    [void]$builder.AppendLine(('              <pre id="' + $snippetId + '" tabindex="0"><code>' + $snippetText + '</code></pre>'))
                    [void]$builder.AppendLine('            </div>')
                    $snippetIndex++
                }
                [void]$builder.AppendLine('          </div>')
            }
            [void]$builder.AppendLine('          <details class="source-details">')
            [void]$builder.AppendLine('            <summary>Ver contenido original completo</summary>')
            [void]$builder.AppendLine(('            <pre class="source-content" tabindex="0"><code>' + (Encode-Html $document.source) + '</code></pre>'))
            [void]$builder.AppendLine('          </details>')
        }
        [void]$builder.AppendLine('        </article>')
    }

    [void]$builder.AppendLine('      </div>')
    [void]$builder.AppendLine('    </section>')
}

[void]$builder.AppendLine('  </main>')
[void]$builder.AppendLine('  <footer class="footer"><div class="footer-inner"><p>Guía personal generada desde el repositorio Curso SDD.</p><p>La página es de consulta: el contenido fuente vive en sus archivos originales.</p></div></footer>')
[void]$builder.AppendLine('  <script>')
[void]$builder.AppendLine($script)
[void]$builder.AppendLine('  </script>')
[void]$builder.AppendLine('</body>')
[void]$builder.AppendLine('</html>')

$outputDirectory = Split-Path -Parent $OutputPath
if (-not (Test-Path -LiteralPath $outputDirectory)) {
    New-Item -ItemType Directory -Force -Path $outputDirectory | Out-Null
}

$utf8NoBom = New-Object System.Text.UTF8Encoding($false)
[System.IO.File]::WriteAllText($OutputPath, $builder.ToString(), $utf8NoBom)

Write-Output "Generado: $OutputPath"
Write-Output "Documentos: $($documents.Count)"
Write-Output "Secciones: $($sections.Count)"
$snippetCount = ($documents | ForEach-Object { @($_.snippets).Count } | Measure-Object -Sum).Sum
Write-Output "Bloques copiables: $snippetCount"
