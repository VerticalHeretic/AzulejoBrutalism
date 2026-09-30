#!/usr/bin/env bash
# Installs the Azulejo Brutalism extras (themes for apps other than Neovim; Neovim is a plugin, see README).
#   ./install.sh                 all tools
#   ./install.sh zed ghostty     only the named tools (noteplan, ghostty, kitty, herdr, zed, fastfetch, xcode, vscode, jetbrains, obsidian)
#   ./install.sh --oled ...      use the true-black OLED variant wherever Dark would be set
# Theme files are copied, so re-run after editing them here. Config files that get edited
# (Ghostty, kitty, Herdr, Zed, Fastfetch) are backed up next to themselves as <file>.bak first.
set -euo pipefail

REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG="${XDG_CONFIG_HOME:-$HOME/.config}"
DARK="Azulejo Brutalism Dark"

say() { printf '\033[1;34m%s\033[0m %s\n' "$1" "$2"; }
skip() { printf '\033[2m%s skipped: %s\033[0m\n' "$1" "$2"; }

install_noteplan() {
  local dest="$HOME/Library/Containers/co.noteplan.NotePlan3/Data/Library/Application Support/co.noteplan.NotePlan3/Themes"
  [[ -d "$dest" ]] || { skip noteplan "NotePlan themes folder not found"; return; }
  cp "$REPO"/extras/noteplan/*.json "$dest/"
  say noteplan "themes copied; pick them in NotePlan → Settings → Themes"
}

install_ghostty() {
  local dir="$CONFIG/ghostty" config="$CONFIG/ghostty/config"
  local line="theme = dark:\"$DARK\",light:\"Azulejo Brutalism Light\""
  [[ -d "$dir" ]] || { skip ghostty "$dir not found"; return; }
  mkdir -p "$dir/themes"
  cp "$REPO"/extras/ghostty/Azulejo* "$dir/themes/"
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

install_kitty() {
  local dir="$CONFIG/kitty" dark=dark mode src dest
  [[ -d "$dir" ]] || { skip kitty "$dir not found"; return; }
  [[ "$DARK" == *OLED ]] && dark=oled
  mkdir -p "$dir/themes"
  cp "$REPO"/extras/kitty/*.conf "$dir/themes/"
  # kitty picks {light,dark}-theme.auto.conf from the OS appearance; no-preference is left alone.
  for mode in light dark; do
    src="$REPO/extras/kitty/azulejo-brutalism-light.conf"
    [[ $mode == dark ]] && src="$REPO/extras/kitty/azulejo-brutalism-$dark.conf"
    dest="$dir/$mode-theme.auto.conf"
    if [[ -f "$dest" ]] && ! cmp -s "$src" "$dest"; then cp "$dest" "$dest.bak"; fi
    cp "$src" "$dest"
  done
  say kitty "themes installed and set to follow the system appearance; restart kitty"
}

install_herdr() {
  local config="$CONFIG/herdr/config.toml"
  command -v herdr >/dev/null || { skip herdr "herdr not installed"; return; }
  mkdir -p "$(dirname "$config")" && touch "$config"
  local new
  new="$(mktemp)"
  # Drop every existing [theme] / [theme.*] table, then put ours where the first one was (or at the end).
  local src="$REPO/extras/herdr/theme.toml"
  [[ "$DARK" == *OLED ]] && src="$REPO/extras/herdr/theme-oled.toml"
  awk -v theme="$src" '
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
  skip nvim "Neovim is now a plugin; install it with your plugin manager (see README)"
}

install_zed() {
  local dir="$CONFIG/zed" settings="$CONFIG/zed/settings.json"
  local line="\"theme\": { \"mode\": \"system\", \"light\": \"Azulejo Brutalism Light\", \"dark\": \"$DARK\" },"
  [[ -d "$dir" ]] || { skip zed "$dir not found"; return; }
  mkdir -p "$dir/themes"
  cp "$REPO/extras/zed/themes/azulejo-brutalism.json" "$dir/themes/"
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
  cp "$REPO/extras/fastfetch/azulejo.txt" "$dir/"
  if [[ -f "$dir/config.jsonc" ]] && ! cmp -s "$REPO/extras/fastfetch/config.jsonc" "$dir/config.jsonc"; then
    cp "$dir/config.jsonc" "$dir/config.jsonc.bak"
  fi
  cp "$REPO/extras/fastfetch/config.jsonc" "$dir/"
  say fastfetch "logo and config installed; run fastfetch"
}

install_xcode() {
  local dir="$HOME/Library/Developer/Xcode/UserData/FontAndColorThemes"
  [[ -d "$HOME/Library/Developer/Xcode" ]] || { skip xcode "Xcode user data not found"; return; }
  mkdir -p "$dir"
  cp "$REPO"/extras/xcode/*.xccolortheme "$dir/"
  # Xcode rewrites its preferences on quit, so only switch themes while it is closed.
  if pgrep -x Xcode >/dev/null; then
    say xcode "themes installed; pick them in Settings → Themes (Light and Dark tabs)"
  else
    defaults write com.apple.dt.Xcode XCFontAndColorCurrentTheme "Azulejo Brutalism Light.xccolortheme"
    defaults write com.apple.dt.Xcode XCFontAndColorCurrentDarkTheme "$DARK.xccolortheme"
    say xcode "themes installed and set for Light and Dark"
  fi
}

install_vscode() {
  local name="verticalheretic.azulejo-brutalism-0.1.0" found=0 dir
  for dir in "$HOME/.vscode/extensions" "$HOME/.cursor/extensions"; do
    [[ -d "$dir" ]] || continue
    rm -rf "${dir:?}/$name"
    cp -R "$REPO/extras/vscode" "$dir/$name"
    found=1
    say vscode "extension installed in $dir"
  done
  [[ $found -eq 1 ]] || { skip vscode "no VS Code or Cursor extensions folder"; return; }
  say vscode 'restart, then set "workbench.preferredLightColorTheme"/"preferredDarkColorTheme" and "window.autoDetectColorScheme": true'
}

install_jetbrains() {
  # Android Studio (Google/) and other JetBrains IDEs keep per-version config dirs; install into each.
  local found=0 dir
  shopt -s nullglob
  for dir in "$HOME/Library/Application Support/Google/AndroidStudio"* "$HOME/Library/Application Support/JetBrains/"*/; do
    [[ -d "$dir" ]] || continue
    mkdir -p "$dir/colors"
    cp "$REPO"/extras/jetbrains/*.icls "$dir/colors/"
    found=1
    say jetbrains "schemes installed in ${dir%/}"
  done
  shopt -u nullglob
  [[ $found -eq 1 ]] || { skip jetbrains "no Android Studio or JetBrains IDE config found"; return; }
  say jetbrains "restart, then pick them in Settings → Editor → Color Scheme"
}

install_obsidian() {
  local registry="$HOME/Library/Application Support/obsidian/obsidian.json" found=0 vault
  [[ -f "$registry" ]] || { skip obsidian "no Obsidian vaults found"; return; }
  # Every vault Obsidian knows about; themes and snippets are per vault.
  while IFS= read -r vault; do
    [[ -d "$vault/.obsidian" ]] || continue
    local theme="$vault/.obsidian/themes/Azulejo Brutalism" appearance="$vault/.obsidian/appearance.json"
    mkdir -p "$theme" "$vault/.obsidian/snippets"
    cp "$REPO/extras/obsidian/manifest.json" "$REPO/extras/obsidian/theme.css" "$theme/"
    cp "$REPO/extras/obsidian/snippets/azulejo-brutalism-oled.css" "$vault/.obsidian/snippets/"
    found=1
    # Obsidian rewrites appearance.json while open, so only switch themes while it is closed.
    if pgrep -x Obsidian >/dev/null; then
      say obsidian "theme installed in $vault; pick it in Settings → Appearance → Themes"
      continue
    fi
    [[ -f "$appearance" ]] || echo '{}' >"$appearance"
    cp "$appearance" "$appearance.bak"
    plutil -replace cssTheme -string "Azulejo Brutalism" "$appearance"
    if [[ "$DARK" == *OLED ]]; then
      plutil -extract enabledCssSnippets json -o /dev/null "$appearance" 2>/dev/null ||
        plutil -replace enabledCssSnippets -json '[]' "$appearance"
      grep -qF '"azulejo-brutalism-oled"' "$appearance" ||
        plutil -insert enabledCssSnippets -json '"azulejo-brutalism-oled"' -append "$appearance"
    else
      # plutil has left the file on one line, so the entry can be cut out textually.
      sed -i '' -e 's/"azulejo-brutalism-oled",\{0,1\}//' -e 's/,]/]/' "$appearance"
    fi
    say obsidian "theme installed and set in $vault"
  done < <(grep -o '"path":"[^"]*"' "$registry" | sed 's/^"path":"//; s/"$//')
  [[ $found -eq 1 ]] || skip obsidian "no Obsidian vaults found"
}

tools=()
for arg in "$@"; do
  if [[ "$arg" == --oled ]]; then DARK="Azulejo Brutalism OLED"; else tools+=("$arg"); fi
done
[[ ${#tools[@]} -eq 0 ]] && tools=(noteplan ghostty kitty herdr zed fastfetch xcode vscode jetbrains obsidian)
for tool in "${tools[@]}"; do
  case "$tool" in
    noteplan | ghostty | kitty | herdr | nvim | zed | fastfetch | xcode | vscode | jetbrains | obsidian) "install_$tool" ;;
    *) echo "unknown tool: $tool (expected noteplan, ghostty, kitty, herdr, zed, fastfetch, xcode, vscode, jetbrains, obsidian)" >&2; exit 1 ;;
  esac
done
