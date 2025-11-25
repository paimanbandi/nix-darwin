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
    {
      "<leader>a",
      function()
        require("aerial").toggle()
        -- Tunggu sedikit lalu pindah jendela biar fokus ke Aerial
        vim.defer_fn(function()
          vim.cmd("wincmd w") -- sama seperti Ctrl+w w
        end, 10)
      end,
      desc = "Toggle Outline (Aerial) + Focus",
    },
    { "{", "<cmd>AerialPrev<CR>", desc = "Previous Symbol" },
    { "}", "<cmd>AerialNext<CR>", desc = "Next Symbol" },
  },
  dependencies = {
    "nvim-treesitter/nvim-treesitter",
    "nvim-tree/nvim-web-devicons",
  },
}
