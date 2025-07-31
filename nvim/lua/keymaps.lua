local k = vim.keymap

k.set('i', 'hh', '<ESC>')
k.set('i', 'HH', '<ESC>')

k.set('v', 'J', ":m '>+1<CR>gv=gv")
k.set('v', 'K', ":m '<-2<CR>gv=gv")

k.set('n', '<leader><leader>', ':b#<CR>', { silent = true })

k.set("n", "<leader>dl", vim.diagnostic.setloclist, { desc = "Show diagnostics in loclist" })
