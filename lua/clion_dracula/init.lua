-- lua/clion_dracula/init.lua
local M = {}

-- A single convenient setup function
---@param opts table|nil
function M.setup(opts)
  -- 1. Set up the config
  require("clion_dracula.config").setup(opts)

  -- 2. Retrieve highlights
  local highlights = require("clion_dracula.theme").setup()

  -- 3. Apply them
  for group, spec in pairs(highlights) do
    vim.api.nvim_set_hl(0, group, spec)
  end
end

return M

