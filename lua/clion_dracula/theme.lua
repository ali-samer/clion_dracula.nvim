-- lua/clion_dracula/theme.lua
local M = {}

---@alias Highlight table<string, string|boolean>
---@alias Theme table<string, Highlight>

---@return Theme
M.setup = function()
  local config = require("clion_dracula.config").options
  local by_group = config.format_by_group or {}
  local theme = config.theme
  local palette = config.palette

  local p = require("clion_dracula.palettes").setup(theme, palette)

  -- Basic/Editor highlights (Normal, CursorLine, etc.) can go here
  local highlights = {
    Normal       = { fg = p.fg_main, bg = p.bg_main },
    NormalFloat  = { fg = p.fg_main, bg = p.bg_main },
    CursorLine   = { bg = p.cursorline },
    Visual       = { bg = p.select_hl },
    Comment      = { fg = "#7A7E85" }, -- Could also map to p.comments if you want a single color
    -- etc...
  }

  ------------------------------------------------------------------------
  -- C/C++ Custom Highlights (based on your provided color mappings)
  ------------------------------------------------------------------------
  -- 1. Bad Character
  highlights["CppBadCharacter"]        = { fg = "#F75464" }

  -- 2. Braces and Operators
  highlights["CppBraces"]             = { fg = "#BCBEC4" }
  highlights["CppBrackets"]           = { fg = "#BCBEC4" }
  highlights["CppComma"]              = { fg = "#BCBEC4" }
  highlights["CppDot"]                = { fg = "#BCBEC4" }
  highlights["CppInitializerList"]    = { fg = "#FFFFFF", bold = true } -- white bold
  highlights["CppOperatorSign"]       = { fg = "#BCBEC4" }
  highlights["CppOverloadedOperator"] = { fg = "#5F8C8A" }
  highlights["CppParentheses"]        = { fg = "#BCBEC4" }
  highlights["CppSemicolon"]          = { fg = "#BCBEC4" }

  -- 3. Class/struct/enum/union
  highlights["CppType"]               = { fg = "#B5B6E3" }

  -- 4. Comments
  -- (We already set `Comment` above; you can refine Doxygen groups, etc.)
  highlights["CppDoxygenTag"]         = { fg = "#67A37C" }
  highlights["CppDoxygenTagValue"]    = { fg = "#ABADB3" }
  highlights["CppDoxygenText"]        = { fg = "#67A37C" }
  highlights["CppNonCompiledCode"]    = { fg = "#686A4E" }

  -- 5. Enum constant [Italic]
  highlights["CppEnumConstant"]       = { fg = "#C77DBB", italic = true }

  -- 6. Functions
  highlights["CppFunctionCall"]       = { fg = "#BCBEC4" }
  highlights["CppFunctionDecl"]       = { fg = "#56A8F5" }

  -- 7. Keywords
  highlights["CppKeyword"]            = { fg = "#CF8E6D" }
  highlights["CppThisKeyword"]        = { fg = "#CF8E6D" }
  highlights["CppLabel"]              = { fg = "#BCBEC4" }

  -- 8. Macro / Preprocessor
  highlights["CppMacroName"]          = { fg = "#908B25" }
  highlights["CppMacroParameter"]     = { fg = "#FFFFFF" }
  highlights["CppParameter"]          = { fg = "#BCBEC4" }
  highlights["CppPreprocDirective"]   = { fg = "#B3AE60" }
  highlights["CppHeaderPath"]         = { fg = "#6AAB73" }

  -- 9. Number
  highlights["CppNumber"]             = { fg = "#2AACB8" }

  -- 10. String
  highlights["CppStringEscapeValid"]  = { fg = "#CF8E6D" }
  highlights["CppStringEscapeInvalid"] = {
    fg        = "#CF8E6D",
    undercurl = true,
    sp        = "#FA6675", -- color for undercurl
  }
  highlights["CppFormatSpecifier"]    = { fg = "#CF8E6D" }
  highlights["CppStringText"]         = { fg = "#6AAB73" }

  -- 11. Struct field
  highlights["CppStructField"]        = { fg = "#9373A5" }

  -- 12. Templates
  highlights["CppTemplateConcept"]    = { fg = "#B5B6E3" }
  highlights["CppDeductionGuide"]     = { fg = "#56A8F5" }
  highlights["CppDependentCode"]      = { fg = "#BCBEC4" }
  highlights["CppTemplateType"]       = { fg = "#B9BCD1" }
  highlights["CppTemplateValue"]      = { fg = "#C77DBB", italic = true }

  -- 13. Typedef
  highlights["CppTypedef"]           = { fg = "#B9BCD1" }

  -- 14. Variables
  highlights["CppExternVariable"]    = { fg = "#BCBEC4" }
  highlights["CppGlobalVariable"]    = { fg = "#BCBEC4" }
  highlights["CppLocalVariable"]     = { fg = "#BCBEC4" }

  -- 15. Semantic highlighting fallback
  highlights["CppSemantic"]          = { fg = "#FFFFFF" }

  ------------------------------------------------------------------------
  -- Apply any group-based user overrides from config.format_by_group
  ------------------------------------------------------------------------
  highlights = M._apply_raw_formatting(highlights, by_group)

  return highlights
end

--- Merges user overrides from config.format_by_group into highlight specs
---@param highlights table
---@param styling table
---@return table
M._apply_raw_formatting = function(highlights, styling)
  if type(styling) ~= "table" then
    return highlights
  end
  for group, style in pairs(styling) do
    style = M._sanitize_style(style)
    if highlights[group] then
      highlights[group] = vim.tbl_deep_extend("force", highlights[group], style)
    else
      highlights[group] = style
    end
  end
  return highlights
end

---@param style table
---@return table
M._sanitize_style = function(style)
  for attr_name, _ in pairs(style) do
    if not M._validate_hl_attr(attr_name) then
      style[attr_name] = nil
    end
  end
  return style
end

local _valid_attr_names = {
  fg            = true,
  bg            = true,
  sp            = true,
  blend         = true,
  bold          = true,
  standout      = true,
  underline     = true,
  undercurl     = true,
  underdouble   = true,
  underdotted   = true,
  underdashed   = true,
  strikethrough = true,
  italic        = true,
  reverse       = true,
  nocombine     = true,
  link          = true,
}

M._validate_hl_attr = function(attr_name)
  return _valid_attr_names[attr_name] == true
end

return M

