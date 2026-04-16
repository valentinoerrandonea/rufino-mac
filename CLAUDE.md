# Rufino — Instalador para macOS

Este archivo contiene las instrucciones completas para instalar Rufino. Claude Code lee este archivo y ejecuta todo automáticamente.

---

## Qué es Rufino

Rufino es un sistema de memoria personal basado en un vault de Obsidian. Tiene dos componentes:

1. **Memoria conversacional** — Claude recuerda cosas entre sesiones escribiendo notas en el vault.
2. **Procesador de notas** — Una carpeta `rufino/` donde el usuario tira notas crudas. Un cron job diario las procesa: detecta el proyecto y tipo, analiza, enriquece con contexto, y las organiza automáticamente en `rufino/<proyecto>/<tipo>/`. También actualiza `_index.md`, `_tags.md`, `_pendientes.md` (action items extraídos automáticamente), y `_people.md` (directorio de personas mencionadas en las notas).

---

## Instrucciones de instalación

Cuando el usuario diga "instalá esto", "install this", o cualquier variación, ejecutá los siguientes pasos EN ORDEN.

### Paso 0: Preguntas iniciales

Hacé estas preguntas y esperá las respuestas antes de continuar:

1. **"¿Dónde querés que se cree el vault de Obsidian?"** — Sugerí como default `~/Documents/vault/`. Aceptá cualquier path válido. Si el usuario dice "dale" o similar, usá el default.
2. **"¿Cuál es tu nombre?"** — Para personalizar `perfil.md`. Si el usuario no quiere dar nombre, usá "Usuario".
3. **"¿En qué idioma preferís las notas?"** — Default: español. Opciones: español, english, portugués.

Guardá las respuestas en variables mentales:
- `VAULT_PATH` = la ruta elegida (expandir `~` a `$HOME`)
- `USER_NAME` = el nombre
- `LANG_PREF` = el idioma
- `DATE` = fecha de hoy en formato YYYY-MM-DD

### Paso 1: Detectar timezone

```bash
TIMEZONE=$(readlink /etc/localtime | sed 's|.*/zoneinfo/||')
echo "Timezone detectado: $TIMEZONE"
```

Guardá el timezone para calcular el cron después.

### Paso 2: Crear el vault

Creá el directorio del vault si no existe:

```bash
mkdir -p "$VAULT_PATH"
```

Copiá toda la estructura de `vault-template/` al vault. Para cada archivo:
- Reemplazá `{{VAULT_PATH}}` con el path real del vault
- Reemplazá `{{USER_NAME}}` con el nombre del usuario
- Reemplazá `{{DATE}}` con la fecha de hoy (YYYY-MM-DD)

Archivos a copiar:
- `vault-template/_meta/design.md` → `$VAULT_PATH/_meta/design.md`
- `vault-template/_meta/projectPaths.md` → `$VAULT_PATH/_meta/projectPaths.md`
- `vault-template/perfil.md` → `$VAULT_PATH/perfil.md`
- `vault-template/preferencias.md` → `$VAULT_PATH/preferencias.md`
- `vault-template/stack.md` → `$VAULT_PATH/stack.md`
- `vault-template/rufino/_index.md` → `$VAULT_PATH/rufino/_index.md`
- `vault-template/rufino/_tags.md` → `$VAULT_PATH/rufino/_tags.md`
- `vault-template/rufino/_processing-log.md` → `$VAULT_PATH/rufino/_processing-log.md`
- `vault-template/rufino/_pendientes.md` → `$VAULT_PATH/rufino/_pendientes.md`
- `vault-template/rufino/_people.md` → `$VAULT_PATH/rufino/_people.md`

Creá los directorios vacíos:
```bash
mkdir -p "$VAULT_PATH/_templates"
mkdir -p "$VAULT_PATH/proyectos"
mkdir -p "$VAULT_PATH/sesiones"
mkdir -p "$VAULT_PATH/rufino"
```

**IMPORTANTE**: Si el vault ya existe y tiene archivos, NO sobreescribas archivos existentes. Solo copiá los que falten. Avisá al usuario qué archivos ya existían y se saltearon.

