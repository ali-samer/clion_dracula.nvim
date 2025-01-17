-- lua/clion_dracula/config.lua
local M = {}

local _generate_default = function()
  local options = {
    -- The "theme" here refers to which palette you want by default, e.g. "default" or "saturated"
    theme = "default",

    -- Additional palette overrides can go here
    palette = {},

    formatting = {
      -- Example: built-in italic for strings/comments
      builtin_strings = {
        styling = { italic = true },
        groups = {
          "String",
          "Character",
          "Comment",
        },
      },
      builtin_bg_fading = {
        groups = {
          "NormalNC",
          "NormalFloatNC",
        },
      },
      builtin_transparent = {
        groups = {
          "Normal",
          "NormalNC",
          "NormalFloat",
          "NormalFloatNC",
          "SignColumn",
          "StatusLine",
          "StatusLineNC",
          "Pmenu",
          "WinSeparator",
          "VertSplit",
          "Folded",
          -- integrations
          "FlashBackdrop",
        },
      },
    },

    -- These group-based overrides can apply custom styles to any highlight group
    format_by_group = {
      -- Example overrides:
      -- Comment = { italic = false },
      -- String  = { italic = false },
    },
  }

  return options
end

--- Convert the `formatting` table to a simpler `format_by_group`.
M._convert_formatting = function(formatting)
  local converted = {}
  for _, tbl in pairs(formatting or {}) do
    local styling = tbl.styling
    local groups = tbl.groups
    for _, group in ipairs(groups or {}) do
      if styling then
        converted[group] = styling
      end
    end
  end
  return converted
end

M._squash_formatting = function(options)
  local converted_formatting = M._convert_formatting(options.formatting)
  options.formatting = nil
  options.format_by_group = vim.tbl_deep_extend("force", converted_formatting, options.format_by_group or {})

  return options
end

--- Main setup function that merges user options with defaults
M.setup = function(options)
  local defaults = _generate_default()

  local config = vim.tbl_deep_extend("force", defaults, options or {})
  config = M._squash_formatting(config)

  M.options = config
end

return M

