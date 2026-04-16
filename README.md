# Rufino

An Obsidian vault memory system and automated note processor powered by Claude Code.

## What is Rufino?

Rufino has two parts:

1. **Conversational memory** -- Claude Code reads and writes to an Obsidian vault across sessions. It remembers your preferences, project context, decisions, and anything valuable that comes up in conversation.

2. **Automated note processor** -- You drop raw notes (`.md` files) into a `rufino/` folder inside your vault. Every day at 19:00 local time, a cron job processes them: detects which project they belong to, assigns a type, analyzes, enriches with context, finds connections to other notes, and organizes them into `rufino/<project>/<type>/` subdirectories. The index (`_index.md`) and tag index (`_tags.md`) are updated automatically after each run. Action items are extracted into `_pendientes.md` and people mentioned in notes are registered in `_people.md`.

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

## Prerequisites

- **macOS** (tested on macOS 14+)
- **Claude Code CLI** installed and authenticated (`npm install -g @anthropic-ai/claude-code`)
- **jq** (usually pre-installed on macOS; if not: `brew install jq`)

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
    ├── _tags.md           # Auto-generated tag index
    ├── _pendientes.md     # Auto-extracted action items from notes
    ├── _people.md         # Directory of people mentioned in notes
    ├── _processing-log.md # Log of each processing run
    ├── raw-note.md        # Unprocessed notes (you write these)
    ├── percha/            # Project subdirectories (auto-created)
    │   └── tech/          # Type subdirectories within each project
    │       └── processed-note.md
    └── general/           # Notes not tied to a specific project
        └── reflexiones/
            └── another-note.md
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

# Remove hook from settings.json (manual edit)
# Open ~/.claude/settings.json and remove the Stop hook entry
```

Your vault is NOT deleted. Remove it manually if you want.

## License

MIT
