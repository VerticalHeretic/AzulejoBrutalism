# Azulejo Brutalism

Color scheme/theme for different tools, created by love for Brutalism and Azulejo tilework.

Every theme comes in three variants: **Light**, **Dark** and **OLED** (Dark with a pure `#000000` background and near-black surfaces; accents are unchanged).

## Neovim

| Light                                  | Dark                                 |
| -------------------------------------- | ------------------------------------ |
| ![Neovim Light](embeddings/nvim-light.png) | ![Neovim Dark](embeddings/nvim-dark.png) |

### Install

[lazy.nvim](https://github.com/folke/lazy.nvim):

```lua
{
  "VerticalHeretic/AzulejoBrutalism",
  lazy = false,
  priority = 1000,
  opts = {},
  config = function(_, opts)
    require("azulejo-brutalism").setup(opts)
    vim.cmd.colorscheme("azulejo-brutalism")
  end,
}
```

[LazyVim](https://www.lazyvim.org), e.g. in `~/.config/nvim/lua/plugins/azulejo-brutalism.lua`:

```lua
return {
  { "VerticalHeretic/AzulejoBrutalism", lazy = false, priority = 1000, opts = {} },
  { "LazyVim/LazyVim", opts = { colorscheme = "azulejo-brutalism" } },
}
```

Any other plugin manager: install `VerticalHeretic/AzulejoBrutalism`, then

```lua
require("azulejo-brutalism").setup({}) -- optional
vim.cmd.colorscheme("azulejo-brutalism")
```

The colorscheme follows `background`, so `:set background=light|dark` (or your terminal's appearance) switches between Light and the dark variant.

### Options

Defaults shown; `setup()` only stores options, `:colorscheme azulejo-brutalism` applies them.

```lua
require("azulejo-brutalism").setup({
  -- Variant used when `background` is dark: "dark" or "oled".
  dark_variant = "dark",
  -- Leave the editor background to the terminal (floats and sidebars keep theirs).
  transparent = false,
  -- Tweak the palette before highlights are built.
  on_colors = function(colors) end,
  -- Tweak highlight groups before they are applied.
  on_highlights = function(highlights, colors) end,
})
```

### Migrating from the copied colorscheme

Earlier versions had `./install.sh nvim` copy the colorscheme into your config. To switch to the plugin:

1. Delete `~/.config/nvim/colors/azulejo-brutalism.lua`. Your config comes first in the runtimepath, so this file shadows the plugin and you would never get updates.
2. Replace `~/.config/nvim/lua/plugins/azulejo-brutalism.lua` with the LazyVim spec above.
3. If you installed with `--oled` (or set `vim.g.azulejo_brutalism_oled`), use `opts = { dark_variant = "oled" }` instead; the global is no longer read.

## Extras

Themes for other apps live in [`extras/`](extras). Install them with the script:

```sh
./install.sh                 # all tools
./install.sh zed ghostty     # only some: noteplan, ghostty, kitty, herdr, zed, fastfetch, xcode, vscode, jetbrains, obsidian
./install.sh --oled          # true-black OLED variant instead of Dark
```

With `--oled` the script sets OLED as the dark theme in Ghostty, kitty, Herdr, Zed, Xcode and Obsidian (via the `azulejo-brutalism-oled` CSS snippet). In NotePlan, VS Code and JetBrains, pick "Azulejo Brutalism OLED" yourself.

Re-run after editing a theme. Edited configs are backed up as `*.bak`.

- **NotePlan:** choose the Light and Dark themes in Settings → Themes.
- **Ghostty:** reload the config with ⌘⇧,
- **kitty:** restart kitty; it follows the system appearance via `light-theme.auto.conf` / `dark-theme.auto.conf`. The themes are also listed in `kitten themes`, or `include` a `.conf` from `extras/kitty/` yourself.
- **Herdr:** the script reloads it for you.
- **Zed:** switches right away and follows the system appearance.
- **Fastfetch:** run `fastfetch`; the tile uses the terminal's blue and yellow.
- **Xcode:** set automatically if Xcode is closed; otherwise pick them in Settings → Themes.
- **VS Code / Cursor:** restart, then choose Azulejo Brutalism Light/Dark as the preferred light and dark themes.
- **Obsidian:** installed into every vault Obsidian knows about, and set if Obsidian is closed; otherwise pick it in Settings → Appearance → Themes. For OLED, turn on the `azulejo-brutalism-oled` CSS snippet.
- **Android Studio / JetBrains:** restart, then pick the scheme in Settings → Editor → Color Scheme (or import the `.icls` from `extras/jetbrains/`).

### NotePlan

| Light                                        | Dark                                       |
| -------------------------------------------- | ------------------------------------------ |
| ![NotePlan Light](embeddings/noteplan-light.png) | ![NotePlan Dark](embeddings/noteplan-dark.png) |

### Obsidian

| Light                                  | Dark                                 |
| -------------------------------------- | ------------------------------------ |
| ![Obsidian Light](https://github.com/user-attachments/assets/0753852c-f9ae-4c26-b4d2-41e55ebd8b47) | ![Obsidian Dark](https://github.com/user-attachments/assets/41b560a1-aa61-49dd-851f-fd1aabab4303) |

### Ghostty + Herdr

| Light                                  | Dark                                 |
| -------------------------------------- | ------------------------------------ |
| ![Herdr Light](embeddings/herdr-light.png) | ![Herdr Dark](embeddings/herdr-dark.png) |

### Zed

| Light                              | Dark                             |
| ---------------------------------- | -------------------------------- |
| ![Zed Light](embeddings/zed-light.png) | ![Zed Dark](embeddings/zed-dark.png) |

### Fastfetch

| Light                                          | Dark                                         |
| ---------------------------------------------- | -------------------------------------------- |
| ![Fastfetch Light](embeddings/fastfetch-light.png) | ![fastfetch Dark](embeddings/fastfetch-dark.png) |

### Xcode

| Light                                  | Dark                                 |
| -------------------------------------- | ------------------------------------ |
| ![Xcode Light](embeddings/xcode-light.png) | ![Xcode Dark](embeddings/xcode-dark.png) |
