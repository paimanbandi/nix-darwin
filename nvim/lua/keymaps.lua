local k = vim.keymap

k.set('i', 'hh', '<ESC>')
k.set('i', 'HH', '<ESC>')

k.set('v', 'J', ":m '>+1<CR>gv=gv")
k.set('v', 'K', ":m '<-2<CR>gv=gv")

k.set('n', '<leader><leader>', ':b#<CR>', { silent = true })

k.set("n", "<leader>dl", vim.diagnostic.setloclist, { desc = "Show diagnostics in loclist" })

k.set("n", "<leader>mm", ":!markmap % -o<CR>", { silent = true })
k.set("n", "<leader>n", ":set number!<CR>", { silent = true })
k.set("n", "<leader>r", ":set relativenumber!<CR>", { silent = true })

k.set("n", "<leader>dp", ":D2Preview<CR>", { desc = "D2 Preview" })
k.set("n", "<leader>dw", ":D2Watch<CR>", { desc = "D2 Watch" })
