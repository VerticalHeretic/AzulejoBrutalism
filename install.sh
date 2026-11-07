#!/usr/bin/env bash
# Installs the Azulejo Brutalism themes.
#   ./install.sh                 all tools
#   ./install.sh nvim ghostty    only the named tools (noteplan, ghostty, herdr, nvim, zed, fastfetch, xcode, vscode, jetbrains, noctalia, vibe, helix, mitos)
#   ./install.sh --oled ...      use the true-black OLED variant wherever Dark would be set
# Theme files are copied, so re-run after editing them here. Config files that get edited
# (Ghostty, Herdr, Zed, Fastfetch, Vibe) are backed up next to themselves as <file>.bak first.
# Font: JetBrains Mono is set wherever the tool stores it (Ghostty, Zed, Xcode, JetBrains, NotePlan code).
# Install it first: brew install --cask font-jetbrains-mono-nerd-font
set -euo pipefail

REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG="${XDG_CONFIG_HOME:-$HOME/.config}"
DARK="Azulejo Brutalism Dark"
FONT="JetBrainsMono Nerd Font"   # wide, open letterforms; Nerd Font build so Neovim/Vibe icons render in the terminal

say() { printf '\033[1;34m%s\033[0m %s\n' "$1" "$2"; }
skip() { printf '\033[2m%s skipped: %s\033[0m\n' "$1" "$2"; }

# set_kv FILE KEY VALUE: rewrite a "key = value" line, or append it. Backs up FILE once per run.
set_kv() {
  local file="$1" key="$2" line="$2 = $3"
  grep -qxF "$line" "$file" && return
  [[ -f "$file.bak" && "$file.bak" -nt "$file" ]] || cp "$file" "$file.bak"
  if grep -q "^$key *=" "$file"; then
    sed "s|^$key *=.*|$line|" "$file" >"$file.tmp" && mv "$file.tmp" "$file"
  else
    printf '%s\n' "$line" >>"$file"
  fi
}

