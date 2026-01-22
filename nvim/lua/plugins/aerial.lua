return {
  "stevearc/aerial.nvim",
  event = "LspAttach",
  opts = {
    backends = { "lsp", "treesitter", "markdown", "man" },
    attach_mode = "window",
    layout = {
      default_direction = "float",
      max_width = { 40, 0.2 },
    },
    show_guides = true,
    -- Tambahan: auto focus saat dibuka
    on_attach = function(bufnr)
      vim.keymap.set("n", "{", "<cmd>AerialPrev<CR>", { buffer = bufnr })
      vim.keymap.set("n", "}", "<cmd>AerialNext<CR>", { buffer = bufnr })
    end,
  },
  keys = {
    {
      "<leader>a",
      function()
        require("aerial").toggle()
        -- Delay kecil untuk memastikan window sudah terbuka
        vim.defer_fn(function()
          -- Cari window aerial dan focus ke sana
          for _, win in ipairs(vim.api.nvim_list_wins()) do
            local buf = vim.api.nvim_win_get_buf(win)
            if vim.bo[buf].filetype == "aerial" then
              vim.api.nvim_set_current_win(win)
              break
            end
          end
        end, 50)
      end,
      desc = "Toggle Outline (Aerial)"
    },
    { "{", "<cmd>AerialPrev<CR>", desc = "Previous Symbol" },
    { "}", "<cmd>AerialNext<CR>", desc = "Next Symbol" },
  },
  dependencies = {
    "nvim-treesitter/nvim-treesitter",
    "nvim-tree/nvim-web-devicons",
  },
}
