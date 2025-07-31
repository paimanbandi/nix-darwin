return {
  "nvimdev/lspsaga.nvim",
  event = "LspAttach",
  config = function()
    require("lspsaga").setup({})
    vim.keymap.set("n", "gd", "<cmd>Lspsaga goto_definition<CR>", { silent = true, desc = "Go to Definition (Lspsaga)" })
    vim.keymap.set("n", "<leader>ca", "<cmd>Lspsaga code_action<CR>", { silent = true })
  end,
  dependencies = {
    "nvim-treesitter/nvim-treesitter",
    "nvim-tree/nvim-web-devicons"
  }
}
