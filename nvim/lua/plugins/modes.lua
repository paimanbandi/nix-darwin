return {
  "mvllow/modes.nvim",
  event = "VeryLazy",
  config = function()
    require("modes").setup({
      colors = {
        insert = "#00ffaa",
        visual = "#ffaaff",
        normal = "#ffcc00",
      },
      line_opacity = 0.15,
      set_cursor = true,
    })
  end
}
