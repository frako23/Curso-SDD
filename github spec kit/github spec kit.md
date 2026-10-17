# GitHub Spec Kit
# Referencia de comandos, significados y usos

Actualizado: 2026-10-01

## 1. Diferencia entre tipos de comandos

Spec Kit tiene dos familias de comandos:

1. Comandos de terminal: empiezan por specify y se ejecutan en PowerShell,
   Bash o cualquier terminal compatible.
2. Comandos del agente: son habilidades que se invocan en el chat del agente
   de programación. No se ejecutan como comandos de terminal.

Formas habituales de invocar una habilidad del agente:

- GitHub Copilot en modo skills: /speckit-specify
- Codex, Command Code y ZCode: $speckit-specify
- Kimi: /skill:speckit-specify
- Notación usada en la documentación: /speckit.specify

En este documento se usa $speckit-* para los ejemplos del agente Codex. La
forma exacta depende de la integración seleccionada al ejecutar specify init.

Notación:

- <valor>: argumento obligatorio.
- [valor]: argumento opcional.
- --opcion: opción o indicador.
- slug: identificador corto en minúsculas y con guiones, por ejemplo
  login-crash.

## 2. Instalación y comprobación inicial

Requisitos principales: Python 3.11 o superior, uv y un agente de
programación compatible.

    uv tool install specify-cli

Instala el ejecutable specify de forma persistente.

    uv tool install specify-cli --from git+https://github.com/github/spec-kit.git@vX.Y.Z

Instala una versión concreta desde una etiqueta del repositorio. Sustituir
vX.Y.Z por una etiqueta real, conservando la v inicial.

    pipx install specify-cli
    pip install specify-cli

Alternativas de instalación mediante pipx o pip.

    specify --version
    specify -V

Muestran rápidamente la versión del CLI instalada.

    specify version
    specify version --features
    specify version --features --json

Muestran la versión de Spec Kit, Python, plataforma y arquitectura. La opción
--features informa las capacidades disponibles; --json produce una salida
para scripts y agentes.

    specify check

Comprueba localmente si están disponibles las herramientas CLI de los agentes.
La comprobación es offline.

## 3. Crear o inicializar un proyecto

    specify init [<nombre-proyecto>]

Crea un proyecto Spec Kit con la estructura .specify/, plantillas, scripts e
integración con el agente de programación.

Ejemplos:

    specify init my-project --integration codex
    cd my-project

    specify init --here --integration codex
    specify init --here --force --integration codex

- my-project: crea una carpeta nueva con ese nombre.
- --here: inicializa en la carpeta actual.
- --force: permite combinar la infraestructura de Spec Kit con una carpeta
  existente y omite la confirmación de combinación.
- --integration <key>: selecciona el agente, por ejemplo codex, copilot,
  claude o gemini.

Opciones de specify init:

    specify init my-project --integration codex --script ps
    specify init my-project --integration codex --ignore-agent-tools
    specify init my-project --integration codex --non-interactive
    specify init my-project --integration codex --preset <preset-id>
    specify init my-project --integration generic --integration-options="--commands-dir .myagent/cmds"

- --script sh: instala scripts Bash/Zsh.
- --script ps: instala scripts PowerShell; es la opción habitual en Windows.
- --script py: instala scripts Python.
- --ignore-agent-tools: no comprueba si el ejecutable del agente está
  instalado localmente.
- --non-interactive: evita preguntas interactivas, útil en CI.
- --preset <preset-id>: instala un preset durante la inicialización.
- --integration-options: pasa opciones específicas a la integración.

La inicialización de Git y la creación de ramas pertenecen a la extensión
opcional git; Spec Kit no la instala automáticamente.

## 4. Actualizar el CLI y los archivos del proyecto

    specify self check

Comprueba si existe una versión más reciente del CLI. Es una operación de solo
lectura.

    specify self upgrade
    specify self upgrade --dry-run
    specify self upgrade --tag vX.Y.Z

