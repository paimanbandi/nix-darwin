return {
  "MagicDuck/grug-far.nvim",
  keys = {
    { "<leader>gr", function() require("grug-far").open() end, desc = "Search & Replace (Grug)" },
  },
  opts = {
    -- opsional, cuman kalau mau theme lebih enak
    window = {
      border = "rounded",
    },
  },
}
