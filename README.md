# dotagents

My agent skills and Claude Code settings. Clone it and run one command to bring a machine in line:

```sh
git clone git@github.com:alexmtonev/dotagents.git ~/Dev/Config/dotagents
~/Dev/Config/dotagents/update.sh
```

Run `./update.sh` again whenever you pull, edit something here, or want the latest third-party skills. When nothing needs a decision it runs straight through, and running it twice changes nothing.

## What `./update.sh` does

It runs two scripts in order. It only stops to ask when local and repo disagree; pressing Enter picks the default shown in brackets. Without a terminal (e.g. piped), the defaults are used.

### 1. `scripts/skills.sh`: third-party skills, with mine on top

1. Runs `npx skills update -g -y`, which updates every skill installed with the [`skills` CLI](https://github.com/vercel-labs/skills) (e.g. mattpocock/skills) into `~/.agents/skills/`.
2. For each folder in `skills/`, replaces `~/.agents/skills/<name>` with a symlink to it. If a third-party skill has the same name, mine wins. If none does, it's simply added.

The chain Claude Code follows looks like this:

```
~/.claude/skills/grilling → ~/.agents/skills/grilling → ~/Dev/Config/dotagents/skills/grilling
```

Edits in `skills/` take effect immediately; there is no copy step.

When the CLI updates a skill I've overridden, it deletes my symlink and puts its own copy back. The script notices (see `upstream/` below) and asks:

- **k**eep mine (default): restore my link.
- **t**ake upstream: copy the new upstream version into `skills/<name>`, then link it.
- **d**iff: show what upstream changed since last time.
- **m**ine vs upstream: show how my version differs from the new upstream.

### 2. `scripts/settings.sh`: Claude Code settings

Files live in `settings/dotclaude/` and go into `~/.claude/`:

| File | How it's applied |
|---|---|
| `settings.json` | Merged into the local file: lists such as `permissions.allow` are combined, and keys that exist only locally are kept. If the merge would change local, it shows the diff and asks: **a**pply repo (default; repo wins on conflicts), **k**eep local values (local wins, and the result is saved to the repo too), or **s**kip. A merge never removes a key, so delete one by hand. |
| `CLAUDE.md` | Copied. If the local copy differs, it asks: **r**epo wins (default; local backed up to `CLAUDE.md.bak.<timestamp>`), **l**ocal wins (saved to the repo), **d**iff, or **s**kip. |
| `statusline.sh` | Copied, the same way as `CLAUDE.md`. This is the script `settings.json` runs to draw Claude Code's status line. |

Settings for one machine only go in `~/.claude/settings.local.json`, which this repo never touches.

## `upstream/`

For each skill I've overridden, `upstream/<name>` holds the last third-party version the script saw. It is committed.

It exists because once my symlink replaces the CLI's copy, the original is gone, so there would be nothing to compare against. When the CLI drops in a new version, `scripts/skills.sh` compares it with `upstream/<name>`. If they differ, it asks what to do (above) and saves the new version there. The change then shows in `git status` until I merge anything I want into `skills/<name>` and commit.

Never edit `upstream/` by hand.

## Layout

```
update.sh              runs everything below
scripts/skills.sh      CLI update, then symlinks skills/*
scripts/settings.sh    applies settings/dotclaude/*
scripts/lib.sh         shared helpers (the ask prompt)
skills/<name>/         my skills and overrides
upstream/<name>/       last-seen third-party version of each override
settings/dotclaude/    Claude Code files (other harnesses get their own folder)
```
