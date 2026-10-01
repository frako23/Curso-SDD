# Curso SDD

Repositorio de material práctico para trabajar con desarrollo guiado por
especificaciones (Spec-Driven Development, SDD). Contiene prompts, plantillas,
convenciones y ejemplos de flujo para crear productos nuevos, documentar
sistemas heredados, coordinar trabajo en paralelo y modernizar módulos sin
perder el comportamiento existente.

Este repositorio es documental: no contiene una aplicación ejecutable ni el
código de los productos descritos en los ejemplos.

## Contenido

| Carpeta | Tema | Proyecto de referencia | Contenido |
| --- | --- | --- | --- |
| [`spec-first/`](<spec-first>) | Diseño desde cero | PresupuestosPro | Constitución, preguntas de calidad, plantilla universal, especificación inicial, cambios de presentación, exportación, convenciones y prompts visuales. |
| [`reverse-specs/`](<reverse-specs>) | Ingeniería inversa | GesFact | Reconocimiento de un sistema heredado de facturación: mapa, flujos, riesgos, reglas, contradicciones, anomalías, entrevistas, tests de caracterización y spec pack. |
| [`trabajo en paralelo/`](<trabajo en paralelo>) | Colaboración con ramas y worktrees | CitaClara | Agenda clínica, portal del paciente, recordatorios, analítica, revisión cruzada, mapa de specs, merge y acceso/cancelación. |
| [`modernización guiada/`](<modernización guiada>) | Modernización incremental | GesFact | Selección de módulos, extracción del motor de cálculo con *strangler fig* y corrección delta del prorrateo. |
| [`spec-anchored/`](<spec-anchored>) | OpenSpec y control de drift | CartaYa | Configuración anclada, carta digital, pedidos de mesa, panel de cocina y un prompt de cambio que sirve como ejemplo de *spec drift*. |
| [`SKILLs/spec-audit/`](<SKILLs/spec-audit>) | Skill de auditoría | CartaYa | Instrucciones para comparar specs vivas, código, tests, entorno, historial y cambios activos sin modificar nada. |
| [`github spec kit/`](<github spec kit>) | GitHub Spec Kit | — | Referencia completa de comandos de terminal, habilidades del agente, extensiones, workflows y bundles en [`github spec kit.md`](<github spec kit/github spec kit.md>). |

## Recorridos recomendados

### Crear un producto nuevo

1. Leer [`spec-first/001-prompt_constitution.txt`](<spec-first/001-prompt_constitution.txt>) y fijar los principios del producto.
2. Usar [`spec-first/002-preguntas_spec.txt`](<spec-first/002-preguntas_spec.txt>) como lista de revisión.
3. Redactar la primera especificación a partir de [`spec-first/003-spec_plantilla_universal.txt`](<spec-first/003-spec_plantilla_universal.txt>) y [`spec-first/004-prompt_spec_servilleta.txt`](<spec-first/004-prompt_spec_servilleta.txt>).
4. Resolver ambigüedades antes de implementar con [`spec-first/005-prompt_speckit_specify.txt`](<spec-first/005-prompt_speckit_specify.txt>).
5. Continuar con el plan, la inicialización del repositorio y la documentación técnica según los prompts 006–014.

### Documentar un sistema heredado

Seguir [`reverse-specs/001-prompt_constitution.txt`](<reverse-specs/001-prompt_constitution.txt>) y después el flujo de reconocimiento: mapa del sistema, ciclo de vida de factura, riesgos, memoria histórica, reglas de negocio, contradicciones y anomalías. A continuación, cerrar las decisiones con la entrevista, congelar el comportamiento mediante tests, proponer la partición por dominios y ensamblar el paquete final.

### Coordinar varias features

La carpeta [`trabajo en paralelo/`](<trabajo en paralelo>) muestra un flujo con una spec base, features independientes en ramas, revisión cruzada desde el tronco y posterior integración. [`trabajo en paralelo/004-prompt_revision_specs.txt`](<trabajo en paralelo/004-prompt_revision_specs.txt>) define cómo leer las specs por commit sin hacer checkout.

### Modernizar sin cambiar el contrato

Usar [`modernización guiada/002-prompt_analisis_modulos.txt`](<modernización guiada/002-prompt_analisis_modulos.txt>) para elegir el primer módulo, [`modernización guiada/003-prompt_spec_modernizacion_motor_calculo.txt`](<modernización guiada/003-prompt_spec_modernizacion_motor_calculo.txt>) para extraerlo manteniendo equivalencia y [`modernización guiada/004-prompt_cambio_anomalia.txt`](<modernización guiada/004-prompt_cambio_anomalia.txt>) para aplicar después un cambio de negocio explícito y no retroactivo.

## Principios comunes

- La especificación es la fuente de verdad del comportamiento observable.
- El alcance debe ser explícito; las ideas nuevas se registran como propuestas.
- Las reglas de negocio se expresan con ejemplos concretos y criterios verificables.
- En sistemas heredados, el comportamiento actual se documenta y protege antes de corregirse.
- Toda afirmación importante debe tener evidencia: código, datos, tests o decisión del negocio.
- Las specs se organizan por dominio de negocio, no por fichero o capa técnica.
- Los cambios de comportamiento se realizan mediante decisiones documentadas y deltas, no de forma implícita.
- El material está redactado principalmente en español de España; los ejemplos fijan también sus propios idiomas, monedas y contextos.

## Estado y alcance

- Hay 48 archivos fuente: 47 prompts/configuraciones y 1 skill con sus metadatos e instrucciones, además de este README. El inventario se compone de archivos `.txt`, `.yaml` y `.md`.
- No hay código de producción, dependencias instalables, comandos de arranque ni suite de tests para ejecutar en este repositorio.
- Los comandos `/speckit-*` y `/opsx:*` son instrucciones para el flujo de trabajo de especificación; no son scripts locales incluidos aquí.
- Los documentos describen proyectos de ejemplo distintos. No deben interpretarse como una única aplicación ni como un contrato técnico común.

## Observaciones para quien use el material

Algunos prompts son deliberadamente borradores o ejercicios y contienen decisiones abiertas, erratas o tensiones que deben resolverse durante la especificación. Por ejemplo, el material de PresupuestosPro mezcla en distintos puntos euro/dólar y España/Venezuela, y deja preguntas sobre redondeo, logo y primer uso. Esas inconsistencias son parte del ejercicio: deben detectarse con las preguntas de clarificación antes de construir.

## Herramientas mencionadas

La documentación hace referencia a Git, GitHub Spec Kit, OpenSpec y worktrees. La referencia completa y actualizada de GitHub Spec Kit está en [`github spec kit/github spec kit.md`](<github spec kit/github spec kit.md>) e incluye comandos de terminal, comandos del agente para Codex, el flujo SDD, extensiones de bugs e ideas, integraciones, presets, workflows y bundles.

La secuencia mínima de inicialización es:

```text
specify init --here --force --integration codex
specify extension add git
```

La skill de [`spec-audit`](<SKILLs/spec-audit/SKILL.md>) es solo de auditoría: informa sobre divergencias entre especificaciones y código, pero no corrige specs, código ni tests.
