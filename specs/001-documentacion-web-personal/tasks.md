# Tasks: Página web personal de documentación SDD

**Input**: Design documents from `specs/001-documentacion-web-personal/`

**Prerequisites**: `plan.md`, `spec.md`, `research.md`, `data-model.md`, `contracts/ui-contract.md`, `quickstart.md`

**Tests**: No se crean tareas de tests automatizados porque la especificación no solicita TDD ni un framework de pruebas. Las validaciones estáticas y manuales del `quickstart.md` sí forman parte de las tareas.

**Organization**: Las tareas están agrupadas por historia de usuario para permitir entregas incrementales y validación independiente.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: La tarea puede ejecutarse en paralelo con otra tarea del mismo bloque sin modificar los mismos archivos.
- **[Story]**: La historia de usuario a la que pertenece; las fases Setup, Foundational y Polish no llevan etiqueta de historia.
- Todas las tareas incluyen rutas concretas del repositorio.

## Phase 1: Setup (Shared Infrastructure)

**Purpose**: Crear el manifiesto y los puntos de entrada locales para generar y validar la página.

- [X] T001 Define el esquema inicial de secciones, exclusiones de infraestructura, inventario esperado y metadatos globales en `content/documentation-manifest.json`
- [X] T002 [P] Crear el punto de entrada PowerShell con parámetros de raíz/salida, lectura UTF-8 y salida determinista en `scripts/build-documentation-page.ps1`
- [X] T003 [P] Crear el punto de entrada PowerShell con reporte legible, códigos de salida y lectura del resultado generado en `scripts/validate-documentation-page.ps1`

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: Implementar el inventario, la serialización segura y el esqueleto común que necesitan todas las historias.

**⚠️ CRITICAL**: Ninguna historia de usuario comienza hasta terminar esta fase.

- [X] T004 Implementar en `scripts/build-documentation-page.ps1` el descubrimiento únicamente dentro de las raíces fuente declaradas en `data-model.md`, excluyendo artefactos de implementación y limitándolo a los 51 archivos documentales definidos
- [X] T005 [P] Implementar en `scripts/validate-documentation-page.ps1` la validación de inventario con los conteos exactos de 45 `.txt`, 4 `.md`, 1 `.yaml` y 1 `.pdf`, además de comprobar que cada ruta declarada existe
- [X] T006 Implementar en `scripts/build-documentation-page.ps1` la lectura Unicode y el escape seguro de texto, atributos y rutas para conservar el contenido original sin permitir que Markdown, comillas o caracteres especiales rompan el HTML generado
- [X] T007 Implementar en `scripts/build-documentation-page.ps1` el modelo compartido de página, la escritura UTF-8 de `index.html`, el contenedor semántico, los estilos base y los puntos de montaje para navegación, documentos, búsqueda y mensajes de estado

**Checkpoint**: El generador produce un `index.html` válido y el validador puede confirmar el inventario antes de añadir historias de usuario.

---

## Phase 3: User Story 1 - Orientarse en el repositorio documental (Priority: P1) 🎯 MVP

**Goal**: Mostrar una introducción clara, contadores y un índice navegable de todas las secciones.

**Independent Test**: Abrir `index.html`, identificar propósito, alcance y número de documentos, seleccionar cada sección desde el índice y volver al índice sin usar el botón atrás.

### Implementation for User Story 1

- [X] T008 [US1] Completar en `content/documentation-manifest.json` los nombres, orden, resúmenes en español, proyectos de referencia y relaciones de las ocho secciones documentales
- [X] T009 [US1] Renderizar en `scripts/build-documentation-page.ps1` la cabecera de bienvenida, el propósito, el alcance, la fecha del inventario y los contadores del corpus en `index.html`
- [X] T010 [US1] Renderizar en `scripts/build-documentation-page.ps1` el índice con anclas estables, enlaces internos, sección activa y acción visible de retorno al índice

**Checkpoint**: La página ya sirve como guía inicial navegable aunque todavía no muestre todos los documentos completos.

---

## Phase 4: User Story 2 - Leer la documentación explicada por secciones (Priority: P1)

**Goal**: Incluir los 51 archivos documentales, con ficha de contexto, explicación editorial y fuente completa.

**Independent Test**: Recorrer las ocho secciones desde `index.html`, abrir cada documento, comprobar ruta/tipo/explicación y comparar la fuente mostrada con el archivo original.

### Implementation for User Story 2

