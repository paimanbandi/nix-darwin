return {
  "APZelos/blamer.nvim",
  config = function()
    vim.g.blamer_enabled = true
    vim.g.blamer_delay = 1000 -- dalam milidetik
    vim.g.blamer_show_in_insert_modes = 0 -- nggak tampil saat insert
    vim.g.blamer_template = '<author> • <summary>' -- template pesan
    vim.g.blamer_date_format = '%d/%m/%y %H:%M'
    -- Contoh keymap toggle
    vim.keymap.set("n", "<leader>bt", "<cmd>BlamerToggle<CR>", { silent = true })
  end,
}
