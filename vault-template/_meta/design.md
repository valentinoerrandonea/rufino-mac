---
tags:
  - tipo/meta
created: {{DATE}}
updated: {{DATE}}
---

# Vault Design

## Estructura

Este vault sirve como memoria persistente para Claude Code. Tiene dos funciones:

1. **Memoria conversacional** — Claude lee y escribe notas durante sesiones para recordar contexto entre conversaciones.
2. **Procesador Rufino** — Notas crudas en `rufino/` se procesan automáticamente: se categorizan, analizan, enriquecen y organizan.

## Directorios

| Directorio | Propósito |
|-----------|-----------|
| `_meta/` | Archivos de sistema (este archivo, mapeo de paths) |
| `_templates/` | Templates para crear notas nuevas |
| `proyectos/` | Un subdirectorio por proyecto con overview, decisiones, aprendizajes |
| `sesiones/` | Resúmenes de sesiones largas |
| `rufino/` | Notas crudas (raíz) y procesadas (subdirectorios por categoría) |

## Taxonomía de tags

- `tipo/` — Qué tipo de nota: perfil, preferencia, stack, decision, aprendizaje, feedback, sesion, meta, overview
- `proyecto/` — A qué proyecto pertenece
- `tema/` — Tema conceptual: auth, db, deploy, ai, arquitectura, etc.
- `estado/` — Estado: activo, archivado, pendiente

## Convenciones

- Archivos en minúsculas, separados por guiones
- Frontmatter YAML obligatorio con tags, created, updated
- Wikilinks para conectar notas: `[[nombre-archivo]]`
- Nunca linkear a archivos inexistentes

## Vault path

`{{VAULT_PATH}}`
