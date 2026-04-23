# Rufino

An Obsidian vault memory system and automated note processor powered by Claude Code.

## What is Rufino?

Rufino has two parts:

1. **Conversational memory** -- Claude Code reads and writes to an Obsidian vault across sessions. It remembers your preferences, project context, decisions, and anything valuable that comes up in conversation.

2. **Automated note processor** -- You drop raw notes (`.md` files) into a `rufino/` folder inside your vault. Every day at 19:00 local time, a cron job processes them: detects which project and sub-area (arista) they belong to, assigns a type, analyzes, enriches with context, finds connections to other notes, and organizes them into `rufino/<project>/<type>/` subdirectories. Tags are generated across **4 axes**: `proyecto/<name>/<arista>`, `tema/<broad>`, `persona/<name>`, and `concepto/<specific>`. Action items are extracted into `_pendientes.md` with rich metadata (proyecto/arista, personas, deadline, origin). People mentioned in notes are registered in individual files under `_people/<name>.md`, indexed in `_people.md`.

3. **Web dashboard (optional)** -- A Next.js app that runs as a LaunchAgent daemon on `localhost:3737`. Always-on UI over the vault: captures notes/todos/people, lists processed notes with filters, full detail view with a structured field-by-field editor, project memory, todo management. Lives in `dashboard/` inside this repo.

## What gets installed

| Component | Location | Purpose |
|-----------|----------|---------|
| Obsidian vault | Your chosen directory | Your personal knowledge base |
| `obsidian-memory` rule | `~/.claude/rules/common/` | Claude reads vault at conversation start |
| `rufino` rule | `~/.claude/rules/common/` | Claude knows how to search processed notes |
| `rufino-daily` prompt | `~/.claude/prompts/` | Full processing instructions for the daily run |
| `/remember` command | `~/.claude/commands/` | Save information to the vault during conversations |
| Memory check hook | `~/.claude/hooks/` | Reminds Claude to save valuable info before closing |
| Cron script | `~/.claude/scripts/` | Wrapper that runs the daily processor |
| Cron job | User crontab | Triggers daily processing at 19:00 local time |
| Dashboard (optional) | `dashboard/` in this repo + LaunchAgent | Local web UI at http://localhost:3737 |

## Prerequisites