### Paso 3: Instalar regla obsidian-memory

```bash
mkdir -p ~/.claude/rules/common
```

Leé el archivo `configs/rules/obsidian-memory.md` de este repo. Reemplazá `{{VAULT_PATH}}` con el path real. Escribilo en `~/.claude/rules/common/obsidian-memory.md`.

### Paso 4: Instalar regla rufino

Leé el archivo `configs/rules/rufino.md` de este repo. Reemplazá `{{VAULT_PATH}}` con el path real. Escribilo en `~/.claude/rules/common/rufino.md`.

### Paso 5: Instalar prompt rufino-daily

```bash
mkdir -p ~/.claude/prompts
```

Leé el archivo `configs/prompts/rufino-daily.md` de este repo. Reemplazá `{{VAULT_PATH}}` con el path real. Escribilo en `~/.claude/prompts/rufino-daily.md`.

### Paso 6: Instalar comando /remember

```bash
mkdir -p ~/.claude/commands
```

Leé el archivo `configs/commands/remember.md` de este repo. Reemplazá `{{VAULT_PATH}}` con el path real. Escribilo en `~/.claude/commands/remember.md`.

### Paso 7: Instalar hook de memoria

```bash
mkdir -p ~/.claude/hooks
```

Copiá `configs/hooks/obsidianMemoryCheck.sh` a `~/.claude/hooks/obsidianMemoryCheck.sh`. Hacelo ejecutable:

```bash
chmod +x ~/.claude/hooks/obsidianMemoryCheck.sh
```

### Paso 8: Configurar el hook en settings.json

Leé el archivo `~/.claude/settings.json` existente (si existe). Mergeá la siguiente configuración SIN sobreescribir lo que ya exista:

```json
{
  "hooks": {
    "Stop": [
      {
        "hooks": [
          {
            "type": "command",
            "command": "$HOME/.claude/hooks/obsidianMemoryCheck.sh",
            "timeout": 30
          }
        ]
      }
    ]
  }
}
```

Si `settings.json` ya tiene una sección `hooks`, agregá el hook de Stop sin borrar los hooks existentes. Si ya existe un hook de Stop, agregá este al array sin duplicar.

### Paso 9: Instalar script del cron

```bash
mkdir -p ~/.claude/scripts
```

Leé `configs/scripts/rufino-cron.sh`. Reemplazá `{{VAULT_PATH}}` con el path real. Escribilo en `~/.claude/scripts/rufino-cron.sh`. Hacelo ejecutable:

```bash
chmod +x ~/.claude/scripts/rufino-cron.sh
```

### Paso 10: Configurar el cron job

Detectá el timezone del usuario y calculá qué hora UTC corresponde a las 19:00 local.

Ejemplo: si el timezone es `America/Argentina/Buenos_Aires` (UTC-3), 19:00 local = 22:00 UTC.

Agregá la entrada al crontab del usuario. Primero verificá si ya existe:

```bash
crontab -l 2>/dev/null | grep -q "rufino-cron" && echo "Cron ya existe" || (crontab -l 2>/dev/null; echo "0 <HORA_UTC> * * * $HOME/.claude/scripts/rufino-cron.sh") | crontab -
```

Reemplazá `<HORA_UTC>` con la hora calculada.

### Paso 11: Verificar instalación

Verificá que todo esté en su lugar:

