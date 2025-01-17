-- colors/clion_dracula.lua
-- This file is executed when user runs :colorscheme clion_dracula

-- 1. Load user config (optional, if you want them to override your defaults)
require("clion_dracula.config").setup()

-- 2. Retrieve the highlight definitions from our theme
local highlights = require("clion_dracula.theme").setup()

-- 3. Apply them all using the Neovim API
for group, specs in pairs(highlights) do
  vim.api.nvim_set_hl(0, group, specs)
end

