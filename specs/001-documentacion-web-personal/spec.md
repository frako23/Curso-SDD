# Feature Specification: Página web personal de documentación SDD

**Feature Branch**: `master`

**Created**: 2026-10-16

**Status**: Draft

**Input**: User description: "Con base en todos los archivos que están dentro de este repositorio quiero crear una página web HTML para mi consumo personal, con toda la documentación explicada por secciones y con todos los prompts y comandos con un botón para copiarlos automáticamente al tocarlo."

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Orientarse en el repositorio documental (Priority: P1)

Como usuario personal del material, quiero abrir una página única que explique qué contiene el repositorio y cómo está organizado, para decidir rápidamente por dónde empezar.

**Why this priority**: Sin una orientación inicial, la cantidad de prompts y recorridos dificulta encontrar el material adecuado.

**Independent Test**: Abrir la página y localizar en menos de un minuto el propósito del repositorio, el índice de secciones y el número de documentos incluidos, sin leer el contenido completo.

**Acceptance Scenarios**:

1. **Given** la página se abre por primera vez, **When** el usuario observa el inicio, **Then** ve el título, el propósito, una explicación breve del alcance y una navegación hacia todas las secciones.
2. **Given** el usuario está en el inicio, **When** selecciona una sección del índice, **Then** la página lo lleva al comienzo de esa sección y mantiene visible una forma de volver al índice.
3. **Given** el usuario consulta el resumen del corpus, **When** compara los contadores con el repositorio, **Then** puede distinguir los 53 archivos documentales incluidos por la página y el recurso PDF complementario.

### User Story 2 - Leer la documentación explicada por secciones (Priority: P1)

Como usuario del curso, quiero leer cada recorrido documental agrupado por tema, con una explicación sencilla antes del material original, para entender qué aporta cada archivo y cuándo usarlo.

**Why this priority**: El valor principal de la página es convertir una colección de archivos sueltos en una guía consultable sin perder el contenido fuente.

**Independent Test**: Entrar en cada sección del índice, identificar su objetivo, abrir cada documento y comprobar que aparecen su nombre, ruta, explicación y contenido completo.

**Acceptance Scenarios**:

1. **Given** el usuario entra en una sección, **When** revisa su encabezado, **Then** ve una explicación de su propósito, el proyecto de referencia y la relación con el recorrido SDD.
2. **Given** una sección contiene varios archivos, **When** el usuario recorre sus documentos, **Then** cada documento muestra su nombre original, ruta relativa, tipo de archivo y una explicación separada del texto fuente.
3. **Given** el usuario lee un prompt o referencia técnica, **When** compara la explicación con el contenido original, **Then** el texto fuente aparece completo y no se sustituyen silenciosamente instrucciones, comandos, ejemplos ni decisiones.
4. **Given** el usuario consulta el material complementario, **When** selecciona el PDF, **Then** puede abrirlo o descargarlo desde la página y ve claramente que es un recurso PDF, no un documento de texto transformado.

### User Story 3 - Copiar prompts y comandos con un toque (Priority: P1)

Como usuario que trabaja con un agente o una terminal, quiero copiar cada prompt o comando desde un botón junto al bloque correspondiente, para reutilizarlo sin seleccionar texto manualmente.

**Why this priority**: La reutilización práctica de prompts y comandos es el objetivo interactivo explícito de la página.

**Independent Test**: Probar bloques de una línea, multilínea, con acentos, comillas, backticks, rutas con espacios y comandos con parámetros; tocar cada botón y pegar el resultado en un editor para compararlo con el bloque mostrado.

**Acceptance Scenarios**:

1. **Given** un prompt o comando se muestra en un bloque copiable, **When** el usuario toca su botón de copiar, **Then** se copia únicamente el contenido exacto del bloque, sin el título, la explicación ni el botón.
2. **Given** la copia termina correctamente, **When** el usuario observa el control, **Then** recibe una confirmación visible y breve asociada a ese bloque, por ejemplo “Copiado”.
3. **Given** el navegador no permite copiar automáticamente, **When** el usuario toca el botón, **Then** la página informa que la copia no pudo confirmarse y deja el texto visible y seleccionable para copiarlo manualmente.
4. **Given** dos documentos contienen comandos iguales, **When** el usuario copia uno de ellos, **Then** se copia el bloque elegido y se confirma el estado solo en ese control.

### User Story 4 - Encontrar material rápidamente (Priority: P2)

Como usuario que busca una instrucción concreta, quiero filtrar la documentación por palabras, nombres de archivo, temas y comandos, para llegar al contenido sin recorrer toda la página.

**Why this priority**: La búsqueda reduce el tiempo de consulta cuando el corpus crezca o cuando el usuario recuerde solo una palabra parcial.

**Independent Test**: Buscar términos presentes en títulos, rutas, explicaciones y contenido; comprobar que aparecen los documentos relevantes y que una búsqueda sin coincidencias ofrece una salida clara.

**Acceptance Scenarios**:

