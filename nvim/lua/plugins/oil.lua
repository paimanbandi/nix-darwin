return {
  "stevearc/oil.nvim",
  config = function()
    require("oil").setup()
    vim.keymap.set("n", "-", "<CMD>Oil<CR>", { desc = "Open parent dir" })
    vim.keymap.set("n", "<leader>.", "<CMD>lua require('oil').toggle_hidden()<CR>", { desc = "Toggle hidden" })
  end,
}
