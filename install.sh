#!/usr/bin/env bash
# Installs the Azulejo Brutalism themes.
#   ./install.sh                 all tools
#   ./install.sh nvim ghostty    only the named tools (noteplan, ghostty, herdr, nvim, zed, fastfetch)
# Theme files are copied, so re-run after editing them here. Config files that get edited
# (Ghostty, Herdr, Zed, Fastfetch) are backed up next to themselves as <file>.bak first.
set -euo pipefail

REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG="${XDG_CONFIG_HOME:-$HOME/.config}"

say() { printf '\033[1;34m%s\033[0m %s\n' "$1" "$2"; }
skip() { printf '\033[2m%s skipped: %s\033[0m\n' "$1" "$2"; }

install_noteplan() {
  local dest="$HOME/Library/Containers/co.noteplan.NotePlan3/Data/Library/Application Support/co.noteplan.NotePlan3/Themes"
  [[ -d "$dest" ]] || { skip noteplan "NotePlan themes folder not found"; return; }
  cp "$REPO"/noteplan/*.json "$dest/"
  say noteplan "themes copied; pick them in NotePlan → Settings → Themes"
}

install_ghostty() {
  local dir="$CONFIG/ghostty" config="$CONFIG/ghostty/config"
  local line='theme = dark:"Azulejo Brutalism Dark",light:"Azulejo Brutalism Light"'
  [[ -d "$dir" ]] || { skip ghostty "$dir not found"; return; }
  mkdir -p "$dir/themes"
  cp "$REPO"/ghostty/Azulejo* "$dir/themes/"
  touch "$config"
  if ! grep -qxF "$line" "$config"; then
    cp "$config" "$config.bak"
    if grep -q '^theme *=' "$config"; then
      sed -i '' "s|^theme *=.*|$line|" "$config"
    else
      printf '%s\n' "$line" >>"$config"
    fi
  fi
  say ghostty "themes installed and set; reload with ⌘⇧,"
}

install_herdr() {
  local config="$CONFIG/herdr/config.toml"
  command -v herdr >/dev/null || { skip herdr "herdr not installed"; return; }
  mkdir -p "$(dirname "$config")" && touch "$config"
  local new
  new="$(mktemp)"
  # Drop every existing [theme] / [theme.*] table, then put ours where the first one was (or at the end).
  awk -v theme="$REPO/herdr/theme.toml" '
    function emit() { while ((getline l < theme) > 0) print l; placed = 1 }
    /^\[/ { in_theme = ($0 ~ /^\[theme(\]|\.)/); if (in_theme && !placed) emit() }
    !in_theme { print }
    END { if (!placed) { print ""; emit() } }
  ' "$config" >"$new"
  if cmp -s "$new" "$config"; then
    rm "$new"
  else
    cp "$config" "$config.bak"
    mv "$new" "$config"
  fi
  herdr config check
  herdr server reload-config >/dev/null 2>&1 || true
  say herdr "theme written to $config"
}

install_nvim() {
  local dir="$CONFIG/nvim"
  [[ -d "$dir" ]] || { skip nvim "$dir not found"; return; }
  mkdir -p "$dir/colors"
  cp "$REPO/nvim/colors/azulejo-brutalism.lua" "$dir/colors/"
  if [[ -f "$dir/lazyvim.json" ]]; then
    mkdir -p "$dir/lua/plugins"
    cp "$REPO/nvim/lua/plugins/azulejo-brutalism.lua" "$dir/lua/plugins/"
    say nvim "colorscheme installed and set as LazyVim's default"
  else
    say nvim "colorscheme installed; add 'colorscheme azulejo-brutalism' to your config"
  fi
}

install_zed() {
  local dir="$CONFIG/zed" settings="$CONFIG/zed/settings.json"
  local line='"theme": { "mode": "system", "light": "Azulejo Brutalism Light", "dark": "Azulejo Brutalism Dark" },'
  [[ -d "$dir" ]] || { skip zed "$dir not found"; return; }
  mkdir -p "$dir/themes"
  cp "$REPO/zed/azulejo-brutalism.json" "$dir/themes/"
  # settings.json is JSONC, so only a one-line "theme" entry is rewritten; anything else is left to you.
  if grep -qF "$line" "$settings" 2>/dev/null; then
    :
  elif grep -qE '^\s*"theme": *(\{[^{}]*\}|"[^"]*"),?\s*$' "$settings" 2>/dev/null; then
    cp "$settings" "$settings.bak"
    sed -i '' -E "s|^([[:space:]]*)\"theme\": *(\{[^{}]*\}\|\"[^\"]*\"),?[[:space:]]*\$|\1$line|" "$settings"
  else
    say zed "theme installed; set it with: $line"
    return
  fi
  say zed "theme installed and set (follows system appearance)"
}

install_fastfetch() {
  local dir="$CONFIG/fastfetch"
  command -v fastfetch >/dev/null || { skip fastfetch "fastfetch not installed"; return; }
  mkdir -p "$dir"
  cp "$REPO/fastfetch/azulejo.txt" "$dir/"
  if [[ -f "$dir/config.jsonc" ]] && ! cmp -s "$REPO/fastfetch/config.jsonc" "$dir/config.jsonc"; then
    cp "$dir/config.jsonc" "$dir/config.jsonc.bak"
  fi
  cp "$REPO/fastfetch/config.jsonc" "$dir/"
  say fastfetch "logo and config installed; run fastfetch"
}

tools=("$@")
[[ ${#tools[@]} -eq 0 ]] && tools=(noteplan ghostty herdr nvim zed fastfetch)
for tool in "${tools[@]}"; do
  case "$tool" in
    noteplan | ghostty | herdr | nvim | zed | fastfetch) "install_$tool" ;;
    *) echo "unknown tool: $tool (expected noteplan, ghostty, herdr, nvim, zed, fastfetch)" >&2; exit 1 ;;
  esac
done
