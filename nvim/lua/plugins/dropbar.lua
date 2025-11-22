return {
  "Bekaboo/dropbar.nvim",
  dependencies = { "nvim-telescope/telescope-fzf-native.nvim" },
  config = function()
    require("dropbar").setup()
    vim.keymap.set("n", "<leader>db", function()
      require("dropbar.api").pick() -- buka breadcrumb picker
    end, { desc = "Dropbar picker" })
  end,
}
