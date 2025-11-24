return {
  "stevearc/aerial.nvim",
  opts = {
    backends = { "lsp", "treesitter", "markdown", "man" },
    attach_mode = "window",        -- Ubah dari "global" ke "window"
    layout = {
      default_direction = "float", -- Ubah dari "right" ke "float"
      max_width = { 40, 0.2 },
    },
    show_guides = true,
  },
  keys = {
    { "<leader>a", "<cmd>AerialToggle!<CR>", desc = "Toggle Outline (Aerial)" },
    { "{",         "<cmd>AerialPrev<CR>",    desc = "Previous Symbol" },
    { "}",         "<cmd>AerialNext<CR>",    desc = "Next Symbol" },
  },
  dependencies = {
    "nvim-treesitter/nvim-treesitter",
    "nvim-tree/nvim-web-devicons",
  },
}
