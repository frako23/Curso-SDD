Analiza este repositorio y crea un archivo AGENTS.md en la raíz que sirva como guía práctica para los agentes de programación que trabajen en este proyecto.

No quiero una plantilla genérica: quiero instrucciones específicas, concisas y respaldadas por el contenido real del repositorio.

1. Inspecciona antes de escribir

Revisa, cuando existan:
- README y documentación relevante.
- Manifiestos de dependencias, scripts y lockfiles.
- Configuración de TypeScript, linting, formato y pruebas.
- Estructura de carpetas y puntos de entrada.
- Una muestra representativa del código y sus pruebas.
- Workflows de CI/CD.
- Archivos de ejemplo de variables de entorno, sin leer secretos.
- Instrucciones existentes: AGENTS.md, AGENTS.override.md, CLAUDE.md,
  .github/copilot-instructions.md y archivos relevantes dentro de .agents/.

No recorras dependencias, archivos generados, builds ni archivos grandes
que no sean necesarios para entender el proyecto.

Si ya existe un AGENTS.md, mejóralo en lugar de reemplazarlo a ciegas.
Conserva las instrucciones válidas y señala cualquier contradicción importante.

2. Escribe únicamente instrucciones útiles para trabajar en este repositorio

Incluye estas secciones solo cuando exista información suficiente:

- Resumen: qué hace el proyecto y cuál es su stack principal.
- Mapa del repositorio: carpetas importantes y sus responsabilidades.
- Comandos: instalación, desarrollo, lint, typecheck, pruebas y build.
- Convenciones: patrones de código, nombres, organización e imports.
- Arquitectura: límites entre módulos y dónde agregar cada tipo de cambio.
- Pruebas: cómo ejecutarlas y qué pruebas acompañan cada tipo de cambio.
- Restricciones: código generado, compatibilidad y zonas delicadas.
- Seguridad: manejo de secretos y operaciones que requieren autorización.
- Flujo de trabajo: cómo implementar y validar un cambio.
- Documentación relacionada: rutas que conviene consultar según la tarea.

3. Aplica estas reglas de calidad

- No inventes comandos, rutas, herramientas ni convenciones.
- Distingue entre lo verificado en archivos y lo inferido del código.
- No conviertas un patrón aislado en una regla general.
- Si documentación, scripts y CI se contradicen, señala el conflicto;
  no elijas silenciosamente una versión.
- No añadas recomendaciones genéricas como “escribe código limpio”.
- No impongas nuevas tecnologías, arquitecturas ni estándares.
- Usa rutas y comandos exactos; indica desde qué directorio se ejecutan.
- No afirmes que un comando funciona si no lo ejecutaste.
- Evita duplicar documentación extensa: enlaza los archivos relevantes.
- Mantén el archivo breve y fácil de consultar; apunta a 100–150 líneas,
  pero prioriza la utilidad sobre cumplir una longitud exacta.
- Redáctalo en español, conservando identificadores y comandos originales.

4. Incluye estas reglas operativas para futuros agentes

- Leer el código relacionado antes de modificarlo.
- Respetar las convenciones existentes y limitar el cambio al alcance pedido.
- No revertir ni sobrescribir cambios ajenos o preexistentes.
- No introducir dependencias ni cambiar contratos públicos sin autorización.
- No leer, copiar ni incluir secretos en código, logs o respuestas.
- No ejecutar operaciones destructivas, despliegues ni migraciones contra
  entornos compartidos o de producción sin autorización explícita.
- Ejecutar las validaciones relevantes disponibles y reportar cuáles
  se ejecutaron, sus resultados y cuáles no pudieron ejecutarse.
- Actualizar documentación o pruebas cuando el cambio lo requiera.

5. Alcance de esta tarea

Crea o actualiza únicamente AGENTS.md.
No modifiques código, configuraciones, dependencias ni lockfiles.
No instales dependencias ni ejecutes scripts del proyecto para esta tarea:
obtén los comandos mediante inspección y aclara que no fueron ejecutados.

Si hay áreas con instrucciones muy distintas —por ejemplo, frontend y
backend dentro de un monorepo—, recomienda AGENTS.md adicionales en
subdirectorios, pero no los crees todavía.

Al terminar, resume:
- Qué creaste o actualizaste.
- Qué archivos usaste como evidencia.
- Qué información no pudiste verificar.
- Qué contradicciones o dudas necesitan revisión humana.