- self upgrade: actualiza el CLI instalado mediante uv tool o pipx.
- --dry-run: muestra lo que haría sin modificar la instalación.
- --tag: actualiza a una etiqueta específica.

    specify integration status
    specify integration upgrade <key>
    specify extension update

Después de actualizar el CLI, estos comandos refrescan los archivos de la
integración y las extensiones instaladas en el proyecto.

## 5. Integraciones con agentes

Las integraciones generan los archivos y carpetas que el agente necesita para
reconocer las habilidades de Spec Kit. Todas las operaciones de gestión de
integraciones se ejecutan dentro de un proyecto inicializado.

    specify integration list
    specify integration list --catalog

Lista las integraciones integradas, las instaladas y, con --catalog, las que
pueden descubrirse en los catálogos.

    specify integration search [query]
    specify integration info <integration-id>

- search: busca integraciones disponibles; admite --tag y --author.
- info: muestra descripción, autor, licencia, etiquetas, origen y estado.

    specify integration install <key>
    specify integration uninstall [<key>]
    specify integration switch <key>
    specify integration use <key>
    specify integration upgrade [<key>]
    specify integration status
    specify integration status --json

- install: instala una integración adicional.
- uninstall: elimina una integración; --force también elimina archivos
  modificados.
- switch: cambia a otra integración, instalándola si hace falta.
- use: selecciona como predeterminada una integración ya instalada.
- upgrade: actualiza sus archivos y comandos.
- status: informa integraciones instaladas, archivos faltantes o modificados;
  --json sirve para CI y scripts.

Opciones importantes:

    specify integration install generic --integration-options="--commands-dir .myagent/cmds"
    specify integration install generic --integration-options="--commands-dir .myagent/skills --skills"
    specify integration install <key> --force
    specify integration switch <key> --refresh-shared-infra
    specify integration scaffold <key>

- --integration-options: opciones específicas, como la carpeta de comandos.
- --skills: usa carpetas speckit-<nombre>/SKILL.md cuando la integración
  lo admite.
- --force: permite instalar junto a integraciones no declaradas como seguras
  para múltiples instalaciones o sobrescribir archivos gestionados.
- --refresh-shared-infra: refresca también la infraestructura compartida.
- scaffold: crea una integración mínima para desarrolladores de Spec Kit.

Catálogos de integraciones:

    specify integration catalog list
    specify integration catalog add <url> [--name <nombre>]
    specify integration catalog remove <index>

Permiten consultar, agregar o quitar fuentes de descubrimiento de
integraciones.

### Usar Claude Code como integración

La clave de la integración es claude. Cada bloque siguiente es independiente y
se puede copiar por separado; la explicación de cada uno aparece debajo.
Ejecutarlos dentro de la carpeta del proyecto.

    specify init my-project --integration claude --script ps

Crea un proyecto nuevo en la carpeta my-project, con Claude como agente y
scripts PowerShell.

    specify init --here --integration claude

Inicializa Spec Kit en la carpeta actual con Claude como agente.

    specify init --here --force --integration claude

Inicializa la carpeta actual con Claude aunque ya contenga archivos; --force
combina la infraestructura de Spec Kit con lo existente sin pedir confirmación.

    specify integration install claude

Instala Claude como integración adicional, sin quitar la que ya existe (por
ejemplo codex).

    specify integration switch claude

Cambia la integración existente por Claude, instalándola si hace falta.

    specify integration switch claude --refresh-shared-infra

Cambia a Claude y refresca también la infraestructura compartida (scripts y
plantillas de .specify/).

    specify integration use claude

Selecciona Claude como integración predeterminada cuando ya está instalada.

    specify integration uninstall codex

Elimina la integración anterior (aquí codex) una vez que Claude funciona;
--force también borra los archivos que se hayan modificado.

    specify integration upgrade claude

Actualiza los archivos y comandos de la integración Claude, por ejemplo tras
actualizar el CLI.

    specify integration status

Informa qué integraciones están instaladas y si faltan archivos o fueron
modificados; añadir --json para CI y scripts.

    specify check

Comprueba localmente, sin red, que el ejecutable de Claude Code y las demás
herramientas de agente están disponibles.

