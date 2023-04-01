local M = {}
local options = require("nvchad_ui.config").options
local utils = require "nvchad_ui.colors.utils"
local statusline = require "nvchad_ui.colors.statusline"
local tbline = require "nvchad_ui.colors.tbline"
local nvdash = require "nvchad_ui.colors.nvdash"
local nvcheatsheet = require "nvchad_ui.colors.nvcheatsheet"
local renamer = require "nvchad_ui.colors.renamer"
local g = vim.g

g.toggle_theme_icon = "   "
g.base46_cache = vim.fn.stdpath "data" .. "/nvchad/base46/"

M.load_all_highlights = function()
  statusline.apply_highlights(options.statusline.theme)
  tbline.apply_highlights()
  nvdash.apply_highlights()
  nvcheatsheet.apply_highlights()
  renamer.apply_highlights()
  ---@type table<string, table<string, any>>
  local groups = vim.tbl_extend(
    "keep",
    statusline[options.statusline.theme],
    tbline.highlights,
    nvdash.highlights,
    nvcheatsheet.highlights,
    renamer.highlights
  )
  utils.load(groups)
  utils.saveStr_to_cache(groups)
end

M.toggle_theme = function()
  local themes = options.theme_toggle
  if themes == nil or #themes < 2 then
    g.toggle_theme_icon = g.toggle_theme_icon == "   " and "   " or "   "
    vim.notify("Set two themes in theme_toggle option in plugin setup", vim.log.levels.WARN)
    return
  end
  if g.toggle_theme_icon == "   " then
    vim.cmd.colorscheme(themes[2])
    g.toggle_theme_icon = "   "
  else
    vim.cmd.colorscheme(themes[1])
    g.toggle_theme_icon = "   "
  end
end

---check if we can use lualine colors
---@return boolean
M.can_use_lualine = function()
  return statusline.can_use_lualine
end

---Lazylaod on startup from cache
M.load_on_startup = function()
  if not vim.loop.fs_stat(vim.g.base46_cache) then
    vim.fn.mkdir(vim.g.base46_cache, "p")
    M.load_all_highlights()
    return
  end
  dofile(g.base46_cache .. "default")
end

return M
