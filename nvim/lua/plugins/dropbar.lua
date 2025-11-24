return {
  "Bekaboo/dropbar.nvim",
  event = { "BufReadPost", "BufNewFile" },
  dependencies = {
    "nvim-telescope/telescope-fzf-native.nvim",
  },
  opts = {
    general = {
      enable = function(buf, win)
        -- Disable di window kecil
        return vim.api.nvim_win_get_height(win) > 4
            and vim.api.nvim_win_get_width(win) > 80
            and vim.bo[buf].buftype == ""
      end,
    },
    icons = {
      enable = true,
      kinds = {
        use_devicons = true,
      },
    },
    bar = {
      padding = {
        left = 1,
        right = 1,
      },
      truncate = true, -- Tambahkan ini
    },
    menu = {
      win_configs = {
        border = "rounded",
        style = "minimal",
      },
    },
  },
  config = function(_, opts)
    require("dropbar").setup(opts)
  end,
}