Con Claude, las habilidades se invocan en el chat de Claude Code con el
prefijo /speckit-, por ejemplo /speckit-specify en lugar de $speckit-specify.
Al cambiar de Codex a Claude, sustituir $speckit- por /speckit- en los
ejemplos de las secciones siguientes.

## 6. Extensiones

Las extensiones agregan comandos, plantillas, scripts, hooks o procesos
especializados. Requieren que el proyecto haya sido inicializado.

    specify extension search [query]

Busca extensiones disponibles. Admite --tag, --author y --verified.

    specify extension add <name>
    specify extension add <name> --version <version>
    specify extension add <name> --dev <directorio>
    specify extension add <name> --from <url>
    specify extension add <name> --priority <N>

Instala una extensión desde un catálogo, una versión concreta, un directorio
local o una URL. Un número de prioridad menor tiene precedencia mayor cuando
varias extensiones ofrecen el mismo comando.

Extensiones de procesos oficiales:

    specify extension add git
    specify extension add bug
    specify extension add assess
    specify extension add github

- git: ramas, inicialización y commits automáticos.
- bug: diagnóstico, reparación y prueba de bugs.
- assess: evaluación de ideas antes de invertir en su desarrollo.
- github: reemplazo con namespace para la sincronización de tareas con
  GitHub; puede exponer taskstoissues como speckit.github.taskstoissues.

Gestión de extensiones:

    specify extension list
    specify extension list --available
    specify extension list --all
    specify extension list --json
    specify extension info <name>
    specify extension info <name> --versions
    specify extension update [<name>]
    specify extension enable <name>
    specify extension disable <name>
    specify extension set-priority <name> <priority>
    specify extension remove <name>
    specify extension remove <name> --keep-config
    specify extension remove <name> --force

- list: muestra extensiones instaladas; --available agrega las no
  instaladas, --all muestra ambas y --json genera salida estructurada.
- info: muestra metadatos, comandos, configuración y versiones disponibles.
- update: actualiza una extensión o todas si no se indica un nombre.
- enable / disable: activa o desactiva una extensión sin desinstalarla.
- set-priority: cambia su prioridad de resolución.
- remove: elimina una extensión; --keep-config conserva la configuración y
  --force omite la confirmación.

Catálogos de extensiones:

    specify extension catalog list
    specify extension catalog add <url> --name <name>
    specify extension catalog remove <name>

Una fuente discovery-only permite descubrir, pero no instalar directamente,
su contenido. Revisar siempre una extensión de terceros antes de instalarla.

## 7. Presets

Los presets modifican comandos, plantillas, scripts o terminología sin cambiar
el ejecutable de Spec Kit. Pueden combinarse por prioridad.

    specify preset search [query]
    specify preset add [<preset-id>]
    specify preset add <preset-id> --dev <directorio>
    specify preset add <preset-id> --from <url>
    specify preset add <preset-id> --priority <N>
    specify preset update <preset-id>
    specify preset remove <preset-id>
    specify preset list
    specify preset list --json
    specify preset info <preset-id>
    specify preset resolve <name>
    specify preset enable <preset-id>
    specify preset disable <preset-id>
    specify preset set-priority <preset-id> <priority>

- search: busca presets.
- add: instala un preset desde catálogo, URL o directorio local.
- update: reemplaza un preset instalado por una versión actualizada.
- remove: desinstala el preset y quita sus registros.
- list: enumera presets instalados.
- info: muestra metadatos y archivos proporcionados.
- resolve: indica qué archivo gana en la pila de resolución.
- enable / disable: activa o desactiva el preset conservándolo instalado.
- set-priority: establece precedencia; el número menor gana.

Catálogos de presets:

    specify preset catalog list
    specify preset catalog add <url> --name <name>
    specify preset catalog remove <name>

## 8. Inspección de artefactos

Un artefacto es un comando, plantilla, script o hook visible en el proyecto.
Estos comandos son de solo lectura y requieren --json.

    specify artifact list --json
    specify artifact info <name> --json
    specify artifact info <name> --json --kind command

