local k = k

k.set('i', 'hh', '<ESC>')
k.set('i', 'HH', '<ESC>')

k.set('v', 'J', ":m '>+1<CR>gv=gv")
k.set('v', 'K', ":m '<-2<CR>gv=gv")

k.set('n', '<leader><leader>', ':b#<CR>', { silent = true })

k.set("n", "<leader>dl", vim.diagnostic.setloclist, { desc = "Show diagnostics in loclist" })

k.set("n", "<leader>mm", ":!markmap % -o<CR>", { silent = true })

k.set('n', '<Esc>', '<cmd>nohlsearch<CR>', { desc = 'Clear search highlights' })

k.set("n", "<leader>mp", ":MarkdownPreview<CR>", { desc = "Mermaid/Markdown Preview" })
k.set("n", "<leader>ms", ":MarkdownPreviewStop<CR>", { desc = "Stop Mermaid Preview" })
k.set("n", "<leader>mt", ":MarkdownPreviewToggle<CR>", { desc = "Toggle Mermaid Preview" })
