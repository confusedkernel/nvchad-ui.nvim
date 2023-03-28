local M = {}

-- From https://github.com/nvim-lualine/lualine.nvim/blob/master/lua/lualine/utils/utils.lua#L11
-- Note for now only works for termguicolors scope can be bg or fg or any other
-- attr parameter like bold/italic/reverse
---@param color_group string hl_group name
---@param scope       string bg | fg | sp
---@return table|string returns #rrggbb formatted color when scope is specified
----                       or complete color table when scope isn't specified
function M.extract_highlight_colors(color_group, scope)
  local color = vim.api.nvim_get_hl_by_name(color_group, true)
  if color.background ~= nil then
    color.bg = string.format("#%06x", color.background)
    color.background = nil
  end
  if color.foreground ~= nil then
    color.fg = string.format("#%06x", color.foreground)
    color.foreground = nil
  end
  if color.special ~= nil then
    color.sp = string.format("#%06x", color.special)
    color.special = nil
  end
  if scope then
    return color[scope]
  end
  return color
end

M.sep = package.config:sub(1, 1)

local is_valid_filename = require("nvchad_ui.util").is_valid_filename

--- From https://github.com/nvim-lualine/lualine.nvim/blob/master/lua/lualine/utils/loader.lua#L212
---loads a theme from lua module
---prioritizes external themes (from user config or other plugins) over the bundled ones
---@param theme_name string
---@return table theme definition from module
local function Load_theme(theme_name)
  if not is_valid_filename(theme_name) then
    error "Invalid FileName for lualine theme"
  end
  local retval = {}
  local path = table.concat { "lua/lualine/themes/", theme_name, ".lua" }
  local files = vim.api.nvim_get_runtime_file(path, true)
  if #files <= 0 then
    path = table.concat { "lua/lualine/themes/", theme_name, "/init.lua" }
    files = vim.api.nvim_get_runtime_file(path, true)
  end
  local n_files = #files
  if n_files == 0 then
    -- No match found
    error(path .. " Not found")
  elseif n_files == 1 then
    -- when only one is found run that and return it's return value
    retval = dofile(files[1])
  else
    -- put entries from user config path in front
    local user_config_path = vim.fn.stdpath "config"
    table.sort(files, function(a, b)
      return vim.startswith(a, user_config_path) or not vim.startswith(b, user_config_path)
    end)
    -- More then 1 found . Use the first one that isn't in lualines repo
    local lualine_repo_pattern = table.concat({ "lualine.nvim", "lua", "lualine" }, M.sep)
    local file_found = false
    for _, file in ipairs(files) do
      if not file:find(lualine_repo_pattern) then
        retval = dofile(file)
        file_found = true
        break
      end
    end
    if not file_found then
      -- This shouldn't happen but somehow we have multiple files but they
      -- apear to be in lualines repo . Just run the first one
      retval = dofile(files[1])
    end
  end
  return retval
end

---Get lualine colors from current theme
---@return table<"normal" | "insert" | "command" | "visual" | "replace" | "terminal" | "inactive",table< "a" | "b" | "c", {fg? : string, bg? : string, bold? : boolean}>>
M.get_lualine_colors = function()
  local color_name = vim.g.colors_name
  if color_name then
    -- All base16 colorschemes share the same theme
    if "base16" == color_name:sub(1, 6) then
      color_name = "base16"
    end
    -- Check if there's a theme for current colorscheme
    -- If there is load that instead of generating a new one
    local ok, theme = pcall(Load_theme, color_name)
    if ok and theme then
      return theme
    end
  end
  return {}
end

--- A function to convert a hex color string to RGB values
---@param hex string
---@return integer, integer, integer
local function hex2rgb(hex)
  -- Remove the hash symbol if present
  hex = hex:gsub("#", "")
  -- Convert the hex digits to numbers
  local r = tonumber(hex:sub(1, 2), 16)
  local g = tonumber(hex:sub(3, 4), 16)
  local b = tonumber(hex:sub(5, 6), 16)
  -- Return the RGB values
  return r, g, b
end

--- A function to convert RGB values to a hex color string
---@param r integer
---@param g integer
---@param b integer
---@return string
local function rgb2hex(r, g, b)
  -- Clamp the RGB values to the range [0,255]
  r = math.min(math.max(r, 0), 255)
  g = math.min(math.max(g, 0), 255)
  b = math.min(math.max(b, 0), 255)
  -- Convert the numbers to hex digits
  local rh = string.format("%02x", r)
  local gh = string.format("%02x", g)
  local bh = string.format("%02x", b)
  -- Concatenate the hex digits with a hash symbol
  local hex = "#" .. rh .. gh .. bh
  -- Return the hex color string
  return hex
end

--- A function to mix two colors by averaging their RGB values
---@param color1 string
---@param color2 string
---@return string
local function mixColors(color1, color2)
  -- Convert the colors from hex to RGB
  local r1, g1, b1 = hex2rgb(color1)
  local r2, g2, b2 = hex2rgb(color2)
  -- Calculate the average of each channel
  local r3 = (r1 + r2) / 2
  local g3 = (g1 + g2) / 2
  local b3 = (b1 + b2) / 2
  -- Convert the result from RGB to hex
  local color3 = rgb2hex(r3, g3, b3)
  -- Return the mixed color
  return color3
end

--- A function that takes red and yellow colors and returns orange color
---@param red string
---@param yellow string
---@return string
M.getOrangeColor = function(red, yellow)
  -- Mix red and yellow colors using the mixColors function
  local orange = mixColors(red, yellow)
  -- Return the orange color
  return orange
end

return M
