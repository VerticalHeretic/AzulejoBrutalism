local palettes = {
  light = {
    bg = "#F3F0E8", -- glaze
    bg_alt = "#E8E4D9", -- sidebars, floats, cursorline
    surface = "#DEDAD0",
    fg = "#0C1030", -- ink
    fg_dim = "#3D4163",
    muted = "#5A5E78",
    faint = "#8A8DA3",
    grout = "#0C1030",
    primary = "#1E2A9E", -- cobalt
    on_primary = "#F3F0E8",
    wash = "#9FB2E4",
    wash_tile = "#D6DAE7",
    ochre = "#D49A1A",
    yellow = "#8F6200",
    red = "#B03A2E",
    green = "#2F6B3A",
    purple = "#6B2E80",
    teal = "#1D6E7E",
    add_bg = "#DCE6D6",
    del_bg = "#F0D6CF",
    change_bg = "#DDE2EF",
    ansi = {
      "#0C1030", "#B03A2E", "#2F6B3A", "#8F6200", "#1E2A9E", "#6B2E80", "#1D6E7E", "#D8D4C8",
      "#5A5E78", "#C8513F", "#3E8A4C", "#B07A0C", "#3A48C4", "#8A48A0", "#2A8C9E", "#E8E4D9",
    },
  },
  dark = {
    bg = "#0C1030", -- ink
    bg_alt = "#10154A",
    surface = "#1A2150",
    fg = "#F3F0E8", -- glaze
    fg_dim = "#C9CBE0",
    muted = "#8A8FB5",
    faint = "#5A5F88",
    grout = "#1E2A9E",
    primary = "#9FB2E4", -- wash stands in for cobalt, which vanishes on ink
    on_primary = "#0C1030",
    wash = "#1E2A9E",
    wash_tile = "#1E2A9E",
    ochre = "#D49A1A",
    yellow = "#D49A1A",
    red = "#E0705A",
    green = "#7CBF7A",
    purple = "#C08AD6",
    teal = "#6FC3CF",
    add_bg = "#16304A",
    del_bg = "#3A1A3A",
    change_bg = "#1A2466",
    ansi = {
      "#141B6B", "#E0705A", "#7CBF7A", "#D49A1A", "#9FB2E4", "#C08AD6", "#6FC3CF", "#D8D4C8",
      "#6E7399", "#F08C78", "#98D496", "#E8B84A", "#C3CFF2", "#D6A8E6", "#94D8E2", "#F3F0E8",
    },
  },
}

-- OLED: Dark with true black behind everything; surfaces sink one step toward black.
palettes.oled = vim.tbl_extend("force", palettes.dark, {
  bg = "#000000",
  bg_alt = "#07091F",
  surface = "#0C1030",
  on_primary = "#000000",
  ansi = vim.list_extend({ "#0C1030" }, vim.list_slice(palettes.dark.ansi, 2)),
})

return palettes
