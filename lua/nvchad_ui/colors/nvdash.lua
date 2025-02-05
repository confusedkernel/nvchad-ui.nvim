local M = {}
local utils = require "nvchad_ui.colors.utils"

M.apply_highlights = function()
  local colors = {
    black = utils.extract_highlight_colors("Normal", "bg"),
    button_bg = utils.extract_highlight_colors("TelescopeNormal", "bg"),
    white = vim.g.terminal_color_7,
    bright_black = vim.g.terminal_color_0,
    special = utils.extract_highlight_colors("Special", "fg"),
  }
  M.highlights = {
    NvDashAscii = {
      fg = colors.black,
      bg = colors.special,
    },

    NvDashButtons = {
      fg = colors.white,
      bg = colors.button_bg,
    },

    NvDashNoiceStats = {
      fg = colors.special,
      bg = colors.black,
    },
  }
end

return M
