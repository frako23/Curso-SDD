# AGENTS.md

## Resumen

Este repositorio es una biblioteca documental en español sobre Spec-Driven
Development (SDD): prompts, plantillas, ingeniería inversa, trabajo paralelo,
modernización y GitHub Spec Kit; no es la aplicación de sus proyectos ejemplo.

La página actual es HTML estático: `index.html` se genera desde fuentes UTF-8
mediante PowerShell 5+ y contiene CSS/JavaScript embebidos. No hay
`package.json`, lockfile, backend, base de datos ni dependencias de terceros.

## Mapa del repositorio

- `README.md`: mapa general, recorridos, principios y alcance.
- `spec-first/`, `reverse-specs/`, `modernización guiada/`: diseño nuevo,
  reconocimiento de GesFact y modernización incremental.
- `trabajo en paralelo/`, `spec-anchored/`: coordinación de specs, worktrees,
  OpenSpec, CartaYa y control de drift.
- `github spec kit/github spec kit.md`: referencia de `specify`, comandos de
  agente, extensiones, workflows, bundles e integraciones.
- `SKILLs/spec-audit/SKILL.md`: auditoría de spec drift de CartaYa, solo lectura.
- `content/documentation-manifest.json`: secciones, metadatos y corpus publicado.
- `scripts/build-documentation-page.ps1`: generador de `index.html`.
- `scripts/validate-documentation-page.ps1`: validador de inventario, HTML y
  regeneración determinista.
- `specs/001-documentacion-web-personal/`: spec, plan, tareas y validación de la
  página actual.
- `.specify/`: infraestructura, plantillas y workflow local de Spec Kit;
  `.agents/skills/`: skills instaladas para las fases del flujo.

El corpus publicado está limitado a las raíces declaradas en el manifiesto:
53 fuentes (46 `.txt`, 5 `.md`, 1 `.yaml` y 1 `.pdf`). `.specify/`, `.agents/`,
`specs/`, `scripts/`, `content/` e `index.html` están fuera de ese corpus.

## Comandos

Ejecutar desde la raíz del repositorio (`Curso SDD`):

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\scripts\build-documentation-page.ps1
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\scripts\validate-documentation-page.ps1
```

El primero reconstruye `index.html`; el segundo comprueba inventario, contenido,
bloques copiables, ausencia de recursos externos y salida determinista.

Para probar la Clipboard API desde un origen local, el `quickstart.md` indica,
si `py` está instalado:

```powershell
py -m http.server 8000
```

Después se abre `http://localhost:8000/index.html` y se detiene con `Ctrl+C`.
No se encontró instalación, `dev`, lint, typecheck ni runner de pruebas;
`/speckit-*`, `$speckit-*` y `specify` son instrucciones, no scripts locales.

## Convenciones

- Mantener documentación y textos de interfaz en español, conservando
  identificadores, comandos, rutas, espacios, acentos y nombres existentes.
- Tratar las fuentes como texto original: conservar UTF-8, saltos de línea y
  caracteres especiales.
- Mantener las explicaciones y metadatos en `content/documentation-manifest.json`;
  no mezclarlos dentro del prompt o fuente mostrada al usuario.
- `snippetMetadata: true` en un documento del manifiesto activa, para ese
  documento, la definición de cada snippet (el párrafo o lista que sigue al
  bloque, o el texto introductorio terminado en `:`) y la marca Claude usada por
  el filtro «Solo snippets de Claude»: encabezado que menciona Claude o texto
  con la palabra «claude».
- Un bloque copiable contiene exactamente el prompt o comando, sin título ni
  explicación; su extracción se cambia en el generador y se valida con la fuente.
- Respetar los prefijos numéricos y la organización temática que ya usan las
  carpetas. No convertir ejemplos de proyectos distintos en una arquitectura
  común.

## Arquitectura y dónde cambiar

El flujo real es:

```text
fuentes documentales -> content/documentation-manifest.json
                     -> scripts/build-documentation-page.ps1 -> index.html
                     -> scripts/validate-documentation-page.ps1
```

