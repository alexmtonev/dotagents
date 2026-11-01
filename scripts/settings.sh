#!/usr/bin/env bash
# Apply settings/dotclaude/* to ~/.claude, asking when local and repo disagree.
set -euo pipefail
REPO="$(cd "$(dirname "$0")/.." && pwd)"
DIR="$REPO/settings/dotclaude"
. "$REPO/scripts/lib.sh"

# settings.json is merged: objects recursively (second file wins on conflicts),
# arrays unioned, so permissions Claude Code added locally survive. Keys are never removed.
MERGE='
  def merge($a; $b):
    if ($a|type) == "object" and ($b|type) == "object" then
      reduce ($b|keys_unsorted[]) as $k ($a; .[$k] = merge(.[$k]; $b[$k]))
    elif ($a|type) == "array" and ($b|type) == "array" then $a + ($b - $a)
    else $b end;
  merge(.[0]; .[1])'
src="$DIR/settings.json"
dest="$HOME/.claude/settings.json"
[ -f "$dest" ] || echo '{}' > "$dest"

repo_wins="$(jq -s "$MERGE" "$dest" "$src")"
if [ "$repo_wins" = "$(jq . "$dest")" ]; then
  echo "settings.json up to date"
else
  echo "⚠ Applying the repo's settings.json would change local:"
  diff -u <(jq . "$dest") <(echo "$repo_wins") || true
  ask "  [a]pply repo, [k]eep local values (and save them to the repo), [s]kip?" "a/k/s" a
  case $REPLY in
    a) echo "$repo_wins" > "$dest"; echo "  Applied" ;;
    k) local_wins="$(jq -s "$MERGE" "$src" "$dest")"
       echo "$local_wins" > "$src"; echo "$local_wins" > "$dest"
       echo "  Saved local values into the repo (commit it)" ;;
    s) echo "  Skipped" ;;
  esac
fi

# These are copied whole.
for name in CLAUDE.md statusline.sh; do
  src="$DIR/$name"
  dest="$HOME/.claude/$name"
  if cmp -s "$src" "$dest"; then
    echo "$name up to date"
    continue
  fi
  if [ ! -f "$dest" ]; then
    cp -p "$src" "$dest"
    echo "Copied $name"
    continue
  fi
  echo "⚠ Local $name differs from the repo."
  while :; do
    ask "  [r]epo wins, [l]ocal wins (save it to the repo), [d]iff, [s]kip?" "r/l/d/s" r
    case $REPLY in
      d) diff -u "$dest" "$src" || true ;;
      r) cp "$dest" "$dest.bak.$(date +%Y%m%d%H%M%S)"; cp -p "$src" "$dest"
         echo "  Copied repo version (local backed up)"; break ;;
      l) cp -p "$dest" "$src"; echo "  Saved local into the repo (commit it)"; break ;;
      s) echo "  Skipped"; break ;;
    esac
  done
done
