return {
  "mikavilpas/yazi.nvim",
  event = "VeryLazy",
  keys = {
    {
      "<leader>y",
      "<cmd>Yazi<cr>",
      desc = "Open yazi file manager",
    },
    {
      "<leader>Y",
      "<cmd>Yazi cwd<cr>",
      desc = "Open yazi in current working directory",
    },
    {
      "<leader>fy",
      "<cmd>Yazi<cr>",
      desc = "Open yazi (file manager)",
    },
  },
  opts = {
    open_for_directories = false,
    keymaps = {
      show_help = '<f1>',
    },
  },
}