1. **Given** el usuario escribe un término existente, **When** aplica la búsqueda, **Then** ve solo las secciones o documentos que contienen coincidencias y puede abrir el resultado.
2. **Given** el usuario escribe un término inexistente, **When** aplica la búsqueda, **Then** ve un mensaje de “sin resultados” y una acción para limpiar el filtro.
3. **Given** el usuario limpia la búsqueda, **When** vuelve al estado inicial, **Then** reaparecen todas las secciones y se conserva la posición de lectura de forma razonable.

### User Story 5 - Consultar la página en distintos tamaños (Priority: P2)

Como usuario personal que puede consultar el material desde un ordenador o un móvil, quiero que la página siga siendo legible y operable en ambos tamaños, para no perder el acceso a los documentos ni a los botones de copia.

**Why this priority**: Los prompts largos y los comandos requieren una lectura cómoda, pero la página no debe depender de una pantalla grande.

**Independent Test**: Revisar la página en una pantalla estrecha y una ancha; navegar por el índice, abrir un documento, leer un bloque largo y accionar el botón de copia sin que ningún control quede inaccesible.

**Acceptance Scenarios**:

1. **Given** la página se visualiza en una pantalla estrecha, **When** el usuario navega y lee, **Then** el texto no queda cortado, los controles mantienen un área táctil cómoda y los bloques largos siguen siendo consultables.
2. **Given** la página se visualiza en una pantalla ancha, **When** el usuario lee una sección, **Then** existe una jerarquía visual clara entre navegación, explicación, metadatos, texto fuente y bloques copiados.
3. **Given** el usuario usa teclado, **When** recorre la navegación, la búsqueda y los botones, **Then** puede identificar el foco y ejecutar todas las acciones principales sin depender exclusivamente del puntero.

### Edge Cases

- El repositorio contiene rutas con espacios, acentos y nombres largos; deben mostrarse sin truncarse de forma que impida reconocer el archivo.
- Un prompt puede contener líneas vacías, comillas, caracteres especiales, Markdown o comandos multilínea; la copia debe conservarlos.
- Un documento puede mezclar explicación, texto normal, prompts y comandos; cada bloque copiable debe conservar sus límites.
- La búsqueda puede recibir espacios iniciales o finales, una cadena vacía o mayúsculas/minúsculas distintas; el resultado debe ser comprensible y consistente.
- Un documento no debe desaparecer por ser muy largo; su contenido puede ocupar varias pantallas y debe seguir siendo accesible.
- Si el PDF no puede mostrarse incrustado en el navegador, debe seguir disponible mediante una acción explícita para abrirlo o descargarlo.
- Si la copia automática está bloqueada por permisos o por el contexto de apertura, no se debe mostrar “Copiado” sin confirmación.
- Si una imagen, icono o recurso decorativo no carga, el contenido textual y las acciones principales deben seguir funcionando.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: La página debe presentar en un único documento web el propósito del repositorio, su alcance, sus recorridos recomendados y un índice navegable.
- **FR-002**: La página debe organizar el material en secciones coherentes con el repositorio: introducción y guía general, `spec-first`, `reverse-specs`, `trabajo en paralelo`, `modernización guiada`, `spec-anchored`, GitHub Spec Kit y recursos complementarios.
- **FR-003**: La página debe incluir los 53 archivos documentales actuales de las raíces fuente del repositorio: 46 `.txt`, 5 `.md`, 1 `.yaml` y 1 `.pdf`, identificando cada archivo por su ruta relativa original y excluyendo los artefactos de implementación de esta feature.
- **FR-004**: La página debe incluir el README como guía global, la referencia completa de GitHub Spec Kit, la skill `SKILLs/spec-audit/SKILL.md`, el prompt de agente, todos los prompts de las cinco familias temáticas y el PDF complementario.
- **FR-005**: Cada sección debe comenzar con una explicación en lenguaje claro que describa su objetivo, el problema que aborda, su proyecto de referencia cuando exista y su relación con las demás secciones.
- **FR-006**: Cada documento debe mostrar una ficha de contexto con título legible, ruta relativa, tipo de archivo, tema, proyecto de referencia cuando aplique y una explicación de cuándo resulta útil.
- **FR-007**: El contenido fuente de cada documento textual debe estar disponible completo y separado visualmente de la explicación editorial; la página no debe reescribir ni ocultar instrucciones, ejemplos, preguntas, decisiones o advertencias del archivo original.
- **FR-008**: Todo prompt completo y todo comando presentado como material reutilizable debe aparecer en un bloque claramente identificable y acompañado por un botón de copiar.
- **FR-009**: Cada botón de copiar debe copiar únicamente el bloque asociado, conservar saltos de línea, espacios, acentos y caracteres especiales, y ofrecer una confirmación visible solo después de confirmar la operación.
- **FR-010**: Cuando la copia automática no esté disponible o falle, la página debe informar el fallo sin afirmar éxito y mantener el contenido seleccionable para una copia manual.
- **FR-011**: La página debe ofrecer una búsqueda que encuentre coincidencias en títulos, rutas, explicaciones, nombres de secciones y contenido textual, y debe indicar claramente cuándo no hay resultados.
- **FR-012**: La página debe permitir navegar mediante el índice, enlaces internos y una acción de retorno al índice sin depender del botón atrás del navegador.
- **FR-013**: La página debe mostrar el PDF como recurso complementario con su nombre y tipo, y ofrecer una acción para abrirlo o descargarlo sin transformarlo en un resumen que sustituya al archivo.
- **FR-014**: La página debe mantener una presentación legible en pantallas estrechas y anchas, con controles de copia y búsqueda accesibles mediante puntero y teclado.
- **FR-015**: Los textos de la interfaz y las explicaciones nuevas deben estar en español claro; los comandos, nombres de archivo, identificadores y fragmentos fuente deben conservar su forma original.
- **FR-016**: La página debe ser de consulta personal: no debe requerir autenticación, perfiles, edición de documentos, comentarios, sincronización, pagos ni envío de datos a terceros.
- **FR-017**: El contenido debe indicar que el inventario corresponde al estado actual del repositorio y que incorporar archivos nuevos requiere actualizar el corpus de la página.
- **FR-018**: Los elementos interactivos deben tener nombres comprensibles, foco visible y estados distinguibles para que una persona pueda identificar la sección activa, el resultado de búsqueda y el resultado de copia.

