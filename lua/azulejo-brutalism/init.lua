-- Azulejo Brutalism: Ink on Glaze (light) / Glaze on Ink (dark), Cobalt primary, Ochre as the one highlight.
-- Follows `background`, so `:set background=dark|light` (or the terminal's appearance) switches variant.

local M = {}

---@class AzulejoBrutalismConfig
---@field dark_variant? "dark"|"oled" variant used when `background` is dark
---@field transparent? boolean leave the editor background to the terminal
---@field on_colors? fun(colors: table) tweak the palette before highlights are built
---@field on_highlights? fun(highlights: table, colors: table) tweak highlight groups before they are applied
local defaults = {
  dark_variant = "dark",
  transparent = false,
  on_colors = function() end,
  on_highlights = function() end,
}

M.config = vim.deepcopy(defaults)

---@param opts? AzulejoBrutalismConfig
function M.setup(opts)
  M.config = vim.tbl_deep_extend("force", vim.deepcopy(defaults), opts or {})
  if M.config.dark_variant ~= "dark" and M.config.dark_variant ~= "oled" then
    vim.notify(
      ("azulejo-brutalism: unknown dark_variant %q, using \"dark\""):format(tostring(M.config.dark_variant)),
      vim.log.levels.WARN
    )
    M.config.dark_variant = "dark"
  end
end

function M.load()
  local config = M.config
  local variant = vim.o.background == "light" and "light" or config.dark_variant
  local c = vim.deepcopy(require("azulejo-brutalism.palette")[variant])
  config.on_colors(c)

  vim.cmd("highlight clear")
  if vim.fn.exists("syntax_on") == 1 then vim.cmd("syntax reset") end
  vim.g.colors_name = "azulejo-brutalism"
  vim.o.termguicolors = true

  for i, color in ipairs(c.ansi) do
    vim.g["terminal_color_" .. (i - 1)] = color
  end

  local groups = require("azulejo-brutalism.groups")(c)
  if config.transparent then
    -- NormalNC links to Normal, so it follows.
    for _, name in ipairs({ "Normal", "SignColumn", "FoldColumn", "EndOfBuffer" }) do
      groups[name].bg = "NONE"
    end
  end
  config.on_highlights(groups, c)

  for name, spec in pairs(groups) do
    vim.api.nvim_set_hl(0, name, spec)
  end

  -- Re-apply when the background flips (e.g. Ghostty switching with macOS appearance).
  vim.api.nvim_create_autocmd("OptionSet", {
    group = vim.api.nvim_create_augroup("AzulejoBrutalism", { clear = true }),
    pattern = "background",
    callback = function()
      if vim.g.colors_name == "azulejo-brutalism" then vim.cmd.colorscheme("azulejo-brutalism") end
    end,
  })
end

return M