- list: muestra el inventario completo y la pila de composición.
- info: muestra de qué capa proviene un artefacto y qué capas quedaron
  ocultas. <name> puede ser speckit.specify o command:speckit.specify.
- --kind: limita la búsqueda a command, template, script o hook.

## 9. Workflows

Los workflows automatizan varios pasos, prompts, comandos, scripts de shell y
aprobaciones humanas en una secuencia reutilizable.

    specify workflow run <source>
    specify workflow run speckit -i spec="Build a kanban board"
    specify workflow run <archivo.yml> --json

Ejecuta un workflow identificado por catálogo, URL o archivo local. -i o
--input pasa valores como clave=valor; --json devuelve el resultado para
automatización.

    specify workflow resume <run-id>
    specify workflow resume <run-id> --input <clave>=<valor>
    specify workflow resume <run-id> --json

Reanuda un workflow pausado o fallido desde el paso exacto donde se detuvo.

    specify workflow status [<run-id>]
    specify workflow status [<run-id>] --json
    specify workflow list

- status: muestra el estado de una ejecución o de todas las ejecuciones.
- Estados: created, running, completed, paused, failed y aborted.
- list: lista los workflows instalados.

Gestión de workflows:

    specify workflow add <source>
    specify workflow add <source> --dev
    specify workflow add <workflow-id> --from <url>
    specify workflow add <workflow-id> --version <version>
    specify workflow update [<workflow-id>]
    specify workflow enable <workflow-id>
    specify workflow disable <workflow-id>
    specify workflow remove <workflow-id>
    specify workflow search [query]
    specify workflow info <workflow-id>
    specify workflow info <workflow-id> --versions
    specify workflow resolve <workflow-id>

- add: instala un workflow desde catálogo, URL, YAML, directorio o archivo
  comprimido.
- --dev: instala una fuente local durante el desarrollo.
- update: actualiza uno o todos los workflows instalados.
- enable / disable: activa o desactiva un workflow sin eliminarlo.
- remove: desinstala un workflow.
- search: busca workflows por texto, --tag o --author.
- info: muestra pasos, entradas, requisitos y versiones.
- resolve: muestra cómo se compone el workflow a partir de la base y sus
  overlays.

Overlays de workflows:

    specify workflow overlay add <archivo-overlay.yml> --priority <N>
    specify workflow overlay list <workflow-id>
    specify workflow overlay set-priority <workflow-id> <overlay-id> <N>
    specify workflow overlay enable <workflow-id> <overlay-id>
    specify workflow overlay disable <workflow-id> <overlay-id>
    specify workflow overlay remove <workflow-id> <overlay-id>

Permiten insertar, reemplazar o quitar pasos de un workflow sin editar el
workflow instalado. Los números de prioridad menores tienen precedencia mayor.

Catálogos de workflows:

    specify workflow catalog list
    specify workflow catalog add <url> [--name <name>]
    specify workflow catalog remove <index>

### Tipos de paso de workflow

Las versiones que incluyen catálogo de pasos también exponen:

    specify workflow step list
    specify workflow step add <id>
    specify workflow step remove <id>
    specify workflow step search [query]
    specify workflow step info <id>
    specify workflow step catalog list
    specify workflow step catalog add <url>
    specify workflow step catalog remove <index>

Estos comandos descubren, instalan, consultan o eliminan tipos de paso
personalizados del motor de workflows. Los tipos incorporados incluyen
command, prompt, shell, init, slot, gate, if, switch, while, do-while,
fan-out y fan-in.

Revisar siempre un workflow antes de ejecutarlo: un paso shell puede ejecutar
comandos locales con los permisos del usuario.

## 10. Bundles

Un bundle empaqueta extensiones, presets, workflows y pasos en una unidad
versionada e instalable.

    specify bundle search [query]
    specify bundle search [query] --offline
    specify bundle search [query] --json
    specify bundle info <bundle-id>
    specify bundle info <bundle-id> --offline --json

