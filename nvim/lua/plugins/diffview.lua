return {
  "sindrets/diffview.nvim",
  dependencies = { "nvim-lua/plenary.nvim" },
  cmd = { "DiffviewOpen", "DiffviewFileHistory" },
  keys = {
    { "<leader>gd", "<cmd>DiffviewOpen<cr>",        desc = "Open Diffview" },
    { "<leader>gh", "<cmd>DiffviewFileHistory<cr>", desc = "File History" },
    { "<leader>gc", "<cmd>DiffviewClose<cr>",       desc = "Close Diffview" },
    -- Untuk conflict resolution
    { "<leader>gm", "<cmd>DiffviewOpen HEAD<cr>",   desc = "Merge Conflicts" },
  },
  config = function()
    require("diffview").setup({
      enhanced_diff_hl = true,
      use_icons = true,
      icons = {
        folder_closed = "",
        folder_open = "",
      },
      signs = {
        fold_closed = "",
        fold_open = "",
        done = "✓",
      },
      view = {
        default = {
          layout = "diff2_horizontal",
        },
        merge_tool = {
          layout = "diff3_horizontal",
          disable_diagnostics = true,
        },
      },
      file_panel = {
        listing_style = "tree",
        tree_options = {
          flatten_dirs = true,
          folder_statuses = "only_folded",
        },
        win_config = {
          position = "left",
          width = 35,
        },
      },
      keymaps = {
        view = {
          { "n", "q",          "<cmd>DiffviewClose<cr>",                { desc = "Close diffview" } },
          { "n", "<leader>co", "<cmd>DiffviewConflictChooseOurs<cr>",   { desc = "Choose Ours" } },
          { "n", "<leader>ct", "<cmd>DiffviewConflictChooseTheirs<cr>", { desc = "Choose Theirs" } },
          { "n", "<leader>cb", "<cmd>DiffviewConflictChooseBase<cr>",   { desc = "Choose Base" } },
          { "n", "<leader>ca", "<cmd>DiffviewConflictChooseAll<cr>",    { desc = "Choose All" } },
          { "n", "dx",         "<cmd>DiffviewConflictDelete<cr>",       { desc = "Delete conflict region" } },
        },
        file_panel = {
          { "n", "q",    "<cmd>DiffviewClose<cr>",                                    { desc = "Close diffview" } },
          { "n", "<cr>", "<cmd>lua require('diffview.actions').goto_file_edit()<cr>", { desc = "Open file" } },
        },
      },
    })
  end,
}
