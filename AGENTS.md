# dotagents

This repo is the source of truth for my agent skills and Claude Code settings. `~/.agents/skills/<override>`, `~/.claude/settings.json`, `~/.claude/CLAUDE.md` and `~/.claude/statusline.sh` are its outputs: change the repo copy, run `./update.sh`, commit.

Read `README.md` before changing a script or the layout; it is the spec for what `./update.sh` does.

## Conventions

- **Overrides mirror upstream.** `skills/<name>/` keeps the upstream folder's full structure (e.g. `agents/openai.yaml`), changing only what I've edited.
- **`upstream/` is written by `scripts/skills.sh` alone.** It holds the last-seen upstream copy of each override; changes there arrive via a run, never a hand edit.
- **One folder per harness.** `settings/dotclaude/` is Claude Code only; another harness (e.g. pi) gets a sibling folder and its own script called from `update.sh`.
- **Third-party skills go through the CLI**: `npx skills add <source> --skill <name> -g`, without `-y`, which installs for every agent and creates folders such as `~/.kiro`.

## Guardrails

- `~/.agents/skills/` belongs to the `skills` CLI, which wipes and recopies a skill's folder on install. Keep `~/.agents` and `~/.agents/skills` as real directories; if either became a symlink into this repo, installs would write into the repo.

## Testing script changes

A script change is done when a run applies it and a second run changes nothing (idempotent).

Run against a sandbox, never the live home: `HOME=<tmpdir>`, with a stub `npx` first on `PATH` (it skips the network and keeps the run fast). To feed answers to prompts, run under `script -q /dev/null` and pipe answers in with a short `sleep` before each: input sent before a prompt appears is flushed.
