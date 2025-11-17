-- ~/.config/nvim/lua/plugins/diffview.lua
return {
  "sindrets/diffview.nvim",
  dependencies = { "nvim-lua/plenary.nvim" },
  cmd = { "DiffviewOpen", "DiffviewFileHistory" },
  keys = {
    { "<leader>gd", "<cmd>DiffviewOpen<cr>",        desc = "Open Diffview" },
    { "<leader>gh", "<cmd>DiffviewFileHistory<cr>", desc = "File History" },
    { "<leader>gc", "<cmd>DiffviewClose<cr>",       desc = "Close Diffview" },
    { "<leader>gm", "<cmd>DiffviewOpen<cr>",        desc = "Show Conflicts" },
  },
  config = function()
    local actions = require("diffview.actions")

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
          -- Layout untuk conflict resolution
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
        -- Keymaps untuk diff view (saat lihat file)
        view = {
          { "n", "q",          actions.close,                     { desc = "Close diffview" } },
          { "n", "<tab>",      actions.select_next_entry,         { desc = "Next file" } },
          { "n", "<s-tab>",    actions.select_prev_entry,         { desc = "Previous file" } },
          { "n", "[x",         actions.prev_conflict,             { desc = "Previous conflict" } },
          { "n", "]x",         actions.next_conflict,             { desc = "Next conflict" } },
          -- Commands untuk resolve conflict (hanya work saat ada conflict)
          { "n", "<leader>co", actions.conflict_choose("ours"),   { desc = "Choose Ours" } },
          { "n", "<leader>ct", actions.conflict_choose("theirs"), { desc = "Choose Theirs" } },
          { "n", "<leader>cb", actions.conflict_choose("base"),   { desc = "Choose Base" } },
          { "n", "<leader>ca", actions.conflict_choose("all"),    { desc = "Choose All" } },
          { "n", "dx",         actions.conflict_choose("none"),   { desc = "Delete conflict region" } },
        },
        -- Keymaps untuk file panel (sidebar)
        file_panel = {
          { "n", "j",       actions.next_entry,        { desc = "Next file" } },
          { "n", "k",       actions.prev_entry,        { desc = "Previous file" } },
          { "n", "<cr>",    actions.select_entry,      { desc = "Open file" } },
          { "n", "o",       actions.select_entry,      { desc = "Open file" } },
          { "n", "q",       actions.close,             { desc = "Close diffview" } },
          { "n", "R",       actions.refresh_files,     { desc = "Refresh files" } },
          { "n", "<tab>",   actions.select_next_entry, { desc = "Next file" } },
          { "n", "<s-tab>", actions.select_prev_entry, { desc = "Previous file" } },
        },
        file_history_panel = {
          { "n", "q",    actions.close,        { desc = "Close" } },
          { "n", "o",    actions.select_entry, { desc = "Open" } },
          { "n", "<cr>", actions.select_entry, { desc = "Open" } },
        },
      },
    })
  end,
}