```bash
echo "=== Verificación de instalación ==="
echo ""
echo "Vault:"
[ -d "$VAULT_PATH" ] && echo "  ✓ Vault existe en $VAULT_PATH" || echo "  ✗ Vault NO encontrado"
[ -f "$VAULT_PATH/perfil.md" ] && echo "  ✓ perfil.md" || echo "  ✗ perfil.md falta"
[ -f "$VAULT_PATH/preferencias.md" ] && echo "  ✓ preferencias.md" || echo "  ✗ preferencias.md falta"
[ -f "$VAULT_PATH/stack.md" ] && echo "  ✓ stack.md" || echo "  ✗ stack.md falta"
[ -f "$VAULT_PATH/rufino/_index.md" ] && echo "  ✓ rufino/_index.md" || echo "  ✗ rufino/_index.md falta"
[ -f "$VAULT_PATH/rufino/_tags.md" ] && echo "  ✓ rufino/_tags.md" || echo "  ✗ rufino/_tags.md falta"
[ -f "$VAULT_PATH/rufino/_pendientes.md" ] && echo "  ✓ rufino/_pendientes.md" || echo "  ✗ rufino/_pendientes.md falta"
[ -f "$VAULT_PATH/rufino/_people.md" ] && echo "  ✓ rufino/_people.md" || echo "  ✗ rufino/_people.md falta"
[ -d "$VAULT_PATH/_meta" ] && echo "  ✓ _meta/" || echo "  ✗ _meta/ falta"
echo ""
echo "Claude Code configs:"
[ -f "$HOME/.claude/rules/common/obsidian-memory.md" ] && echo "  ✓ regla obsidian-memory" || echo "  ✗ regla obsidian-memory falta"
[ -f "$HOME/.claude/rules/common/rufino.md" ] && echo "  ✓ regla rufino" || echo "  ✗ regla rufino falta"
[ -f "$HOME/.claude/prompts/rufino-daily.md" ] && echo "  ✓ prompt rufino-daily" || echo "  ✗ prompt rufino-daily falta"
[ -f "$HOME/.claude/commands/remember.md" ] && echo "  ✓ comando /remember" || echo "  ✗ comando /remember falta"
[ -x "$HOME/.claude/hooks/obsidianMemoryCheck.sh" ] && echo "  ✓ hook obsidianMemoryCheck (ejecutable)" || echo "  ✗ hook obsidianMemoryCheck falta o no es ejecutable"
[ -x "$HOME/.claude/scripts/rufino-cron.sh" ] && echo "  ✓ script rufino-cron (ejecutable)" || echo "  ✗ script rufino-cron falta o no es ejecutable"
echo ""
echo "Cron:"
crontab -l 2>/dev/null | grep -q "rufino-cron" && echo "  ✓ Cron job configurado" || echo "  ✗ Cron job NO encontrado"
echo ""
echo "=== Fin de verificación ==="
```

### Paso 12: Mensaje final

Mostrá este mensaje al usuario:

> **Instalación completa.**
>
> Tu vault está en `<VAULT_PATH>`.
>
> **Cómo usar Rufino:**
> - Escribí notas en `<VAULT_PATH>/rufino/` — cualquier archivo `.md` que dejes ahí se procesa automáticamente.
> - Se procesan todos los días a las 19:00 (hora local).
> - En cualquier sesión de Claude Code, podés decir "procesá rufino ahora" para ejecutar manualmente.
> - Usá `/remember` para guardar algo en el vault durante una conversación.
> - Claude va a leer tu vault automáticamente al inicio de cada conversación para tener contexto.
>
> **Recomendación:** Para una mejor experiencia navegando tus notas, instalá [Obsidian](https://obsidian.md) y abrí la carpeta `<VAULT_PATH>` como un vault de Obsidian. Es opcional pero recomendado.

---

## Notas técnicas

- Todos los archivos de configuración usan `{{VAULT_PATH}}` como placeholder. Durante la instalación, reemplazá TODAS las ocurrencias con el path real.
- Los archivos del vault template usan `{{DATE}}` (reemplazar con YYYY-MM-DD) y `{{USER_NAME}}` (reemplazar con el nombre del usuario).
- El hook `obsidianMemoryCheck.sh` usa un flag en `/tmp/` para que solo se ejecute una vez por sesión. Le recuerda a Claude guardar información valiosa antes de cerrar.
- El cron job ejecuta Claude Code en modo no interactivo con el prompt de procesamiento diario.
- Si el usuario ya tiene un vault existente, no sobreescribir archivos. Solo agregar los que falten.
- La regla `obsidian-memory.md` hace que Claude lea el vault al inicio de cada conversación.
- La regla `rufino.md` hace que Claude sepa buscar en las notas procesadas cuando el usuario pregunta cosas.
