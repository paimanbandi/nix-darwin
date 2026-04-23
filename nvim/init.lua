-- Workaround nvim 0.12 treesitter.get_range bug
-- https://github.com/neovim/neovim/issues/39032
local orig_get_range = vim.treesitter.get_range
vim.treesitter.get_range = function(node, ...)
  if node == nil then
    return { 0, 0, 0, 0, 0, 0 }
  end
  local ok, result = pcall(orig_get_range, node, ...)
  if ok then
    return result
  end
  return { 0, 0, 0, 0, 0, 0 }
end
require("bootstrap.lazy")
require("autocmd")
require("settings")
require("keymaps")
require("plugins")
