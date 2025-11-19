local g = vim.g
local opt = vim.opt

g.mapleader = ' '
g.indentLine_char = '¦'

opt.mouse = 'a'
opt.clipboard = 'unnamedplus'

opt.number = true
opt.relativenumber = false
opt.numberwidth = 8
opt.tabstop = 2
opt.shiftwidth = 2
opt.expandtab = true
opt.smartindent = true
opt.termguicolors = true
opt.cursorline = false

opt.updatetime = 300
opt.timeoutlen = 300
opt.signcolumn = "yes"

-- Smooth scrolling behavior
vim.opt.scrolloff = 8       -- Keep cursor centered
vim.opt.sidescrolloff = 8
vim.opt.smoothscroll = true -- Native smooth scroll (Neovim 0.10+)

-- Reduce visual clutter untuk smooth appearance
vim.opt.cmdheight = 1
vim.opt.laststatus = 3   -- Global statusline (cleaner)
vim.opt.showmode = false -- Hide mode (noice handles this)

-- Better rendering
vim.opt.conceallevel = 0
vim.opt.concealcursor = ""

opt.fillchars = {
  vert = "│",
  vertleft = "│",
  vertright = "│",
  horiz = "─",
  horizup = "─",
  msgsep = "~",
  foldsep = "│",
  foldopen = "▾",
  foldclose = "▸",
}

opt.guicursor = {
  "n-v-c:block-Cursor/lCursor",
  "i-ci-ve:ver25-Cursor/lCursor",
  "r-cr:hor20-Cursor/lCursor",
  "o:hor50-Cursor/lCursor",
  "a:blinkwait700-blinkoff400-blinkon250",
  "sm:block-blinkwait175-blinkoff150-blinkon175",
}