- Para cambiar contenido, edita la fuente temática; para cambiar título, sección,
  explicación, proyecto o modo de copia, actualiza también el manifiesto.
- Para cambiar markup, estilos, búsqueda, copia, accesibilidad o responsive,
  modifica `scripts/build-documentation-page.ps1` y regenera `index.html`.
- No edites manualmente `index.html`: es una salida generada y el validador
  exige que su regeneración sea determinista.
- Conserva `misc/Claude_Course_Course_-_Prompts_Workflow_2026_.pdf`; la página
  lo enlaza y descarga, pero no lo convierte a texto.
- No añadas `.specify/` ni `.agents/` al manifiesto sin revisar primero el
  alcance de la feature y actualizar inventario, spec, validador y quickstart.

## Pruebas y validación

No existe suite automatizada ni directorio de tests. La validación disponible
es `scripts/validate-documentation-page.ps1`: ejecuta el generador si corresponde
y después el validador. Para cambios visibles, sigue además los escenarios de
`specs/001-documentacion-web-personal/quickstart.md`: índice y ocho secciones,
cobertura del corpus, copia exacta, fallback de portapapeles, búsqueda, PDF,
responsive y teclado. No declares verificada la interacción del navegador a
partir de una inspección estática solamente.

## Restricciones y seguridad

- No introduzcas dependencias, servidor de aplicación, autenticación,
  persistencia, red externa, fuentes remotas ni recursos externos: contradicen
  el plan y el validador actuales.
- No cambies el contrato observable de rutas, contenido, búsqueda, copia
  confirmada o fallback manual sin actualizar la spec y el quickstart.
- Lee el código o documento relacionado antes de modificarlo; respeta las
  convenciones existentes y limita el cambio al alcance solicitado.
- No reviertas ni sobrescribas cambios ajenos o preexistentes. Revisa el estado
  y el diff de Git antes de escribir.
- No leas, copies ni incluyas secretos en código, logs o respuestas; no se
  encontró archivo de ejemplo de variables de entorno.
- No ejecutes operaciones destructivas, despliegues, instalaciones,
  migraciones ni workflows con pasos shell contra entornos compartidos o de
  producción sin autorización explícita. Este repositorio no contiene una
  ruta de despliegue ni migraciones de datos.

## Flujo de trabajo para cambios

1. Leer `README.md`, los artefactos relacionados y una muestra del material;
   comprobar `git status` para preservar trabajo previo.
2. Editar solo fuentes, manifiesto y/o generador según el alcance. No tocar la
   salida generada a mano ni añadir dependencias.
3. Regenerar y ejecutar el validador; abrir `index.html` y aplicar
   los escenarios manuales cuando el cambio afecte la interfaz.
4. Revisar el diff para confirmar que `index.html` refleja las fuentes, que no
   aparecen secretos ni archivos ajenos y que las rutas con espacios/acentos
   siguen intactas.
5. Reportar validaciones ejecutadas, resultados y cualquier validación no
   ejecutada o bloqueada. Actualizar documentación o pruebas/checklists cuando
   el cambio modifique su contrato.

## Documentación y dudas conocidas

- Para el comportamiento de la página, consultar `spec.md`, `plan.md`,
  `data-model.md`, `contracts/ui-contract.md`, `tasks.md` y `quickstart.md` en
  `specs/001-documentacion-web-personal/`; para generación, el manifiesto y ambos scripts.
- Para el flujo de Spec Kit, consultar `.specify/integration.json`,
  `.specify/workflows/speckit/workflow.yml`, las skills bajo `.agents/skills/`
  y `github spec kit/github spec kit.md`.
- `README.md` conserva una descripción anterior de 48 archivos fuente,
  mientras el manifiesto, el modelo y los scripts actuales exigen 53. No
  resuelvas esa discrepancia silenciosamente: si cambia el corpus, pide o
  documenta la decisión y actualiza todas las referencias afectadas.
- `.specify/memory/constitution.md` sigue siendo la plantilla con marcadores
  `[PROJECT_NAME]`, no una constitución ratificada; no conviertas sus
  placeholders en reglas de producto.