### Key Entities

- **Sección documental**: Agrupación temática de material del repositorio, con nombre, propósito, proyecto de referencia, orden y documentos asociados.
- **Documento**: Archivo fuente representado en la página, con ruta, tipo, título, explicación, contenido original y metadatos de clasificación.
- **Bloque reutilizable**: Fragmento de un documento etiquetado como prompt o comando, con su texto exacto y una acción de copia independiente.
- **Ítem de navegación**: Enlace interno que lleva a una sección o documento y permite volver al índice.
- **Recurso complementario**: Material no textual o auxiliar, como el PDF, que se identifica y se abre o descarga sin perder su formato original.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: Una revisión contra el inventario del repositorio encuentra representados 53 de 53 archivos documentales actuales, sin archivos omitidos ni rutas incorrectas.
- **SC-002**: En una prueba con cinco personas que no hayan revisado el repositorio, al menos cuatro pueden identificar el propósito de la página y abrir la sección adecuada en menos de 60 segundos.
- **SC-003**: En una prueba de al menos 20 bloques representativos, incluidos prompts multilínea, comandos con parámetros, acentos, comillas y rutas con espacios, el 100% de las copias confirmadas coincide exactamente con el bloque elegido.
- **SC-004**: En una prueba manual de búsqueda, al menos el 90% de los términos seleccionados a partir de títulos, nombres de archivos y comandos lleva al documento o sección donde aparece el término.
- **SC-005**: Una persona puede pasar del inicio a cualquier sección y regresar al índice sin usar el botón atrás del navegador en el 100% de las rutas probadas.
- **SC-006**: En anchos de pantalla estrechos y anchos, el 100% de los documentos, botones de copia, búsqueda y enlaces principales permanece accesible y legible sin contenido esencial cortado.
- **SC-007**: En una prueba de teclado, todos los controles principales pueden enfocarse y ejecutarse, y el foco es visible en el 100% de los controles probados.
- **SC-008**: El PDF complementario puede abrirse o descargarse desde la página en el 100% de las pruebas realizadas en los navegadores objetivo.
- **SC-009**: El usuario puede entender que la página es una guía personal de documentación y que no representa una única aplicación ejecutable después de leer la introducción, sin consultar código.

## Assumptions

- La página está destinada a una sola persona y a consulta personal; no se necesita autenticación ni edición colaborativa.
- La primera versión será un documento web autocontenido o estático, sin backend, base de datos ni persistencia de preferencias.
- “Todos los archivos” se interpreta como todo el corpus documental actual de las raíces fuente (`README.md`, `github spec kit/`, `misc/`, `modernización guiada/`, `prompts/`, `reverse-specs/`, `SKILLs/`, `spec-anchored/`, `spec-first/` y `trabajo en paralelo/`): los 53 archivos enumerados en FR-003. `.git`, `.specify`, `.agents`, `specs/`, `scripts/`, `content/` e `index.html` son infraestructura o artefactos de la página, no material didáctico del corpus.
- El PDF se conserva como archivo original y se ofrece como recurso complementario; no se asume que deba convertirse a texto para cumplir la consulta del material.
- Las explicaciones editoriales se añaden sin alterar el contenido fuente, y las diferencias entre proyectos, idiomas, monedas o decisiones de los ejemplos se presentan como parte del material, no como un contrato común.
- El inventario es una fotografía del repositorio en la fecha de esta especificación; los archivos futuros se incorporarán mediante una actualización posterior.
- El navegador permite abrir la página y, cuando sus permisos lo permiten, realizar una copia automática; la alternativa manual cubre los casos en que el navegador la bloquee.
