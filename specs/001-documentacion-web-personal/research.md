# Research: Página web personal de documentación SDD

## Decisión 1: Página estática sin dependencias externas

**Decision**: Usar HTML, CSS y JavaScript estándar, con el contenido documental embebido en el `index.html` generado.

**Rationale**:

- El repositorio no tiene código de aplicación, `package.json`, dependencias ni servidor existente.
- La página es para una sola persona y debe poder abrirse localmente.
- Una solución estática evita autenticación, despliegue, almacenamiento y puntos de fallo que no aportan valor al caso de uso.
- El contenido embebido permite que la lectura funcione incluso sin red y evita depender de `fetch()` de archivos locales, que puede estar restringido por el navegador.

**Alternatives considered**:

- Aplicación con framework y servidor: descartada por añadir complejidad y dependencias sin necesidad funcional.
- Carga de cada documento mediante `fetch()` al abrir la página: descartada como mecanismo principal porque el acceso desde `file://` puede quedar limitado por políticas del navegador.
- iframe por documento: descartado porque dificulta la búsqueda global, la explicación editorial y la copia por bloques.

## Decisión 2: Generación reproducible del contenido

**Decision**: Crear un script local de PowerShell que lea las fuentes documentales, aplique un manifiesto de secciones y explicaciones, extraiga bloques reutilizables y genere el `index.html`.

**Rationale**:

- Evita copiar manualmente 51 archivos en cada actualización.
- Mantiene los archivos originales como fuente de verdad y permite comparar el inventario antes de generar.
- Permite declarar de forma explícita qué fragmentos son prompts o comandos sin alterar la fuente completa.
- Un segundo script puede verificar rutas, conteos y presencia del contenido antes de abrir la página.

**Alternatives considered**:

- Escribir todo el HTML manualmente: descartado por riesgo de omisiones y deriva del contenido.
- Generar la página en tiempo de ejecución desde el navegador: descartado porque requeriría leer archivos locales o ejecutar un servidor.
- Convertir todo Markdown a HTML con una librería: descartado para no introducir dependencias; el texto fuente se conservará en bloques legibles y las explicaciones aportarán la navegación.

## Decisión 3: Copia con confirmación real y fallback manual

**Decision**: El botón usará `navigator.clipboard.writeText()` cuando exista y esperará a que la promesa confirme la escritura antes de mostrar “Copiado”. Si la API no existe, el permiso falla o el contexto no es válido, mostrará un estado de error y mantendrá el texto seleccionable para copiarlo manualmente.

**Rationale**:

- La documentación de MDN indica que `Clipboard.writeText()` escribe texto y resuelve su promesa cuando el portapapeles fue actualizado; también indica que requiere un contexto seguro y puede lanzar `NotAllowedError`.
- La Clipboard API es el mecanismo recomendado frente a `document.execCommand()`, que está obsoleto.
- La especificación exige no anunciar éxito sin confirmación y conservar una alternativa manual.

**Alternatives considered**:

- Mostrar “Copiado” inmediatamente al tocar: descartado porque confunde la intención del usuario con una escritura confirmada.
- Depender de `document.execCommand('copy')`: descartado como mecanismo principal por estar obsoleto y por su comportamiento variable.
- Deshabilitar la copia al abrir `index.html` con `file://`: descartado porque la lectura debe seguir siendo útil y el usuario necesita un mensaje de fallback claro.

**Evidence**: [MDN: Clipboard.writeText()](https://developer.mozilla.org/en-US/docs/Web/API/Clipboard/writeText), [MDN: Clipboard API](https://developer.mozilla.org/en-US/docs/Web/API/Clipboard_API).

## Decisión 4: Inventario explícito y alcance documental

**Decision**: Incluir los 51 archivos fuera de `.git`, `.specify` y `.agents`: README, 45 prompts `.txt`, 3 documentos `.md` adicionales, la skill `.md`, un `.yaml` y el PDF.

**Rationale**:

- Estas son las fuentes documentales del curso identificadas en el inventario actual.
- `.specify` y `.agents` son infraestructura del flujo de trabajo, no material que el usuario pidió estudiar como documentación del curso.
- El PDF se conserva como recurso original porque no debe transformarse ni sustituirse por una extracción parcial.

**Alternatives considered**:

- Incluir scripts y metadatos internos de `.specify` y `.agents`: descartado para la primera versión porque convertiría la guía en documentación de la herramienta y no del curso.
- Omitir el PDF por no ser texto: descartado; se representará como recurso complementario con apertura/descarga.

## Decisión 5: Búsqueda en memoria del corpus generado

**Decision**: Construir un índice de texto normalizado al cargar la página y filtrar documentos y secciones en memoria, sin almacenamiento persistente.

**Rationale**:

- El corpus es pequeño para una búsqueda en el navegador.
- Permite buscar títulos, rutas, explicaciones y fuente completa sin red ni backend.
- La normalización será sensible a espacios y no distinguirá mayúsculas/minúsculas; también se normalizarán acentos para que una búsqueda sin tilde encuentre contenido acentuado.

**Alternatives considered**:

- Motor de búsqueda externo: descartado por privacidad, dependencia de red y escala innecesaria.
- Búsqueda solo por título: descartada porque no encuentra comandos o conceptos dentro de los prompts.