- **macOS** (tested on macOS 14+)
- **Claude Code CLI** installed and authenticated (`npm install -g @anthropic-ai/claude-code`)
- **jq** (usually pre-installed on macOS; if not: `brew install jq`)
- **Node.js 20+** (only if you install the dashboard; check with `node -v`, install via [nodejs.org](https://nodejs.org) or `brew install node`)

## Installation

1. Clone this repo:
   ```bash
   git clone https://github.com/valentinoerrandonea/rufino-mac.git
   cd rufino-mac
   ```

2. Open Claude Code:
   ```bash
   claude
   ```

3. Say:
   ```
   instalá esto
   ```

Claude reads the `CLAUDE.md` file and does everything. It will ask you:
- Where to create the vault (default: `~/Documents/vault/`)
- Your name (for personalizing the profile)
- Your preferred language for notes (default: Spanish)

That's it. Installation takes about a minute.

## How to use

### Drop notes for processing

Create any `.md` file in the `rufino/` folder of your vault:

```bash
echo "# Meeting notes\nDiscussed the new API design..." > ~/Documents/vault/rufino/meeting-api.md
```

At 19:00, Rufino processes it automatically: detects the project and type, adds tags, a structured summary, analysis, context, and connections to other notes. The processed note gets moved to `rufino/<project>/<type>/`. The index and tag index are updated.

### Manual processing

In any Claude Code session:

```
procesá rufino ahora
```

### Save memories during conversations

Claude automatically detects valuable information and saves it. You can also explicitly say:

```
recordá que prefiero TypeScript sobre JavaScript
```

Or use the command:

```
/remember
```

### Query your notes

Ask Claude anything about your notes:

```
qué decisiones tomé sobre la base de datos?
buscá en mis notas algo sobre autenticación
resumí las notas de esta semana
```

## Vault structure

```
vault/
├── perfil.md              # Your profile
├── preferencias.md        # Your work preferences
├── stack.md               # Your tech stack
├── _meta/
│   ├── design.md          # System design docs
│   └── projectPaths.md    # Maps directories to projects
├── _templates/            # Note templates
├── proyectos/             # Project-specific notes
├── sesiones/              # Session logs
└── rufino/
    ├── _index.md          # Auto-generated index of all notes
    ├── _tags.md           # Auto-generated 4-axis tag index
    ├── _pendientes.md     # Auto-extracted action items with project/arista, personas, deadlines
    ├── _people.md         # Index of people mentioned in notes
    ├── _people/           # Individual file per person (created on first mention)
    ├── _processing-log.md # Log of each processing run
    ├── raw-note.md        # Unprocessed notes (you write these)
    ├── percha/            # Project subdirectories (auto-created)
    │   └── tech/          # Type subdirectories within each project
    │       └── processed-note.md
    └── general/           # Notes not tied to a specific project
        └── reflexiones/
            └── another-note.md
```

## Dashboard

The dashboard is a Next.js 16 app that runs as a LaunchAgent daemon. Always live at http://localhost:3737 once installed.

### Features
- Capture views for notes, todos, and people
- Note list with inbox (unprocessed) + filters (search, project, tema, persona, concepto), grouped by project
- Note detail with the processed augmentation and a **structured field-by-field editor** (edit raw body, Resumen, Análisis, Implicaciones, Preguntas abiertas, Próximos pasos as separate fields — title/tags/Context/Connections stay read-only and preserved byte-for-byte on save)
- Todos with 3-state checkbox (`[ ]` → `[/]` → `[x]`), filters, and atomic updates to `_pendientes.md`
- People directory with per-person detail
- Project memory: overview, decisiones, aprendizajes, notas, todos and people involved
- Theme toggle (light/dark) and accent color picker

### Install via Claude Code

Inside `claude` in the repo root, say `instalá esto` — the installer will ask if you want the dashboard. Answer yes and it handles everything.

### Install manually

```bash
cd dashboard
npm install
npm run build
cd ..

bash configs/scripts/install-dashboard.sh "$(pwd)/dashboard" "<YOUR_VAULT_PATH>"
```

The install script:
1. Verifies Node 20+
2. Runs `npm install` and `npm run build` in `dashboard/`
3. Writes a LaunchAgent plist to `~/Library/LaunchAgents/com.rufino.dashboard.plist` with your vault path and port 3737 baked in
4. Loads the agent with `launchctl` so the daemon starts now and on every boot
5. Polls http://localhost:3737 to confirm it's responding

### Updating the dashboard

After editing anything under `dashboard/`:

```bash
cd dashboard
npm run build
launchctl kickstart -k gui/$(id -u)/com.rufino.dashboard
```

The daemon runs the production build (`next start`), so code changes only take effect after rebuild + kickstart — there's no hot reload.

### Logs

```bash
tail -f ~/rufino-dashboard.log ~/rufino-dashboard.err.log
```

### Uninstall dashboard only

```bash
launchctl unload ~/Library/LaunchAgents/com.rufino.dashboard.plist
rm ~/Library/LaunchAgents/com.rufino.dashboard.plist
```

## Optional: Obsidian

For the best experience browsing and navigating your notes, install [Obsidian](https://obsidian.md) and open your vault folder as an Obsidian vault. The wikilinks, tags, and graph view work out of the box.

This is optional -- the system works entirely from the command line.

## Uninstalling

Remove the installed files:

```bash
# Remove Claude Code configs
rm -f ~/.claude/rules/common/obsidian-memory.md
rm -f ~/.claude/rules/common/rufino.md
rm -f ~/.claude/prompts/rufino-daily.md
rm -f ~/.claude/commands/remember.md
rm -f ~/.claude/hooks/obsidianMemoryCheck.sh
rm -f ~/.claude/scripts/rufino-cron.sh

# Remove cron job
crontab -l | grep -v "rufino-cron" | crontab -

# Remove dashboard (if installed)
launchctl unload ~/Library/LaunchAgents/com.rufino.dashboard.plist 2>/dev/null
rm -f ~/Library/LaunchAgents/com.rufino.dashboard.plist

# Remove hook from settings.json (manual edit)
# Open ~/.claude/settings.json and remove the Stop hook entry
```

Your vault is NOT deleted. Remove it manually if you want.

## License

MIT
