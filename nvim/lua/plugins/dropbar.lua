return {
  "Bekaboo/dropbar.nvim",
  event = { "BufReadPost", "BufNewFile" },
  dependencies = {
    "nvim-telescope/telescope-fzf-native.nvim",
  },
  opts = {
    -- ✅ PERUBAHAN: 'general.enable' pindah ke 'bar.enable'
    bar = {
      enable = function(buf, win)
        return vim.api.nvim_win_get_height(win) > 4
            and vim.api.nvim_win_get_width(win) > 80
            and vim.bo[buf].buftype == ""
      end,
      padding = {
        left = 1,
        right = 1,
      },
      truncate = true,
    },
    icons = {
      enable = true,
      kinds = {
        -- ✅ PERUBAHAN: 'use_devicons' diganti dua field terpisah
        file_icon = function(opts)
          return require("nvim-web-devicons").get_icon(
            vim.fn.fnamemodify(opts.buf_name or "", ":t"),
            vim.fn.fnamemodify(opts.buf_name or "", ":e"),
            { default = true }
          )
        end,
        folder_icon = {
          closed = " ",
          open = " ",
        },
      },
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
