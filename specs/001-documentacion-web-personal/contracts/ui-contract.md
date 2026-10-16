# UI Contract: Página web personal de documentación SDD

Este contrato describe comportamientos observables. No fija nombres de clases, librerías ni estructura interna.

## Inicio e índice

- La página presenta título, propósito, alcance, fecha del inventario y contadores del corpus.
- Existe un índice con todas las secciones y sus nombres legibles.
- Cada entrada del índice lleva a una sección concreta mediante navegación interna.
- Cada sección ofrece una acción visible para volver al índice.

## Documento

- Cada documento textual muestra título, ruta relativa, tipo, sección, explicación y fuente completa.
- La explicación está separada visualmente de la fuente y no sustituye ningún contenido original.
- Las rutas con espacios, acentos y nombres largos son reconocibles.
- El PDF muestra su nombre, tipo y acciones explícitas para abrirlo o descargarlo.

## Bloque copiable

- Cada bloque de prompt o comando tiene un botón con nombre accesible, por ejemplo “Copiar prompt” o “Copiar comando”.
- El botón copia exactamente el texto del bloque asociado.
- El estado inicial del botón no afirma que se haya copiado.
- Tras una escritura confirmada, el usuario ve una confirmación asociada al mismo bloque.
- Si la escritura no está disponible o falla, el usuario ve un mensaje de error y el bloque sigue seleccionable.
- El foco de teclado y el estado de copia son visibles.

## Búsqueda

- El campo de búsqueda tiene una etiqueta visible o accesible.
- La búsqueda no distingue mayúsculas/minúsculas y tolera espacios periféricos.
- Las coincidencias pueden proceder del título, ruta, explicación, sección o fuente.
- Un resultado muestra suficiente contexto para abrir el documento.
- Cero resultados produce un mensaje claro y una acción para limpiar.

## Adaptación y accesibilidad

- En pantalla estrecha no se pierde ningún documento, botón, enlace o campo de búsqueda.
- Los bloques largos pueden leerse y no se truncan silenciosamente.
- Los encabezados mantienen un orden lógico.
- Todos los controles principales son alcanzables y accionables con teclado.
- Los mensajes de búsqueda y copia se anuncian de forma comprensible sin depender solo del color.
