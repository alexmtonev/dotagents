---
name: dotagents
description: Change the user's own agent setup through their dotagents repo. Use when updating skills, adding or removing a skill, or editing a skill, CLAUDE.md or Claude Code settings.
---

The setup lives in `~/Dev/Config/dotagents`; `~/.agents/skills` and `~/.claude` hold its outputs. Read its `AGENTS.md` first, then:

- **Update**: `git pull` in the repo, then `./update.sh`.
- **Add or remove a third-party skill**: the CLI command in `AGENTS.md`.
- **Edit a skill or setting**: edit the repo copy, then `./update.sh`. To customise a third-party skill, first copy `~/.agents/skills/<name>` into `skills/`.

Your shell has no terminal, so `update.sh` takes each prompt's default and prints `→ <default> (no terminal)`. The run is done when every such line and every ⚠ diff has been shown to the user, with the other choice offered (keep mine / take upstream; repo / local), and any repo change is committed and pushed.