- [X] T011 [P] [US2] Registrar en `content/documentation-manifest.json` los 51 documentos con `path`, `title`, `type`, `sectionId`, `explanation` y `referenceProject` cuando exista, sin omitir rutas con espacios o acentos
- [X] T012 [P] [US2] Implementar en `scripts/build-documentation-page.ps1` la generación de fichas documentales con título, ruta relativa, tipo, sección, proyecto de referencia y explicación separada de la fuente
- [X] T013 [US2] Renderizar en `scripts/build-documentation-page.ps1` el contenido textual completo de cada `.txt`, `.md` y `.yaml` en un bloque legible, conservando saltos de línea, Unicode y texto original
- [X] T014 [US2] Renderizar en `scripts/build-documentation-page.ps1` la tarjeta del PDF `misc/Claude_Course_Course_-_Prompts_Workflow_2026_.pdf` con acciones explícitas de abrir y descargar, sin convertirlo a texto

**Checkpoint**: La página ya contiene y explica todo el corpus documental, y el PDF se puede consultar como recurso original.

---

## Phase 5: User Story 3 - Copiar prompts y comandos con un toque (Priority: P1)

**Goal**: Convertir todos los prompts y comandos reutilizables en bloques con copia individual y estados confirmados.

**Independent Test**: Probar al menos 20 bloques de `index.html`, incluyendo multilínea, acentos, comillas, backticks, rutas con espacios y parámetros; pegar cada resultado y compararlo con el bloque elegido.

### Implementation for User Story 3

- [X] T015 [P] [US3] Declarar en `content/documentation-manifest.json` los bloques `prompt` y `command` de los archivos fuente, incluyendo prompts completos, bloques de comandos delimitados y localizadores de origen cuando estén disponibles
- [X] T016 [P] [US3] Renderizar en `scripts/build-documentation-page.ps1` cada bloque reutilizable con texto exacto, etiqueta visible, identificador único, botón de copia y nombre accesible asociado al documento de origen
- [X] T017 [US3] Implementar en el JavaScript generado por `scripts/build-documentation-page.ps1` la detección de `navigator.clipboard.writeText()`, espera de confirmación, estados `idle/success/failure` y confirmación visible únicamente tras una copia confirmada
- [X] T018 [US3] Implementar en `scripts/validate-documentation-page.ps1` la comprobación de que cada bloque tiene texto no vacío, botón asociado, identificador único y etiqueta `prompt` o `command`, y que ningún botón copia el título o la explicación

**Checkpoint**: La reutilización de prompts y comandos funciona por bloque, con fallback manual cuando el navegador no permite la escritura automática.

---

## Phase 6: User Story 4 - Encontrar material rápidamente (Priority: P2)

**Goal**: Permitir búsqueda global por contenido, metadatos, rutas y comandos con resultados claros.

**Independent Test**: Buscar términos de títulos, rutas, explicaciones y comandos en `index.html`, abrir un resultado, probar un término inexistente y limpiar el filtro.

### Implementation for User Story 4

- [X] T019 [US4] Renderizar en `scripts/build-documentation-page.ps1` el campo de búsqueda etiquetado, el contador de resultados, el estado sin resultados y la acción para limpiar
- [X] T020 [US4] Implementar en el JavaScript generado por `scripts/build-documentation-page.ps1` la normalización de espacios, mayúsculas/minúsculas y acentos, y el filtrado sobre título, ruta, explicación, sección, fuente y bloques reutilizables
- [X] T021 [US4] Implementar en `scripts/build-documentation-page.ps1` la actualización de visibilidad de documentos/secciones y la navegación desde un resultado hasta su ancla, manteniendo disponible el retorno al índice

**Checkpoint**: La búsqueda encuentra material dentro de los 51 documentos y vuelve al estado completo al limpiar el filtro.

---

## Phase 7: User Story 5 - Consultar la página en distintos tamaños (Priority: P2)

**Goal**: Mantener legibilidad, operabilidad y accesibilidad en pantallas estrechas, anchas y mediante teclado.

**Independent Test**: Revisar `index.html` en pantalla móvil y escritorio, leer un documento largo, accionar copia y búsqueda, y recorrer los controles principales con teclado y foco visible.

### Implementation for User Story 5

- [X] T022 [US5] Añadir en los estilos generados por `scripts/build-documentation-page.ps1` reglas responsive para pantallas estrechas, bloques largos, rutas extensas, áreas táctiles y ausencia de contenido esencial cortado
- [X] T023 [US5] Añadir en `scripts/build-documentation-page.ps1` jerarquía semántica de encabezados, labels accesibles, foco visible, estados no dependientes solo del color y regiones `aria-live` para búsqueda y copia
- [X] T024 [US5] Ejecutar los escenarios responsive y de teclado de `specs/001-documentacion-web-personal/quickstart.md` contra `index.html` y corregir en `scripts/build-documentation-page.ps1` cualquier control inaccesible o contenido truncado

**Checkpoint**: Las cinco historias P1/P2 funcionan en la página generada y los controles principales son utilizables con puntero y teclado.

---

## Phase 8: Polish & Cross-Cutting Concerns

**Purpose**: Cerrar paridad, seguridad de contenido, reproducibilidad y validación completa.