- search: busca bundles disponibles.
- --offline: evita la red.
- --json: produce salida estructurada.
- info: muestra todos los componentes y versiones que instalaría.

    specify bundle install <bundle-id | path>
    specify bundle add <bundle-id>
    specify bundle install <path> --refresh
    specify bundle update [<bundle-id>]
    specify bundle update --all
    specify bundle remove <bundle-id>
    specify bundle list
    specify bundle list --json

- install y add: instalan un bundle desde un catálogo, directorio, archivo
  bundle.yml o .zip; add es alias de install.
- --refresh: vuelve a aplicar los componentes propios del bundle.
- update: actualiza un bundle; --all actualiza todos.
- remove: elimina solo los componentes aportados por ese bundle.
- list: muestra bundles instalados, versiones y fechas.

    specify bundle init [<bundle-id>]
    specify bundle validate
    specify bundle validate --path <directorio-o-bundle.yml>
    specify bundle build
    specify bundle build --path <directorio> --output <directorio-salida>

- init: inicializa el proyecto si hace falta y opcionalmente instala un
  bundle.
- validate: verifica el manifiesto y las referencias.
- build: crea un artefacto .zip distribuible.

Bundles oficiales del README:

    specify bundle install bugfix
    specify bundle add assess

Catálogos de bundles:

    specify bundle catalog list
    specify bundle catalog add <url> --policy install-allowed --priority <N>
    specify bundle catalog remove <id-o-url>

## 11. Flujo principal de Spec-Driven Development (SDD)

Después de specify init, abrir el agente dentro de la carpeta del proyecto.
El flujo recomendado es:

    $speckit-constitution
    $speckit-specify
    $speckit-clarify
    $speckit-plan
    $speckit-checklist
    $speckit-tasks
    $speckit-analyze
    $speckit-implement
    $speckit-converge

Solo specify es estrictamente necesario antes de plan. clarify, checklist y
analyze son controles de calidad opcionales.

### $speckit-constitution

    $speckit-constitution Define principles focused on code quality, testing and maintainability.

Crea o actualiza la constitución del proyecto: principios que guían y evalúan
las fases posteriores. Normalmente se ejecuta una vez por proyecto.

### $speckit-specify

    $speckit-specify Build a photo organizer with albums grouped by date.

Crea o actualiza la especificación funcional. Define qué se necesita y por qué,
incluyendo comportamiento visible para el usuario, historias de usuario y
criterios de aceptación; no decide todavía la tecnología.

### $speckit-clarify

    $speckit-clarify Focus on permissions, status changes and assignment rules.

Formula preguntas sobre ambigüedades de la especificación y registra las
respuestas en spec.md. Puede repetirse antes de planificar.

### $speckit-plan

    $speckit-plan Use Vite, vanilla JavaScript and SQLite for local metadata.

Genera el plan técnico: arquitectura, tecnologías, datos, interfaces,
restricciones y estrategia de implementación.

### $speckit-checklist

    $speckit-checklist
    $speckit-checklist Focus on authentication and authorization requirements.

Genera una lista de comprobación de calidad de los requisitos. Verifica que la
especificación sea completa, clara, consistente y no ambigua. No es una lista
de tareas de implementación.

### $speckit-tasks

    $speckit-tasks

Convierte los artefactos de diseño en tasks.md: tareas accionables ordenadas
por dependencias, fases e historias de usuario.

### $speckit-analyze

    $speckit-analyze

Realiza un análisis de solo lectura entre spec.md, plan.md y tasks.md.
Detecta conflictos, huecos, ambigüedades y tareas sin requisito asociado. No
edita archivos.

### $speckit-implement

    $speckit-implement
    $speckit-implement Implement only the Setup and Foundational phases.

Ejecuta las tareas de tasks.md respetando sus dependencias y marcas de
paralelización. Puede ejecutarse por fases pasando un alcance como argumento.

### $speckit-converge

    $speckit-converge

Compara la implementación con la especificación, el plan y las tareas. Si no
hay faltantes informa Converged; si encuentra faltantes, agrega nuevas tareas
en la sección Convergence de tasks.md. Repetir implement y converge hasta
obtener Converged.

### $speckit-taskstoissues

    $speckit-taskstoissues

