#!/bin/bash
# Claude Code status line: model | dir ⎇ branch | context tokens
input=$(cat)

model=$(jq -r '.model.display_name // "?"' <<<"$input")
dir=$(jq -r '.workspace.current_dir // .cwd // ""' <<<"$input")
branch=$(git -C "$dir" branch --show-current 2>/dev/null)
dir=${dir/#$HOME/\~}

read -r used size pct <<<"$(jq -r '[
  .context_window.total_input_tokens // 0,
  .context_window.context_window_size // 0,
  .context_window.used_percentage // 0
] | @tsv' <<<"$input")"

ctx=$(awk -v u="$used" -v s="$size" -v p="$pct" 'BEGIN{
  c = (p >= 80) ? "31" : (p >= 60) ? "33" : "32"
  printf "\033[%sm%.1fk/%dk (%.0f%%)\033[0m", c, u/1000, s/1000, p
}')

printf '\033[2m%s | %s%s |\033[0m %s' "$model" "$dir" "${branch:+ ⎇ $branch}" "$ctx"
