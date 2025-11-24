return {
  -- 2. Beacon - Flash super smooth saat jump
  {
    "danilamihailov/beacon.nvim",
    event = "VeryLazy",
    config = function()
      vim.g.beacon_size = 150       -- Bigger flash
      vim.g.beacon_fade = 1         -- Enable fade
      vim.g.beacon_show_jumps = 1
      vim.g.beacon_shrink = 1       -- Shrink animation
      vim.g.beacon_minimal_jump = 5 -- More sensitive
      vim.g.beacon_timeout = 800    -- Longer duration
      vim.g.beacon_ignore_filetypes = { 'fzf', 'NvimTree' }

      -- Ultra smooth fire gradient
      vim.cmd([[
        highlight Beacon guibg=#ff4500 ctermbg=red gui=bold blend=50
        highlight BeaconDefault guibg=#ff6347 ctermbg=red blend=50
      ]])
    end,
  },
  {
    "rcarriga/nvim-notify",
    config = function()
      local notify = require("notify")

      notify.setup({
        stages = "fade_in_slide_out", -- Smooth slide
        timeout = 4000,
        background_colour = "#000000",
        fps = 60, -- Smooth 60fps animations
        icons = {
          ERROR = "",
          WARN = "",
          INFO = "",
          DEBUG = "",
          TRACE = "✎",
        },
        level = vim.log.levels.INFO,
        minimum_width = 50,
        render = "wrapped-compact", -- Smoother render
        top_down = true,
      })

      vim.notify = notify
    end,
  },
}
