return {
  "gen740/SmoothCursor.nvim",
  event = "VeryLazy",
  config = function()
    require('smoothcursor').setup({
      type = "default",
      cursor = "",
      texthl = "SmoothCursor",
      linehl = nil,

      fancy = {
        enable = true,
        head = {
          cursor = "█",
          texthl = "SmoothCursorHead",
          linehl = nil
        },
        body = {
          -- HYBRID: blocks → shades → circles → dots
          { cursor = "█", texthl = "SmoothCursorRed" },
          { cursor = "█", texthl = "SmoothCursorRed2" },
          { cursor = "█", texthl = "SmoothCursorOrange" },
          { cursor = "▓", texthl = "SmoothCursorOrange2" },
          { cursor = "▓", texthl = "SmoothCursorOrange3" },
          { cursor = "▒", texthl = "SmoothCursorOrange4" },
          { cursor = "▒", texthl = "SmoothCursorOrange5" },
          { cursor = "●", texthl = "SmoothCursorOrange6" },
          { cursor = "●", texthl = "SmoothCursorOrange7" },
          { cursor = "○", texthl = "SmoothCursorOrange8" },
          { cursor = "○", texthl = "SmoothCursorOrange9" },
          { cursor = "•", texthl = "SmoothCursorOrange10" },
          { cursor = "·", texthl = "SmoothCursorOrange11" },
        },
        tail = { cursor = nil, texthl = "SmoothCursor" }
      },

      autostart = true,
      always_redraw = true,

      -- SMEAR-LIKE settings (slower = more visible trail)
      flyin_effect = nil,
      speed = 30,     -- Slower untuk longer trail
      intervals = 40, -- Higher untuk smoother fade
      priority = 10,
      timeout = 3000,
      threshold = 1, -- More sensitive

      disable_float_win = false,
      enabled_filetypes = nil,
      disabled_filetypes = nil,
    })

    -- Fire gradient colors (red → orange)
    vim.api.nvim_set_hl(0, "SmoothCursor", { fg = "#ff4500", bg = "NONE" })
    vim.api.nvim_set_hl(0, "SmoothCursorHead", { fg = "#ff0000", bg = "NONE", bold = true })

    -- Red blocks
    vim.api.nvim_set_hl(0, "SmoothCursorRed", { fg = "#ff0000", bg = "NONE" })
    vim.api.nvim_set_hl(0, "SmoothCursorRed2", { fg = "#ff0808", bg = "NONE" })
    vim.api.nvim_set_hl(0, "SmoothCursorOrange", { fg = "#ff1010", bg = "NONE" })

    -- Shades
    vim.api.nvim_set_hl(0, "SmoothCursorOrange2", { fg = "#ff1818", bg = "NONE" })
    vim.api.nvim_set_hl(0, "SmoothCursorOrange3", { fg = "#ff2020", bg = "NONE" })
    vim.api.nvim_set_hl(0, "SmoothCursorOrange4", { fg = "#ff2828", bg = "NONE" })
    vim.api.nvim_set_hl(0, "SmoothCursorOrange5", { fg = "#ff3030", bg = "NONE" })

    -- Circles
    vim.api.nvim_set_hl(0, "SmoothCursorOrange6", { fg = "#ff3838", bg = "NONE" })
    vim.api.nvim_set_hl(0, "SmoothCursorOrange7", { fg = "#ff4545", bg = "NONE" })
    vim.api.nvim_set_hl(0, "SmoothCursorOrange8", { fg = "#ff5252", bg = "NONE" })
    vim.api.nvim_set_hl(0, "SmoothCursorOrange9", { fg = "#ff5f5f", bg = "NONE" })

    -- Dots
    vim.api.nvim_set_hl(0, "SmoothCursorOrange10", { fg = "#ff6c6c", bg = "NONE" })
    vim.api.nvim_set_hl(0, "SmoothCursorOrange11", { fg = "#ff7979", bg = "NONE" })

    -- Normal cursor merah
    vim.cmd([[
      highlight Cursor guibg=#ff0000 guifg=#ffffff gui=NONE
      highlight CursorLineNr guifg=#ff4500 gui=bold
    ]])

    -- Keybindings untuk adjust speed/trail
    vim.keymap.set('n', '<leader>t1', function()
      -- Fast & short trail
      require('smoothcursor').setup({
        fancy = {
          body = {
            { cursor = "█", texthl = "SmoothCursorRed" },
            { cursor = "▓", texthl = "SmoothCursorOrange2" },
            { cursor = "●", texthl = "SmoothCursorOrange6" },
            { cursor = "○", texthl = "SmoothCursorOrange8" },
            { cursor = "·", texthl = "SmoothCursorOrange10" },
          }
        },
        speed = 15,
        intervals = 20,
        threshold = 3,
      })
      vim.notify("⚡ Fast mode", vim.log.levels.INFO)
    end, { desc = 'Fast mode' })

    vim.keymap.set('n', '<leader>t2', function()
      -- Balanced (default)
      require('smoothcursor').setup({
        fancy = {
          body = {
            { cursor = "█", texthl = "SmoothCursorRed" },
            { cursor = "█", texthl = "SmoothCursorRed2" },
            { cursor = "█", texthl = "SmoothCursorOrange" },
            { cursor = "▓", texthl = "SmoothCursorOrange2" },
            { cursor = "▓", texthl = "SmoothCursorOrange3" },
            { cursor = "▒", texthl = "SmoothCursorOrange4" },
            { cursor = "▒", texthl = "SmoothCursorOrange5" },
            { cursor = "●", texthl = "SmoothCursorOrange6" },
            { cursor = "●", texthl = "SmoothCursorOrange7" },
            { cursor = "○", texthl = "SmoothCursorOrange8" },
            { cursor = "○", texthl = "SmoothCursorOrange9" },
            { cursor = "•", texthl = "SmoothCursorOrange10" },
            { cursor = "·", texthl = "SmoothCursorOrange11" },
          }
        },
        speed = 30,
        intervals = 40,
        threshold = 1,
      })
      vim.notify("✨ Balanced mode", vim.log.levels.INFO)
    end, { desc = 'Balanced mode' })

    vim.keymap.set('n', '<leader>t3', function()
      -- Slow & long trail (very smear-like)
      require('smoothcursor').setup({
        fancy = {
          body = {
            { cursor = "█", texthl = "SmoothCursorRed" },
            { cursor = "█", texthl = "SmoothCursorRed2" },
            { cursor = "█", texthl = "SmoothCursorOrange" },
            { cursor = "█", texthl = "SmoothCursorOrange2" },
            { cursor = "▓", texthl = "SmoothCursorOrange3" },
            { cursor = "▓", texthl = "SmoothCursorOrange4" },
            { cursor = "▒", texthl = "SmoothCursorOrange5" },
            { cursor = "▒", texthl = "SmoothCursorOrange6" },
            { cursor = "●", texthl = "SmoothCursorOrange7" },
            { cursor = "●", texthl = "SmoothCursorOrange8" },
            { cursor = "○", texthl = "SmoothCursorOrange9" },
            { cursor = "○", texthl = "SmoothCursorOrange10" },
            { cursor = "•", texthl = "SmoothCursorOrange11" },
            { cursor = "·", texthl = "SmoothCursorOrange11" },
          }
        },
        speed = 40,
        intervals = 50,
        threshold = 0.5,
      })
      vim.notify("🔥 Slow mode (smear-like)", vim.log.levels.INFO)
    end, { desc = 'Slow mode' })

    vim.keymap.set('n', '<leader>ts', ':SmoothCursorToggle<CR>', { desc = 'Toggle Smooth Cursor' })
  end,
}