- [X] T025 Extender `scripts/validate-documentation-page.ps1` para rechazar fuentes externas, recursos remotos y rutas PDF inexistentes, y confirmar que la página puede funcionar sin red
- [X] T026 Añadir a `scripts/validate-documentation-page.ps1` una comprobación de regeneración determinista y de preservación UTF-8 para detectar diferencias no explicadas entre las fuentes y `index.html`
- [X] T027 Ejecutar `scripts/build-documentation-page.ps1` y `scripts/validate-documentation-page.ps1`, y resolver cualquier discrepancia del inventario o del contenido antes de la revisión visual
- [X] T028 Ejecutar todos los escenarios de `specs/001-documentacion-web-personal/quickstart.md` sobre `index.html`, los bloques de copia y `misc/Claude_Course_Course_-_Prompts_Workflow_2026_.pdf`, documentando cualquier resultado que impida declarar la feature lista

---

## Dependencies & Execution Order

### Phase Dependencies

- **Setup (Phase 1)**: No depende de otras fases.
- **Foundational (Phase 2)**: Depende de Setup y bloquea todas las historias.
- **User Story 1 (Phase 3)**: Depende de Foundational.
- **User Story 2 (Phase 4)**: Depende de Foundational; usa el esqueleto de secciones de Setup y puede desarrollarse en paralelo lógico con US1 si se coordinan las modificaciones al generador.
- **User Story 3 (Phase 5)**: Depende de US2 porque los bloques reutilizables se asocian a documentos renderizados.
- **User Story 4 (Phase 6)**: Depende de US2 porque la búsqueda necesita el corpus completo; puede desarrollarse en paralelo lógico con US3.
- **User Story 5 (Phase 7)**: Depende de US2 y de los controles de US3/US4 para validar la experiencia completa.
- **Polish (Phase 8)**: Depende de todas las historias que se quieran incluir en la entrega.

### User Story Dependencies

```text
Setup
  ↓
Foundational
  ├──→ US1 Orientación
  └──→ US2 Lectura completa
            ├──→ US3 Copia de prompts/comandos
            └──→ US4 Búsqueda
                         └──→ US5 Responsive y accesibilidad
                                      ↓
                                   Polish
```

### Parallel Opportunities

- **Setup**: T002 y T003 pueden ejecutarse en paralelo porque crean dos scripts distintos; T001 debe definir el manifiesto antes de integrar su uso.
- **Foundational**: T005 puede ejecutarse en paralelo con T006 porque trabajan en scripts distintos; T007 integra el resultado en el generador.
- **US1**: T008 debe preceder a T009; no hay paralelismo seguro adicional porque T009 y T010 modifican el mismo generador.
- **US2**: T011 y T012 pueden ejecutarse en paralelo tras acordar el esquema del modelo; T013 y T014 dependen del renderer documental.
- **US3**: T015 y T016 pueden ejecutarse en paralelo porque separan manifiesto y renderer; T017 depende del markup de T016 y T018 del resultado generado.
- **US4**: T019 y T020 pueden diseñarse en paralelo, pero su integración en `scripts/build-documentation-page.ps1` debe hacerse secuencialmente; T021 cierra la navegación.
- **US5**: T022 y T023 afectan la salida del mismo generador y conviene ejecutarlas secuencialmente; T024 es la validación posterior.
- **Polish**: T025 y T026 deben ejecutarse secuencialmente porque amplían el mismo validador; después pueden ejecutarse T027/T028.

## Implementation Strategy

### MVP recomendado

El MVP debe incluir Setup + Foundational + US1 + US2 + US3. US1 por sí sola demuestra la navegación, pero no entrega el valor principal de consultar el material y reutilizar prompts/comandos; por eso las tres historias P1 forman el primer corte útil.

1. Generar el esqueleto y validar el inventario.
2. Entregar orientación e índice.
3. Incorporar los 51 documentos y el PDF.
4. Añadir copia individual y validar 20 bloques representativos.
5. Detenerse en el checkpoint y revisar manualmente antes de continuar con búsqueda y responsive.

### Incremental Delivery

1. Completar Setup + Foundational.
2. Entregar US1 y validar la orientación.
3. Entregar US2 y validar la cobertura documental.
4. Entregar US3 y validar la copia exacta.
5. Entregar US4 y validar búsqueda/no resultados.
6. Entregar US5 y validar móvil, escritorio y teclado.
7. Ejecutar Polish y repetir el quickstart completo.

## Notes

- Cada tarea está marcada con checkbox, ID secuencial, marcador `[P]` solo cuando procede, etiqueta de historia en fases de usuario y rutas concretas.
- La implementación debe conservar la fuente original; las explicaciones editoriales viven en `content/documentation-manifest.json`.
- No se deben añadir dependencias, fuentes remotas, autenticación ni almacenamiento persistente.
