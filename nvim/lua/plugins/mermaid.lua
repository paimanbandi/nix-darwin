return {
  {
    "OXY2DEV/markview.nvim",
    lazy = false,
    dependencies = {
      "nvim-treesitter/nvim-treesitter",
      "nvim-tree/nvim-web-devicons"
    },
    config = function()
      require("markview").setup({
        modes = { "n", "no", "c" },
        hybrid_modes = { "n" },
        callbacks = {
          on_enable = function(_, win)
            vim.wo[win].conceallevel = 2
            vim.wo[win].concealcursor = "c"
          end
        }
      })
      vim.keymap.set("n", "<leader>mp", ":MarkdownPreview<CR>", { desc = "Mermaid/Markdown Preview" })
      vim.keymap.set("n", "<leader>ms", ":MarkdownPreviewStop<CR>", { desc = "Stop Mermaid Preview" })
      vim.keymap.set("n", "<leader>mt", ":MarkdownPreviewToggle<CR>", { desc = "Toggle Mermaid Preview" })
    end
  }
}
