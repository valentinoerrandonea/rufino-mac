# Manual Operativo: /remember

## 1. Flow de escritura

Cuando necesites guardar información en el vault, seguí este flujo:

### 1.1 Determinar tipo de nota

| Tipo | Archivo destino | Cuándo usarlo |
|------|----------------|---------------|
| Perfil | `{{VAULT_PATH}}/perfil.md` | Info sobre el usuario: nombre, rol, background, responsabilidades |
| Preferencia | `{{VAULT_PATH}}/preferencias.md` | Cómo le gusta trabajar, estilo de código, convenciones, comportamiento de Claude |
| Stack | `{{VAULT_PATH}}/stack.md` | Tecnologías, lenguajes, frameworks, herramientas |
| Proyecto overview | `{{VAULT_PATH}}/proyectos/<proyecto>/overview.md` | Contexto de un proyecto: qué es, estado, equipo, stack |
| Decisión | `{{VAULT_PATH}}/proyectos/<proyecto>/decisiones/<nombre>.md` | Decisión técnica o arquitectónica con contexto |
| Aprendizaje | `{{VAULT_PATH}}/proyectos/<proyecto>/aprendizajes/<nombre>.md` | Algo aprendido durante debugging, investigación, o implementación |
| Feedback | `{{VAULT_PATH}}/proyectos/<proyecto>/feedback/<nombre>.md` | Corrección que el usuario hizo, algo que no le gustó |
| Sesión | `{{VAULT_PATH}}/sesiones/<fecha>-<tema>.md` | Resumen de una sesión larga con contexto importante |
| Project paths | `{{VAULT_PATH}}/_meta/projectPaths.md` | Mapeo de directorios a proyectos |

### 1.2 Verificar existencia

Antes de escribir:
1. Verificá si el archivo ya existe (leelo con Read)
2. Si existe, actualizá la sección relevante — NO sobreescribas todo el archivo
3. Si no existe, crealo con la template correspondiente

### 1.3 Escribir la nota

Usá Write o Edit según corresponda. Siempre preservá el contenido existente.

## 2. Reglas de comportamiento

### 2.1 Qué guardar SIEMPRE (sin que te lo pidan)

- Primera mención del nombre, rol, o background del usuario
- Preferencias explícitas ("me gusta X", "no me gusta Y", "siempre hacé Z")
- Correcciones ("no, hacelo así", "eso está mal", "preferí X sobre Y")
- Decisiones técnicas con contexto ("elegimos X porque Y")
- Soluciones no obvias de debugging
- Stack tecnológico mencionado
- Proyectos nuevos detectados por CWD

### 2.2 Qué NO guardar

- Conversación trivial sin valor informativo
- Código específico (guardá la decisión/patrón, no el código entero)
- Información temporal sin valor futuro ("hacé un console.log acá")
- Duplicados de algo que ya está en el vault

### 2.3 Cuándo guardar

- **Inmediatamente** cuando detectás información valiosa — no esperes al final
- **Al detectar un proyecto nuevo** (CWD no está en projectPaths.md)
- **Cuando el usuario dice explícitamente** "recordá esto", "guardá esto", etc.
- **Al final de sesiones largas** con mucho contexto nuevo (el hook te lo recuerda)

### 2.4 Cómo actualizar

- Si la info ya existe pero cambió: buscá la nota, editá la sección relevante
- Si es info nueva sobre algo existente: agregá a la nota existente
- Nunca borres información previa — agregá o actualizá

## 3. Estructura de directorios

```
{{VAULT_PATH}}/
├── perfil.md                    # Perfil del usuario
├── preferencias.md              # Preferencias de trabajo
├── stack.md                     # Stack tecnológico
├── _meta/
│   ├── design.md                # Diseño del sistema del vault
│   └── projectPaths.md          # Mapeo CWD → proyecto
├── _templates/                  # Templates para nuevas notas
├── proyectos/
│   └── <nombre-proyecto>/
│       ├── overview.md          # Contexto del proyecto
│       ├── decisiones/
│       │   └── <nombre>.md      # Decisiones técnicas
│       ├── aprendizajes/
│       │   └── <nombre>.md      # Aprendizajes
│       └── feedback/
│           └── <nombre>.md      # Feedback del usuario
├── sesiones/
│   └── <fecha>-<tema>.md        # Resúmenes de sesión
└── rufino/
    ├── _index.md                # Índice auto-generado
    ├── _processing-log.md       # Log de procesamiento
    └── <categoría>/             # Notas procesadas
        └── <nota>.md
```

## 4. Naming conventions

### 4.1 Archivos

- Minúsculas, separados por guiones: `mi-decision-importante.md`
- Sin espacios, sin caracteres especiales
- Descriptivo pero conciso: `auth-jwt-vs-session.md`, no `decision-1.md`
- Sesiones: `YYYY-MM-DD-tema.md`

### 4.2 Proyectos

- Usar el nombre del repositorio o el nombre corto del proyecto
- Minúsculas: `percha`, `rufino-mac`, `mi-api`

## 5. Taxonomía de tags

### 5.1 Ejes principales

