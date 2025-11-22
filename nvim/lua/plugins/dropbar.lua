return {
  "Bekaboo/dropbar.nvim",
  event = { "BufReadPost", "BufNewFile" },
  dependencies = {
    "nvim-telescope/telescope-fzf-native.nvim",
  },
  opts = {
    general = {
      enable = true,
    },
    icons = {
      enable = true,
      kinds = {
        use_devicons = true,
      },
    },
  },
  config = function(_, opts)
    require("dropbar").setup(opts)
  end,
}
