return {
  "ThePrimeagen/refactoring.nvim",
  dependencies = { "nvim-lua/plenary.nvim", "nvim-treesitter/nvim-treesitter" },
  config = function()
    require("refactoring").setup({})
    -- keymaps
    vim.keymap.set("v", "<leader>re", function()
      require("refactoring").refactor("Extract Function")
    end, { desc = "Refactor: Extract Function" })

    vim.keymap.set("v", "<leader>rv", function()
      require("refactoring").refactor("Extract Variable")
    end, { desc = "Refactor: Extract Variable" })

    vim.keymap.set("v", "<leader>rf", function()
      require("refactoring").refactor("Inline Variable")
    end, { desc = "Refactor: Inline Variable" })
  end,
}