Convierte las tareas existentes en issues de GitHub. Requiere un remoto origin,
acceso al repositorio y herramientas MCP de GitHub. Es opcional y no es
necesario para implementar o converger.

La extensión GitHub también puede proporcionar la variante namespaced:

    specify extension add github
    $speckit-github-taskstoissues

## 12. Corrección de bugs

Instalar primero la extensión:

    specify extension add bug

Instala la extensión bug, que añade los comandos de evaluación, corrección y
prueba de bugs.

Flujo del agente:

    $speckit-bug-assess "Submitting an empty password crashes the login form." slug=login-crash
    $speckit-bug-fix slug=login-crash
    $speckit-bug-test slug=login-crash

- $speckit-bug-assess: evalúa si el reporte es un bug real, localiza las
  rutas de código y propone una corrección. Solo escribe assessment.md.
- $speckit-bug-fix: aplica la corrección evaluada y documenta los cambios en
  fix.md. Es el único comando de este flujo que modifica el código fuente.
- $speckit-bug-test: reproduce y verifica el resultado; escribe test.md.

Los reportes se guardan en .specify/bugs/<slug>/. El veredicto final es
verified, partial o failed. Un bug sin verificación no debe considerarse
corregido.

## 13. Evaluación de ideas

Instalar primero la extensión:

    specify extension add assess

Instala la extensión assess, que añade los comandos para evaluar una idea antes
de especificarla.

Flujo del agente:

    $speckit-assess-intake "Let users work offline and sync when they reconnect." slug=offline-mode
    $speckit-assess-research slug=offline-mode
    $speckit-assess-define slug=offline-mode
    $speckit-assess-shape slug=offline-mode
    $speckit-assess-decide slug=offline-mode

- $speckit-assess-intake: captura la idea desde texto, URL, ticket o
  referencia a un código y crea intake.md.
- $speckit-assess-research: reúne evidencia a favor y en contra, con fuentes
  y nivel de confianza; crea research.md.
- $speckit-assess-define: define usuarios, problema, objetivos, no-objetivos,
  métricas y coste de no actuar; crea problem.md.
- $speckit-assess-shape: compara opciones conceptuales, esfuerzo y
  compromisos; crea concept.md.
- $speckit-assess-decide: registra scorecard, justificación y veredicto en
  decision.md.

Los artefactos se guardan en .specify/assessments/<slug>/. Los veredictos son:

- go: la idea tiene evidencia suficiente y una opción recomendada.
- needs-clarification: existen incertidumbres que bloquean la decisión.
- kill: no conviene continuar por ahora; se documenta la razón.

Una decisión go puede entregarse después a $speckit-specify, pero la evaluación
no inicia SDD automáticamente.

## 14. Extensión Git

Instalación:

    specify extension add git

Instala la extensión git, que añade ramas, validación de nombres y commits
automáticos.

Comandos del agente que proporciona la extensión:

    $speckit-git-initialize
    $speckit-git-feature
    $speckit-git-validate
    $speckit-git-remote
    $speckit-git-commit

- git-initialize: inicializa un repositorio Git con un mensaje de commit
  configurable.
- git-feature: crea una rama de feature con numeración secuencial o por
  fecha/hora.
- git-validate: comprueba que la rama actual respete la convención de nombres.
- git-remote: detecta la URL remota para integraciones con GitHub.
- git-commit: crea commits automáticos según la configuración.

La extensión puede ejecutar hooks antes o después de comandos SDD, por ejemplo
crear el repositorio antes de constitution, crear una rama antes de specify y
hacer commits después de plan, tasks o implement.

Configuración principal:

    .specify/extensions/git/git-config.yml

Archivo de configuración de la extensión Git: nombres de ramas, commits y
hooks.

La extensión Git es opcional. Si Git no está instalado, Spec Kit puede seguir
creando especificaciones, aunque las ramas, validaciones y remotos se omiten
con una advertencia.

## 15. Secuencia rápida recomendada para Codex

    uv tool install specify-cli
    specify init mi-proyecto --integration codex --script ps
    cd mi-proyecto
    specify extension add git

