return {
  "folke/snacks.nvim",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "stevearc/oil.nvim",
  },
  opts = {
    -- Konfigurasi snacks.nvim
    integrations = {
      oil = true, -- Integrasi dengan oil.nvim
    },
    preview = {
      width = 80,
      height = 40,
      border = "rounded",
    },
  },
  config = function(_, opts)
    require("snacks").setup(opts)

    -- Keymaps global
    vim.keymap.set("n", "<leader>sp", "<cmd>Snacks toggle<cr>", { desc = "Snacks Toggle" })
    vim.keymap.set("n", "<leader>so", "<cmd>Snacks open<cr>", { desc = "Snacks Open" })
    vim.keymap.set("n", "<leader>sq", "<cmd>Snacks close<cr>", { desc = "Snacks Close" })
  end,
}
