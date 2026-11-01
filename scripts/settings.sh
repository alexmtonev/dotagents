#!/usr/bin/env bash
# Merge settings/dotclaude/settings.json into ~/.claude/settings.json.
# Objects merge recursively (repo wins on conflicts); arrays are unioned,
# so permissions Claude Code added locally survive. Keys are never removed.
set -euo pipefail
REPO="$(cd "$(dirname "$0")/.." && pwd)"
dest="$HOME/.claude/settings.json"
[ -f "$dest" ] || echo '{}' > "$dest"

merged="$(jq -s '
  def merge($a; $b):
    if ($a|type) == "object" and ($b|type) == "object" then
      reduce ($b|keys_unsorted[]) as $k ($a; .[$k] = merge(.[$k]; $b[$k]))
    elif ($a|type) == "array" and ($b|type) == "array" then $a + ($b - $a)
    else $b end;
  merge(.[0]; .[1])
' "$dest" "$REPO/settings/dotclaude/settings.json")"

if [ "$merged" = "$(jq . "$dest")" ]; then
  echo "settings.json up to date"
else
  diff -u <(jq . "$dest") <(echo "$merged") || true
  echo "$merged" > "$dest"
  echo "Merged settings.json"
fi

# These are copied from the repo; a drifted local copy is shown and backed up.
for name in CLAUDE.md statusline.sh; do
  src="$REPO/settings/dotclaude/$name"
  dest="$HOME/.claude/$name"
  if cmp -s "$src" "$dest"; then
    echo "$name up to date"
    continue
  fi
  if [ -f "$dest" ]; then
    bak="$dest.bak.$(date +%Y%m%d%H%M%S)"
    echo "⚠ Local $name differs from the repo; backed up to $bak. Diff (local → repo):"
    diff -u "$dest" "$src" || true
    cp "$dest" "$bak"
  fi
  cp -p "$src" "$dest"
  echo "Copied $name"
done
