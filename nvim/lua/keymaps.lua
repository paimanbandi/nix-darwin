local k = vim.keymap

k.set('i', 'hh', '<ESC>')
k.set('i', 'HH', '<ESC>')

k.set('v', 'J', ":m '>+1<CR>gv=gv")
k.set('v', 'K', ":m '<-2<CR>gv=gv")
