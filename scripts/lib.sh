# Shared helpers for scripts/*.sh.

# ask PROMPT CHOICES DEFAULT — sets REPLY to one of CHOICES ("a/b/c").
# Enter picks DEFAULT; without a terminal, DEFAULT is used.
ask() {
  local prompt=$1 choices=$2 default=$3
  if [ ! -t 0 ]; then
    REPLY=$default
    echo "$prompt → $default (no terminal)"
    return
  fi
  while :; do
    read -rp "$prompt ($default) " REPLY
    REPLY=${REPLY:-$default}
    case "/$choices/" in *"/$REPLY/"*) return ;; esac
  done
}