- uv tool install specify-cli: instala el ejecutable specify.
- specify init mi-proyecto --integration codex --script ps: crea el proyecto
  con Codex como agente y scripts PowerShell.
- cd mi-proyecto: entra en la carpeta del proyecto.
- specify extension add git: instala la extensión opcional de ramas y commits.

Flujo en el chat de Codex:

    $speckit-constitution Define principles for quality, testing and maintainability.
    $speckit-specify Describe the feature and its user stories.
    $speckit-clarify Resolve the ambiguous requirements.
    $speckit-plan Choose the architecture and technology.
    $speckit-checklist
    $speckit-tasks
    $speckit-analyze
    $speckit-implement
    $speckit-converge

- $speckit-constitution: fija los principios de calidad, pruebas y
  mantenibilidad del proyecto.
- $speckit-specify: crea la especificación funcional con historias de usuario.
- $speckit-clarify: resuelve las ambigüedades de la especificación.
- $speckit-plan: elige la arquitectura y la tecnología.
- $speckit-checklist: genera la lista de calidad de los requisitos.
- $speckit-tasks: convierte el diseño en tareas ordenadas en tasks.md.
- $speckit-analyze: revisa en solo lectura la coherencia entre spec, plan y
  tareas.
- $speckit-implement: ejecuta las tareas de tasks.md.
- $speckit-converge: compara la implementación con la spec y añade las tareas
  que falten.

Si converge agrega tareas, repetir:

    $speckit-implement
    $speckit-converge

- $speckit-implement: ejecuta las tareas nuevas.
- $speckit-converge: vuelve a comprobar; termina cuando informa Converged.

### Variante para Claude Code

    uv tool install specify-cli
    specify init mi-proyecto --integration claude --script ps
    cd mi-proyecto
    specify extension add git

- uv tool install specify-cli: instala el ejecutable specify.
- specify init mi-proyecto --integration claude --script ps: crea el proyecto
  con Claude como agente y scripts PowerShell.
- cd mi-proyecto: entra en la carpeta del proyecto.
- specify extension add git: instala la extensión opcional de ramas y commits.

Flujo en el chat de Claude Code:

    /speckit-constitution Define principles for quality, testing and maintainability.
    /speckit-specify Describe the feature and its user stories.
    /speckit-clarify Resolve the ambiguous requirements.
    /speckit-plan Choose the architecture and technology.
    /speckit-checklist
    /speckit-tasks
    /speckit-analyze
    /speckit-implement
    /speckit-converge

- /speckit-constitution: fija los principios de calidad, pruebas y
  mantenibilidad del proyecto.
- /speckit-specify: crea la especificación funcional con historias de usuario.
- /speckit-clarify: resuelve las ambigüedades de la especificación.
- /speckit-plan: elige la arquitectura y la tecnología.
- /speckit-checklist: genera la lista de calidad de los requisitos.
- /speckit-tasks: convierte el diseño en tareas ordenadas en tasks.md.
- /speckit-analyze: revisa en solo lectura la coherencia entre spec, plan y
  tareas.
- /speckit-implement: ejecuta las tareas de tasks.md.
- /speckit-converge: compara la implementación con la spec y añade las tareas
  que falten.

Si converge agrega tareas, repetir:

    /speckit-implement
    /speckit-converge

- /speckit-implement: ejecuta las tareas nuevas.
- /speckit-converge: vuelve a comprobar; termina cuando informa Converged.

## 16. Fuentes oficiales

- README: https://github.com/github/spec-kit
- Referencia del CLI: https://github.github.io/spec-kit/reference/overview.html
- Comandos SDD: https://github.github.io/spec-kit/reference/agentic-sdd.html
- Corrección de bugs: https://github.github.io/spec-kit/reference/agentic-bugfix.html
- Evaluación de ideas: https://github.github.io/spec-kit/reference/agentic-assessment.html
- Instalación: https://github.com/github/spec-kit/blob/main/docs/installation.md
- Actualización: https://github.com/github/spec-kit/blob/main/docs/upgrade.md

