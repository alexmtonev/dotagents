#!/usr/bin/env bash
# Update CLI-managed skills, then link every skill in skills/ over them.
# upstream/<name> holds the last upstream version seen for each override,
# so an upstream change is shown as a diff (and shows up in git status).
set -euo pipefail
REPO="$(cd "$(dirname "$0")" && pwd)"
AGENTS="$HOME/.agents/skills"

npx -y skills@latest update -g -y

for src in "$REPO"/skills/*/; do
  src="${src%/}"; name="$(basename "$src")"
  dest="$AGENTS/$name"; snap="$REPO/upstream/$name"

  if [ -L "$dest" ]; then
    [ "$(readlink "$dest")" = "$src" ] && continue
    rm "$dest"
  elif [ -d "$dest" ]; then
    # A real dir here is a fresh CLI copy of upstream.
    if [ ! -d "$snap" ]; then
      echo "Recording upstream baseline for $name"
      cp -R "$dest" "$snap"
    elif ! diff -rq "$snap" "$dest" >/dev/null; then
      echo "⚠ Upstream changed '$name' (your override still applies). Upstream diff:"
      diff -ru "$snap" "$dest" || true
      rm -rf "$snap"; cp -R "$dest" "$snap"
    fi
    rm -rf "$dest"
  fi

  ln -s "$src" "$dest"
  echo "Linked $name"
  link="$HOME/.claude/skills/$name"
  [ -e "$link" ] || [ -L "$link" ] || ln -s "../../.agents/skills/$name" "$link"
done
