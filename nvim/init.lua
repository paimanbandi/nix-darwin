require("bootstrap.lazy")
require("autocmd")
require("settings")
require("keymaps")
require("plugins")

if vim.env.NVIM_NO_TITLE then
  vim.opt.title = false
  vim.opt.titlestring = ""
  vim.notify("Title disabled (NVIM_NO_TITLE=1)", vim.log.levels.INFO)
end
