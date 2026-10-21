# Quickstart: Página web personal de documentación SDD

## Prerrequisitos

- Windows con PowerShell 5 o superior.
- Un navegador moderno de escritorio o móvil.
- El repositorio completo en la raíz del proyecto.
- Python solo es necesario si se quiere probar la Clipboard API desde `localhost`; no es necesario para leer la página.

## Generar la página

Desde la raíz del repositorio:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\scripts\build-documentation-page.ps1
```

Resultado esperado:

- Se genera o actualiza `index.html`.
- El generador informa el inventario encontrado y confirma que contiene 53 archivos documentales.
- El PDF original permanece en `misc\Claude_Course_Course_-_Prompts_Workflow_2026_.pdf`.

## Validar el inventario y el contenido generado

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\scripts\validate-documentation-page.ps1
```

Resultado esperado:

- Las rutas declaradas existen.
- Los conteos por extensión son 46 `.txt`, 5 `.md`, 1 `.yaml` y 1 `.pdf`.
- `index.html` contiene todas las secciones y los documentos esperados.
- Cada bloque reutilizable tiene texto y un control de copia asociado.

## Abrir la página

Abrir `index.html` directamente en el navegador. La lectura, el índice, la búsqueda y la selección manual deben funcionar.

Para probar la copia automática en un contexto local de confianza, si Python está instalado:

```powershell
py -m http.server 8000
```

Después, abrir `http://localhost:8000/index.html`. Detener el servidor con `Ctrl+C`.

## Escenarios de validación manual

1. **Orientación**: abrir la página, confirmar título, alcance, contadores e índice; abrir una sección y regresar al índice.
2. **Cobertura**: recorrer las ocho secciones y confirmar que cada documento muestra ruta, tipo, explicación y contenido original.
3. **Copia de prompt**: copiar un prompt multilínea con acentos y pegarlo en un editor; comparar saltos de línea y caracteres.
4. **Copia de comando**: copiar un comando de GitHub Spec Kit con parámetros y confirmar que no incluye el título ni la explicación.
5. **Fallback**: abrir directamente con `file://` o bloquear el permiso del portapapeles; confirmar que no aparece “Copiado” falsamente y que el texto sigue seleccionable.
6. **Búsqueda**: buscar `GesFact`, `speckit`, una ruta con espacios y un término inexistente; limpiar el filtro y confirmar que vuelve todo el corpus. Activar «Solo snippets de Claude» y comprobar que solo quedan snippets con la etiqueta Claude, cada uno con su definición; combinarlo con una búsqueda y desactivarlo con «Limpiar búsqueda».
7. **PDF**: abrir y descargar el recurso PDF desde su tarjeta, sin que la página dependa de extraerlo a texto.
8. **Responsive y teclado**: revisar una pantalla estrecha y una ancha; navegar por índice, búsqueda y botones usando teclado y comprobar foco visible.

## Criterio de salida

La feature está lista para la siguiente fase cuando el validador estático pasa, los escenarios 1–8 se pueden completar y el checklist de la spec no presenta regresiones.
