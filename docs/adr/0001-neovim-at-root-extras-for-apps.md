# Neovim plugin at the repo root, every other app under `extras/`

The repo is laid out as a standard Neovim colorscheme plugin (`colors/`, `lua/azulejo-brutalism/` at the root) so it installs directly with lazy.nvim, and every other app's theme lives in `extras/<app>/`, following the tokyonight convention. We rejected keeping flat per-app folders (Neovim would need a manual copy step) and splitting Neovim into its own repo (two places to keep the palette in sync).

## Consequences

- The Zed extension registry entry must point at `path = "extras/zed"` from the next Zed release onward; `extras/zed/LICENSE` stays because Zed requires it inside the extension directory.
- Obsidian's community theme registry expects `theme.css` and `manifest.json` at the repo root, so listing the Obsidian theme there would need its own repo or a root-level exception.
- Neovim is no longer handled by `install.sh`; users who copied the old `colors/azulejo-brutalism.lua` into their config must delete it, or it shadows the plugin.