| Eje | Ejemplos | Uso |
|-----|----------|-----|
| `tipo/` | `tipo/decision`, `tipo/aprendizaje`, `tipo/feedback`, `tipo/perfil`, `tipo/preferencia`, `tipo/stack`, `tipo/sesion`, `tipo/meta` | Clasificar qué tipo de nota es |
| `proyecto/` | `proyecto/percha`, `proyecto/rufino` | Asociar a un proyecto |
| `tema/` | `tema/auth`, `tema/db`, `tema/deploy`, `tema/ai`, `tema/arquitectura` | Tema técnico o conceptual |
| `estado/` | `estado/activo`, `estado/archivado`, `estado/pendiente` | Estado actual |

### 5.2 Reglas de tags

- Mínimo 2 tags por nota (tipo + al menos uno más)
- Usar tags existentes antes de crear nuevos
- Tags en minúsculas, sin espacios
- Axis siempre como prefijo: `tipo/`, `proyecto/`, `tema/`, `estado/`

## 6. Templates de notas

### 6.1 Proyecto overview

```markdown
---
tags:
  - tipo/overview
  - proyecto/<nombre>
  - estado/activo
created: YYYY-MM-DD
updated: YYYY-MM-DD
---

# <Nombre del proyecto>

## Qué es
<Descripción en una o dos oraciones>

## Estado
<Estado actual: en desarrollo, producción, idea, etc.>

## Stack
<Tecnologías principales>

## Equipo
<Quién trabaja en esto>

## Decisiones clave
<Links a decisiones importantes>

## Links
<URLs relevantes: repo, deploy, docs>

---
Relacionado: [[perfil]] | [[stack]]
```

### 6.2 Decisión

```markdown
---
tags:
  - tipo/decision
  - proyecto/<nombre>
  - tema/<tema>
created: YYYY-MM-DD
updated: YYYY-MM-DD
---

# <Título de la decisión>

## Contexto
<Por qué surgió esta decisión>

## Opciones consideradas
| Opción | Pros | Contras |
|--------|------|---------|
| A | ... | ... |
| B | ... | ... |

## Decisión
<Qué se eligió y por qué>

## Consecuencias
<Qué implica esta decisión>

---
Relacionado: [[proyectos/<proyecto>/overview]]
```

### 6.3 Aprendizaje

```markdown
---
tags:
  - tipo/aprendizaje
  - proyecto/<nombre>
  - tema/<tema>
created: YYYY-MM-DD
updated: YYYY-MM-DD
---

# <Qué se aprendió>

## Contexto
<Qué estaba pasando cuando surgió>

## Problema
<Qué no funcionaba o qué se descubrió>

## Solución
<Cómo se resolvió>

## Lección
<Qué recordar para la próxima>

---
Relacionado: [[proyectos/<proyecto>/overview]]
```

### 6.4 Feedback

```markdown
---
tags:
  - tipo/feedback
  - proyecto/<nombre>
created: YYYY-MM-DD
updated: YYYY-MM-DD
---

# <Resumen del feedback>

## Qué pasó
<Contexto: qué hizo Claude que generó la corrección>

## Corrección
<Qué dijo el usuario>

## Acción
<Qué cambiar en el comportamiento futuro>

---
Relacionado: [[preferencias]]
```

### 6.5 Sesión

```markdown
---
tags:
  - tipo/sesion
  - proyecto/<nombre>
created: YYYY-MM-DD
updated: YYYY-MM-DD
---

# Sesión: <tema principal>

## Resumen
<Qué se hizo en la sesión>

## Decisiones tomadas
<Lista de decisiones>

## Pendientes
<Qué quedó por hacer>

## Contexto para la próxima sesión
<Qué necesita saber Claude la próxima vez>

---
Relacionado: [[proyectos/<proyecto>/overview]]
```

## 7. Convenciones de wikilinks

- Usar wikilinks de Obsidian: `[[nombre-archivo]]`
- Para archivos en subdirectorios: `[[proyectos/mi-proyecto/overview]]`
- Siempre verificar que el archivo destino EXISTE antes de linkear
- Nunca fabricar links a archivos inexistentes
- Al final de cada nota, agregar una sección `Relacionado:` con links relevantes

## 8. Quick Reference

### Checklist antes de escribir

- [ ] Determiné el tipo de nota correcto
- [ ] Verifiqué si el archivo ya existe
- [ ] Si existe, voy a actualizar (no sobreescribir)
- [ ] El nombre del archivo sigue las convenciones
- [ ] Incluí frontmatter con tags, created, updated
- [ ] Los tags siguen la taxonomía (tipo/, proyecto/, tema/, estado/)
- [ ] Agregué wikilinks a notas relacionadas que EXISTEN
- [ ] La información es valiosa para futuras sesiones

### Checklist al detectar proyecto nuevo

- [ ] Creé `{{VAULT_PATH}}/proyectos/<nombre>/overview.md`
- [ ] Agregué el path a `{{VAULT_PATH}}/_meta/projectPaths.md`
- [ ] Creé directorios: `decisiones/`, `aprendizajes/`, `feedback/`

### Checklist al final de sesión (trigger: hook)

- [ ] ¿Hubo preferencias nuevas? → Actualizar `preferencias.md`
- [ ] ¿Hubo decisiones técnicas? → Crear nota de decisión
- [ ] ¿Hubo correcciones/feedback? → Crear nota de feedback
- [ ] ¿Hubo aprendizajes de debugging? → Crear nota de aprendizaje
- [ ] ¿Se mencionó stack nuevo? → Actualizar `stack.md`
- [ ] ¿Se mencionó info personal nueva? → Actualizar `perfil.md`
