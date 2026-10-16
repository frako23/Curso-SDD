# Data Model: Página web personal de documentación SDD

El modelo es de contenido estático y de estado efímero de interfaz. No se persiste información del usuario.

## Sección documental

Representa una agrupación temática visible en el índice.

| Campo | Tipo | Reglas |
|---|---|---|
| `id` | texto | Obligatorio, único, estable y apto para ancla HTML. |
| `title` | texto | Obligatorio; español claro. |
| `order` | entero | Obligatorio; determina el orden del índice y la página. |
| `summary` | texto | Obligatorio; explica propósito, problema y relación con SDD. |
| `referenceProject` | texto nullable | Proyecto de ejemplo cuando aplique; no se inventa si no aparece en el repositorio. |
| `documentIds` | lista | Uno o más documentos asociados, en el orden recomendado. |

Secciones iniciales:

1. Introducción y guía general.
2. `spec-first` — diseño desde cero y PresupuestosPro.
3. `reverse-specs` — ingeniería inversa y GesFact.
4. `trabajo en paralelo` — colaboración y CitaClara.
5. `modernización guiada` — modernización incremental de GesFact.
6. `spec-anchored` — OpenSpec, CartaYa y control de drift.
7. GitHub Spec Kit — referencia de comandos, workflows, extensiones, bundles e integraciones.
8. Recursos complementarios — prompt de agente, `spec-audit` y PDF.

## Documento

Representa una fuente documental del repositorio.

| Campo | Tipo | Reglas |
|---|---|---|
| `id` | texto | Obligatorio y único; deriva de la ruta relativa. |
| `path` | texto | Obligatorio; ruta relativa exacta, incluyendo espacios y acentos. |
| `title` | texto | Obligatorio; nombre legible sin perder el nombre de archivo original. |
| `type` | enumeración | `txt`, `md`, `yaml` o `pdf`. |
| `sectionId` | referencia | Debe apuntar a una sección existente. |
| `explanation` | texto | Obligatorio; cuándo usar el archivo y qué aporta. |
| `sourceText` | texto nullable | Obligatorio para documentos textuales; debe conservar el contenido completo. Nulo solo para el PDF. |
| `snippets` | lista | Bloques reutilizables extraídos del texto; puede estar vacía si el documento no contiene prompt/comando identificable. |
| `referenceProject` | texto nullable | Proyecto de ejemplo si el documento lo especifica. |

Raíces fuente del inventario:

- `README.md`
- `github spec kit/`
- `misc/`
- `modernización guiada/`
- `prompts/`
- `reverse-specs/`
- `SKILLs/`
- `spec-anchored/`
- `spec-first/`
- `trabajo en paralelo/`

Validaciones de inventario:

- Deben existir 51 documentos: 45 `.txt`, 4 `.md`, 1 `.yaml` y 1 `.pdf`.
- Solo se incluyen las raíces fuente declaradas arriba; no se incluyen `.git`, `.specify`, `.agents`, `specs/`, `scripts/`, `content/` ni `index.html` en el corpus de la página.
- Cada ruta del manifiesto debe resolverse desde la raíz del repositorio.
- El texto generado debe conservar los saltos de línea y caracteres Unicode del archivo fuente.

## Bloque reutilizable

Representa un prompt o comando que tendrá un botón de copia independiente.

| Campo | Tipo | Reglas |
|---|---|---|
| `id` | texto | Obligatorio y único dentro del documento. |
| `documentId` | referencia | Documento del que procede. |
| `kind` | enumeración | `prompt` o `command`. |
| `label` | texto | Visible; por ejemplo, “Prompt completo” o “Comando”. |
| `text` | texto | Obligatorio; contenido exacto que se copiará. |
| `sourceLocator` | texto nullable | Referencia orientativa a sección o líneas cuando pueda calcularse; no sustituye al texto. |

Reglas:

- Los prompts completos de los archivos de prompt se ofrecen como bloques reutilizables.
- Los bloques de comandos delimitados por el documento o identificados en la referencia de GitHub Spec Kit se ofrecen por separado.
- El contenido de `text` no incluye el título, la explicación ni el botón.
- Un documento puede tener varios bloques y dos documentos pueden tener bloques idénticos sin compartir estado.

## Recurso PDF

Es un documento con `type=pdf`, ruta original y acciones de abrir/descargar. No se fuerza `sourceText` ni se crea una copia convertida.

## Estado efímero de interfaz

| Estado | Valores | Transiciones |
|---|---|---|
| `query` | texto | Vacío muestra todo; texto filtra; limpiar vuelve a vacío. |
| `activeSection` | `id` nullable | Cambia al navegar por el índice o por un enlace interno. |
| `copyStatus` | `idle`, `success`, `failure` | `idle → success` solo tras confirmación; `idle → failure` ante ausencia/error; vuelve a `idle` después del mensaje. |
| `visibleDocumentCount` | entero | Se recalcula después de cada búsqueda; puede ser cero. |

No se guardan `query`, sección activa ni estados de copia después de cerrar la página.
