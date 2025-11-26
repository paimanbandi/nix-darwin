return {
  {
    "edluffy/specs.nvim",
    event = "VeryLazy",
    config = function()
      require("specs").setup({
        show_jumps = true,
        min_jump = 10,
        popup = {
          delay_ms = 0,
          inc_ms = 10,
          blend = 10,
          width = 20,
          winhl = "PMenu",
          fader = require("specs").pulse_fader,
          resizer = require("specs").shrink_resizer,
        },
      })
    end,
  },
}
