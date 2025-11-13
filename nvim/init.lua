if vim.env.NVIM_NO_TITLE then
  vim.opt.title = false
end

require("bootstrap.lazy")
require("autocmd")
require("settings")
require("keymaps")
require("plugins")
