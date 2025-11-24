return {
  "ibhagwan/fzf-lua",
  dependencies = { "nvim-tree/nvim-web-devicons" },
  config = function()
    require("fzf-lua").setup({})
  end,
  keys = {
    { "<leader>ff", "<cmd>FzfLua files<cr>",     desc = "Find Files" },
    { "<leader>lg", "<cmd>FzfLua live_grep<cr>", desc = "Live Grep" },
  },
}