install_noteplan() {
  local dest="$HOME/Library/Containers/co.noteplan.NotePlan3/Data/Library/Application Support/co.noteplan.NotePlan3/Themes"
  [[ -d "$dest" ]] || { skip noteplan "NotePlan themes folder not found"; return; }
  cp "$REPO"/noteplan/*.json "$dest/"
  say noteplan "themes copied; pick them in NotePlan → Settings → Themes"
}

install_ghostty() {
  local dir="$CONFIG/ghostty" config="$CONFIG/ghostty/config"
  [[ -d "$dir" ]] || { skip ghostty "$dir not found"; return; }
  mkdir -p "$dir/themes"
  cp "$REPO"/ghostty/Azulejo* "$dir/themes/"
  touch "$config"
  set_kv "$config" theme "dark:\"$DARK\",light:\"Azulejo Brutalism Light\""
  set_kv "$config" font-family "\"$FONT\""
  set_kv "$config" adjust-cell-height "10%"
  say ghostty "themes installed and set, font set to $FONT; reload with ⌘⇧,"
}

install_herdr() {
  local config="$CONFIG/herdr/config.toml"
  command -v herdr >/dev/null || { skip herdr "herdr not installed"; return; }
  mkdir -p "$(dirname "$config")" && touch "$config"
  local new
  new="$(mktemp)"
  # Drop every existing [theme] / [theme.*] table, then put ours where the first one was (or at the end).
  local src="$REPO/herdr/theme.toml"
  [[ "$DARK" == *OLED ]] && src="$REPO/herdr/theme-oled.toml"
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
  local dir="$CONFIG/nvim"
  [[ -d "$dir" ]] || { skip nvim "$dir not found"; return; }
  mkdir -p "$dir/colors"
  cp "$REPO/nvim/colors/azulejo-brutalism.lua" "$dir/colors/"
  if [[ -f "$dir/lazyvim.json" ]]; then
    mkdir -p "$dir/lua/plugins"
    cp "$REPO/nvim/lua/plugins/azulejo-brutalism.lua" "$dir/lua/plugins/"
    if [[ "$DARK" == *OLED ]]; then
      sed -i '' 's|^return {|vim.g.azulejo_brutalism_oled = true\n&|' "$dir/lua/plugins/azulejo-brutalism.lua"
    fi
    say nvim "colorscheme installed and set as LazyVim's default"
  else
    say nvim "colorscheme installed; add 'colorscheme azulejo-brutalism' to your config"
  fi
}

install_zed() {
  local dir="$CONFIG/zed" settings="$CONFIG/zed/settings.json"
  local line="\"theme\": { \"mode\": \"system\", \"light\": \"Azulejo Brutalism Light\", \"dark\": \"$DARK\" },"
  [[ -d "$dir" ]] || { skip zed "$dir not found"; return; }
  mkdir -p "$dir/themes"
  cp "$REPO/zed/themes/azulejo-brutalism.json" "$dir/themes/"
  # settings.json is JSONC, so only a one-line "theme" entry is rewritten; anything else is left to you.
  if grep -qF "$line" "$settings" 2>/dev/null; then
    :
  elif grep -qE '^\s*"theme": *(\{[^{}]*\}|"[^"]*"),?\s*$' "$settings" 2>/dev/null; then
    cp "$settings" "$settings.bak"
    sed -i '' -E "s|^([[:space:]]*)\"theme\": *(\{[^{}]*\}\|\"[^\"]*\"),?[[:space:]]*\$|\1$line|" "$settings"
  else
    say zed "theme installed; set it with: $line"
    zed_font "$settings"
    return
  fi
  say zed "theme installed and set (follows system appearance)"
  zed_font "$settings"
}

# Rewrite one-line "buffer_font_family"/"ui_font_family" entries; if neither exists, say how to add them.
zed_font() {
  local settings="$1" key changed=0 missing=0
  for key in buffer_font_family ui_font_family; do
    if grep -qE "^\s*\"$key\": *\"$FONT\",?\s*$" "$settings" 2>/dev/null; then
      :
    elif grep -qE "^\s*\"$key\": *\"[^\"]*\",?\s*$" "$settings" 2>/dev/null; then
      [[ -f "$settings.bak" && "$settings.bak" -nt "$settings" ]] || cp "$settings" "$settings.bak"
      sed -E "s|^([[:space:]]*)\"$key\": *\"[^\"]*\"|\1\"$key\": \"$FONT\"|" "$settings" >"$settings.tmp" && mv "$settings.tmp" "$settings"
      changed=1
    else
      missing=1
    fi
  done
  [[ $changed -eq 1 ]] && say zed "font set to $FONT"
  [[ $missing -eq 1 ]] && say zed "to use the font, add: \"buffer_font_family\": \"$FONT\", \"ui_font_family\": \"$FONT\","
  return 0
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

install_xcode() {
  local dir="$HOME/Library/Developer/Xcode/UserData/FontAndColorThemes"
  [[ -d "$HOME/Library/Developer/Xcode" ]] || { skip xcode "Xcode user data not found"; return; }
  mkdir -p "$dir"
  cp "$REPO"/xcode/*.xccolortheme "$dir/"
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
    cp -R "$REPO/vscode" "$dir/$name"
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
    cp "$REPO"/jetbrains/*.icls "$dir/colors/"
    found=1
    say jetbrains "schemes installed in ${dir%/}"
  done
  shopt -u nullglob
  [[ $found -eq 1 ]] || { skip jetbrains "no Android Studio or JetBrains IDE config found"; return; }
  say jetbrains "restart, then pick them in Settings → Editor → Color Scheme"
}

install_noctalia() {
  command -v noctalia >/dev/null || { skip noctalia "noctalia not installed"; return; }
  local dir="$CONFIG/noctalia" config="$CONFIG/noctalia/config.toml"
  mkdir -p "$dir/palettes"
  cp "$REPO"/noctalia/*.json "$dir/palettes/"
  # Upsert source/custom_palette/pure_black_dark inside [theme], leaving the
  # rest of the config alone (same mktemp pattern as herdr).
  local new oled
  oled=false
  if [[ "$DARK" == *OLED ]]; then oled=true; fi
  new="$(mktemp)"
  awk -v oled="$oled" '
    function flush() {
      if (!done_src) print "source = \"custom\""
      if (!done_pal) print "custom_palette = \"Azulejo Brutalism\""
      if (!done_oled) print "pure_black_dark = " oled
      done_src = done_pal = done_oled = 1
    }
    BEGIN { in_theme = 0; have_theme = 0; done_src = 0; done_pal = 0; done_oled = 0 }
    /^\[theme\]/ { if (in_theme) flush(); in_theme = 1; have_theme = 1; print; next }
    /^\[/ { if (in_theme) flush(); in_theme = 0; print; next }
    in_theme && /^source[ \t]*=/ { print "source = \"custom\""; done_src = 1; next }
    in_theme && /^custom_palette[ \t]*=/ { print "custom_palette = \"Azulejo Brutalism\""; done_pal = 1; next }
    in_theme && /^pure_black_dark[ \t]*=/ { print "pure_black_dark = " oled; done_oled = 1; next }
    { print }
    END { if (in_theme) flush(); else if (!have_theme) { print ""; print "[theme]"; flush() } }
  ' "$config" >"$new"
  if cmp -s "$new" "$config"; then
    rm "$new"
  else
    cp "$config" "$config.bak"
    mv "$new" "$config"
  fi
  noctalia config validate >/dev/null 2>&1 || { skip noctalia "resulting config failed validation"; return; }
  say noctalia "palette installed and set as theme source in $config — applies live"
}

install_helix() {
  local dir="$CONFIG/helix"
  local config="$dir/config.toml"
  [[ -d "$dir" ]] || { skip helix "$dir not found"; return; }
  mkdir -p "$dir/themes"
  cp "$REPO"/helix/*.toml "$dir/themes/"
  # Helix has no light/dark auto-switch, so follow the macOS appearance; --oled forces the true-black variant.
  local theme="azulejo-brutalism-dark"
  if [[ "$DARK" == *OLED ]]; then
    theme="azulejo-brutalism-oled"
  elif [[ "$(defaults read -g AppleInterfaceStyle 2>/dev/null || true)" != "Dark" ]]; then
    theme="azulejo-brutalism-light"
  fi
  local line="theme = \"$theme\""
  touch "$config"
  if ! grep -qxF "$line" "$config"; then
    cp "$config" "$config.bak"
    if grep -q '^theme *=' "$config"; then
      sed -i '' "s|^theme *=.*|$line|" "$config"
    else
      printf '%s\n' "$line" >>"$config"
    fi
  fi
  say helix "themes copied to $dir/themes; $line set in $config — switch anytime with :theme azulejo-brutalism-light|dark|oled"
}

install_mitos() {
  local dir="$CONFIG/mitos"
  local config="$dir/config.toml"
  command -v mitos >/dev/null || [[ -d "$dir" ]] || { skip mitos "mitos not installed"; return; }
  mkdir -p "$dir/themes"
  cp "$REPO"/mitos/*.toml "$dir/themes/"
  # Mitos follows the terminal's light/dark report (mode 2031), so both variants go into a [theme] table.
  # Drop any existing top-level `theme =` key and [theme]/[theme.*] tables, then put ours where the first one was.
  local dark="azulejo-brutalism-dark"
  [[ "$DARK" == *OLED ]] && dark="azulejo-brutalism-oled"
  touch "$config"
  local new
  new="$(mktemp)"
  awk -v dark="$dark" '
    function emit() {
      print "[theme]"
      print "dark = \"" dark "\""
      print "light = \"azulejo-brutalism-light\""
      placed = 1
    }
    /^\[/ { in_theme = ($0 ~ /^\[theme(\]|\.)/); if (in_theme && !placed) emit() }
    !in_theme && $0 !~ /^theme[ \t]*=/ { print }
    END { if (!placed) { print ""; emit() } }
  ' "$config" >"$new"
  if cmp -s "$new" "$config"; then
    rm "$new"
  else
    cp "$config" "$config.bak"
    mv "$new" "$config"
  fi
  say mitos "themes copied to $dir/themes; [theme] table set in $config — switch anytime with :theme azulejo-brutalism-light|dark|oled"
}

install_vibe() {
  # Vibe has no theme-file format: the TUI is Textual, which only accepts its
  # BUILTIN_THEMES. So the theme module is installed into Vibe's Python
  # environment with a .pth hook that registers the themes at startup; they
  # then behave like built-ins (config `theme`, /theme picker).
  command -v vibe >/dev/null || { skip vibe "vibe not installed"; return; }
  local site="" exe bin
  # uv/pipx/etc. launchers point their shebang at the venv python; walk up to its site-packages.
  if exe="$(command -v vibe)"; then
    bin="$(sed -n '1s|^#!||p' "$exe")"
    [[ -x "$bin" ]] && for site in "$(dirname "$(dirname "$bin")")"/lib/python*/site-packages; do
      [[ -d "$site" ]] && break
    done
  fi
  if [[ -z "$site" || ! -d "$site" ]]; then
    for site in "$HOME/.local/share/uv/tools/mistral-vibe"/lib/python*/site-packages "$HOME/.local/pipx/venvs/mistral-vibe"/lib/python*/site-packages; do
      [[ -d "$site" ]] && break
    done
  fi
  [[ -n "$site" && -d "$site" ]] || { skip vibe "could not find Vibe's site-packages (unsupported install method?)"; return; }
  cp "$REPO/vibe/azulejo_brutalism.py" "$site/"
  printf 'import azulejo_brutalism\n' >"$site/azulejo-brutalism.pth"
  # All three variants (light/dark/oled) are registered; --oled picks the dark one to set.
  local theme="azulejo-brutalism-dark"
  [[ "$DARK" == *OLED ]] && theme="azulejo-brutalism-oled"
  local config="$HOME/.vibe/config.toml"
  mkdir -p "$HOME/.vibe" && touch "$config"
  set_kv "$config" theme "\"$theme\""
  say vibe "themes installed into $site; $line set in $config — restart vibe, or pick a variant in /theme"
}

tools=()
for arg in "$@"; do
  if [[ "$arg" == --oled ]]; then DARK="Azulejo Brutalism OLED"; else tools+=("$arg"); fi
done
[[ ${#tools[@]} -eq 0 ]] && tools=(noteplan ghostty herdr nvim zed fastfetch xcode vscode jetbrains noctalia vibe helix mitos)
for tool in "${tools[@]}"; do
  case "$tool" in
    noteplan | ghostty | herdr | nvim | zed | fastfetch | xcode | vscode | jetbrains | noctalia | vibe | helix | mitos) "install_$tool" ;;
    *) echo "unknown tool: $tool (expected noteplan, ghostty, herdr, nvim, zed, fastfetch, xcode, vscode, jetbrains, noctalia, vibe, helix, mitos)" >&2; exit 1 ;;
  esac
done
