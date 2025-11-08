return {
  "stevearc/overseer.nvim",
  opts = {
    strategy = {
      "toggleterm", -- atau "terminal" kalau kamu tidak pakai toggleterm.nvim
      direction = "horizontal",
      open_on_start = true,
    },
    task_list = {
      direction = "bottom",
      min_height = 8,
      max_height = 20,
    },
  },
  keys = {
    { "<leader>or", "<cmd>OverseerRun<cr>",    desc = "Run task" },
    { "<leader>ol", "<cmd>OverseerToggle<cr>", desc = "Toggle task list" },
    { "<leader>oo", "<cmd>OverseerOpen<cr>",   desc = "Open task window" },
  },
}
