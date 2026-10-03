# Azulejo Brutalism

Color scheme/theme for different tools, created by love for Brutalism and Azulejo tilework.

## Install

```sh
./install.sh                 # all tools
./install.sh nvim ghostty    # only some: noteplan, ghostty, herdr, nvim, zed, fastfetch, xcode, vscode, jetbrains, obsidian
./install.sh --oled          # true-black OLED variant instead of Dark
```

**OLED** is Dark with a pure `#000000` background and near-black surfaces; accents are unchanged. With `--oled` the script sets it as the dark theme in Ghostty, Herdr, Zed, Xcode, Neovim (via `vim.g.azulejo_brutalism_oled = true`) and Obsidian (via the `azulejo-brutalism-oled` CSS snippet). In NotePlan, VS Code and JetBrains, pick "Azulejo Brutalism OLED" yourself.

Re-run after editing a theme. Edited configs are backed up as `*.bak`.

- **NotePlan:** choose the Light and Dark themes in Settings → Themes.
- **Ghostty:** reload the config with ⌘⇧,
- **Herdr:** the script reloads it for you.
- **Neovim:** becomes LazyVim's colorscheme on the next start.
- **Zed:** switches right away and follows the system appearance.
- **Fastfetch:** run `fastfetch`; the tile uses the terminal's blue and yellow.
- **Xcode:** set automatically if Xcode is closed; otherwise pick them in Settings → Themes.
- **VS Code / Cursor:** restart, then choose Azulejo Brutalism Light/Dark as the preferred light and dark themes.
- **Obsidian:** installed into every vault Obsidian knows about, and set if Obsidian is closed; otherwise pick it in Settings → Appearance → Themes. For OLED, turn on the `azulejo-brutalism-oled` CSS snippet. Or install it from the community themes (Settings → Appearance → Themes → Manage); the theme lives in [azulejo-brutalism-obsidian](https://github.com/VerticalHeretic/azulejo-brutalism-obsidian), a submodule here.
- **Android Studio / JetBrains:** restart, then pick the scheme in Settings → Editor → Color Scheme (or import the `.icls` from `jetbrains/`).

## NotePlan

| Light                                        | Dark                                       |
| -------------------------------------------- | ------------------------------------------ |
| ![NotePlan Light](embeddings/noteplan-light.png) | ![NotePlan Dark](embeddings/noteplan-dark.png) |


## Obsidian

Source and options (OLED, uppercase labels, heading rules via Style Settings): [azulejo-brutalism-obsidian](https://github.com/VerticalHeretic/azulejo-brutalism-obsidian).

| Light                                  | Dark                                 |
| -------------------------------------- | ------------------------------------ |
| ![Obsidian Light](https://github.com/user-attachments/assets/0753852c-f9ae-4c26-b4d2-41e55ebd8b47) | ![Obsidian Dark](https://github.com/user-attachments/assets/41b560a1-aa61-49dd-851f-fd1aabab4303) |

## Ghostty + Herdr

| Light                                  | Dark                                 |
| -------------------------------------- | ------------------------------------ |
| ![Herdr Light](embeddings/herdr-light.png) | ![Herdr Dark](embeddings/herdr-dark.png) |

## Neovim

| Light                                  | Dark                                 |
| -------------------------------------- | ------------------------------------ |
| ![Neovim Light](embeddings/nvim-light.png) | ![Neovim Dark](embeddings/nvim-dark.png) |

## Zed

| Light                              | Dark                             |
| ---------------------------------- | -------------------------------- |
| ![Zed Light](embeddings/zed-light.png) | ![Zed Dark](embeddings/zed-dark.png) |

## Fastfetch

| Light                                          | Dark                                         |
| ---------------------------------------------- | -------------------------------------------- |
| ![Fastfetch Light](embeddings/fastfetch-light.png) | ![fastfetch Dark](embeddings/fastfetch-dark.png) |

## Xcode

| Light                                  | Dark                                 |
| -------------------------------------- | ------------------------------------ |
| ![Xcode Light](embeddings/xcode-light.png) | ![Xcode Dark](embeddings/xcode-dark.png) |

