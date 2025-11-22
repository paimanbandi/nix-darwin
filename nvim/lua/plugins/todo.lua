return {
  "folke/todo-comments.nvim",
  dependencies = "nvim-lua/plenary.nvim",
  config = function()
    require("todo-comments").setup({})
    vim.keymap.set("n", "<leader>td", "<cmd>TodoTrouble<CR>", { desc = "Todo list" })
    vim.keymap.set("n", "<leader>tq", "<cmd>TodoQuickFix<CR>", { desc = "Todo to QuickFix" })
  end,
}
