-- lua/clion_dracula/palettes.lua
local colors = require("clion_dracula.colors")
local M = {}
local blend = colors.hex_blend_with_rgb
local trans = colors.hex_trans_with_hsl

---@alias Palette table<string, string> -- keys -> hex color codes

--- Generate the default palette
---@return Palette
M.generate_default = function()
  local base = {
    fg_main        = "#ece1d7",
    select_hl      = "#524f4c",
    cursorline     = "#403d3b",
    bg_washed      = "#34302c",
    bg_main        = "#292522",

    comments       = "#91908e",
    ui_accent      = "#a08264",
    cursor_line_nr = "#f9a03f",
    delimiter      = "#d7b475",

    func           = "#9fc6b8",
    method         = "#8fd1b9",
    string         = "#9db2d2",
    type           = "#f1b47e",
    field          = "#fbdc98",
    keyword        = "#cd88b8",
    constant       = "#dfaad2",
    preproc        = "#cfbfe3",
    operator       = "#d47766",
    green          = "#89B3B6",

    ok             = "#78997A",
    warn           = "#EBC06D",
    info           = "#7F91B2",
    hint           = "#9C848F",
    error_light    = "#BD8183",
    error_dark     = "#7D2A2F",

    pop1           = "#69f59c",
  }
  return base
end

--- (Optional) A second variant, e.g., "saturated"
---@return Palette
M.generate_saturated = function()
  local p = M.generate_default()
  p.bg_main     = blend("#000000", p.bg_main,   0.3)
  p.bg_washed   = blend("#000000", p.bg_washed, 0.85)
  p.comments    = blend(p.fg_main, p.comments,  0.7)
  p.ui_accent   = blend(p.fg_main, p.ui_accent, 0.8)
  p.string      = blend(p.fg_main, p.string,    0.8)

  p.func        = trans(p.func,     0, 10, 10)
  p.type        = trans(p.type,     0, 20, 10)
  p.field       = trans(p.field,    0, 30, 0)
  p.keyword     = trans(p.keyword,  0, 20, 10)
  p.constant    = trans(p.constant, 0, 20, 30)
  p.preproc     = trans(p.preproc,  0, 30, 0)
  p.operator    = trans(p.operator, 0, 15, 10)
  return p
end

local _builtin_palettes = {
  default   = M.generate_default,
  saturated = M.generate_saturated,
}

---@param palette_name string
---@return Palette
local _get_palette = function(palette_name)
  if type(palette_name) ~= "string" then
    return _builtin_palettes["default"]()
  end
  return _builtin_palettes[palette_name] or _builtin_palettes["default"]()
end

---@param palette table
---@return Palette
M.setup_palette = function(palette)
  local p = palette

  p.bg_statusline1 = blend(p.select_hl, p.bg_main, 0.6)
  p.bg_statusline2 = blend(p.select_hl, p.bg_main, 0.2)

  p.func_param     = trans(p.fg_main, -15, -75, -10)
  p.member         = blend(p.string, p.fg_main, 0.5)
  p.hint           = trans(p.hint, 0, 10, 50)
  p.type_builtin   = blend(p.type, p.field, 0.5)

  -- Example: headings if you need them
  p.header1        = p.cursor_line_nr
  p.header2        = blend(p.cursor_line_nr, p.preproc, 0.2)
  p.header3        = blend(p.cursor_line_nr, p.preproc, 0.4)
  p.header4        = blend(p.cursor_line_nr, p.preproc, 0.6)
  p.header5        = blend(p.cursor_line_nr, p.preproc, 0.8)
  p.header6        = p.preproc

  return p
end

---@param theme string
---@param custom_palette table|nil
---@return Palette
M.setup = function(theme, custom_palette)
  local base = _get_palette(theme)
  if type(custom_palette) ~= "table" then
    M.palette = M.setup_palette(base)
  else
    local merged = vim.tbl_deep_extend("keep", custom_palette, base)
    M.palette = M.setup_palette(merged)
  end
  return M.palette
end

return M

