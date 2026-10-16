# Implementation Plan: Página web personal de documentación SDD

**Branch**: `master` | **Date**: 2026-10-16 | **Spec**: [spec.md](./spec.md)

**Input**: Feature specification from `specs/001-documentacion-web-personal/spec.md`

## Summary

Se construirá una página web estática, autocontenida y de consulta personal que reúna el corpus documental actual del repositorio en secciones temáticas. La página conservará el texto fuente de los documentos, añadirá explicaciones editoriales y metadatos de contexto, y ofrecerá búsqueda, navegación interna y botones independientes para copiar prompts y comandos.

La solución usará estándares web sin dependencias externas ni backend. Un generador local leerá el inventario documental y producirá `index.html`, de modo que la página pueda abrirse directamente y el PDF existente permanezca disponible como recurso original. Una validación local comprobará que no falte ningún archivo del inventario y que los bloques copiados conserven exactamente su contenido.

## Technical Context

**Language/Version**: HTML Living Standard, CSS moderno y JavaScript ES2022 ejecutado en el navegador; PowerShell 5+ para generación y validación local.

**Primary Dependencies**: Ninguna dependencia de terceros. Se usarán APIs estándar del navegador, incluida la Clipboard API cuando esté disponible.

**Storage**: N/A. El contenido queda embebido en la página generada; no hay base de datos, sesión ni preferencias persistentes.

**Testing**: Validación estática con PowerShell y pruebas manuales en navegador sobre contenido, navegación, búsqueda, copia, PDF, teclado y tamaños de pantalla.

**Target Platform**: Navegadores modernos de escritorio y móvil. La lectura funcionará al abrir el archivo localmente; la copia automática se validará también desde un origen local seguro como `localhost`.

**Project Type**: Página web estática de documentación personal.

**Performance Goals**: Mostrar el encabezado y el índice inmediatamente en uso local; actualizar la búsqueda sin una pausa perceptible para el corpus de 51 archivos; completar la copia después de que el navegador confirme la escritura.

**Constraints**: Sin servidor de aplicación, autenticación, red externa, fuentes remotas, persistencia, edición ni dependencias instalables. Deben conservarse acentos, saltos de línea, espacios, caracteres especiales, rutas con espacios y el contenido original del repositorio.

**Scale/Scope**: Una persona, una página, 51 archivos documentales actuales —45 `.txt`, 4 `.md`, 1 `.yaml` y 1 `.pdf`—, cinco familias temáticas principales, un recurso PDF y un número abierto de bloques reutilizables extraídos del contenido.

## Constitution Check

La constitución del repositorio sigue siendo la plantilla inicial de Spec Kit y no contiene principios ratificados ni gates de producto aplicables. No se detectan violaciones. Se respetan, como decisiones de esta feature, la simplicidad, el alcance explícito, la conservación de la evidencia documental y la ausencia de secretos o datos externos.

**Initial gate**: PASS — no hay principios activos adicionales que bloquearían la fase de investigación.

**Post-design gate**: PASS — el diseño mantiene una sola página estática, no añade integraciones externas y conserva el corpus fuente sin reinterpretarlo.

## Project Structure

### Documentation (this feature)

```text
specs/001-documentacion-web-personal/
├── plan.md              # Este plan técnico
├── research.md          # Decisiones de investigación de Phase 0
├── data-model.md        # Modelo de contenido y estado de interfaz
├── quickstart.md        # Guía de generación y validación
├── contracts/
│   └── ui-contract.md   # Contrato observable de la página
└── tasks.md             # Se generará en la fase $speckit-tasks
```

### Source Code (repository root)

```text
index.html                              # Página estática generada y autocontenida
content/
└── documentation-manifest.json         # Secciones, explicaciones y metadatos del corpus
scripts/
├── build-documentation-page.ps1        # Genera index.html desde el corpus actual
└── validate-documentation-page.ps1     # Comprueba inventario y requisitos estáticos
misc/
└── Claude_Course_Course_-_Prompts_Workflow_2026_.pdf
                                         # Recurso PDF original enlazado desde la página
README.md, spec-first/, reverse-specs/,
trabajo en paralelo/, modernización guiada/,
spec-anchored/, prompts/, SKILLs/       # Fuentes documentales existentes
```

**Structure Decision**: Se selecciona una única página generada en la raíz porque el usuario pidió una página HTML de consulta personal y el corpus debe funcionar sin backend ni instalación. Los scripts de generación y validación separan el mantenimiento del contenido de la presentación final. El PDF no se copia ni se transforma: conserva su ubicación original y se enlaza con una ruta relativa.

## Complexity Tracking

No hay violaciones de la constitución ni complejidad excepcional que justificar.
