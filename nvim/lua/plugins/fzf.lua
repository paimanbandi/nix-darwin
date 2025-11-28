return {
  "ibhagwan/fzf-lua",
  dependencies = { "nvim-tree/nvim-web-devicons" },
  config = function()
    require("fzf-lua").setup({
      fzf_opts = {
        ["--cycle"] = true,
      },
      hls = {
        normal = "Normal",
        border = "FloatBorder",
        title = "Title",
        search = "IncSearch",
        scrollbar_e = "PmenuSbar",
        scrollbar_f = "PmenuThumb",
      },
    })

    vim.api.nvim_set_hl(0, "FzfLuaMatch", {
      fg = "#fabd2f",
      bold = true
    })
  end,
  keys = {
    { "<leader>ff", "<cmd>FzfLua files<cr>",     desc = "Find Files" },
    { "<leader>lg", "<cmd>FzfLua live_grep<cr>", desc = "Live Grep" },
  },
}
