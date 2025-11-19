return {
  "sphamba/smear-cursor.nvim",
  event = "VeryLazy",
  config = function()
    require("smear_cursor").setup({
      -- Cursor colors
      cursor_color = "#ff0000",
      normal_bg = "#ff0000",
      insert_bg = "#ffd700",
      visual_bg = "#ff0000",

      -- Smear behavior
      smear_between_buffers = true,
      smear_between_neighbor_lines = true,

      -- OPTIMIZED SETTINGS untuk best slow motion effect!
      stiffness = 0.4,                -- Lower = longer trail, better slow motion
      trailing_stiffness = 0.18,      -- Lower = smoother fade
      trailing_exponent = 0.06,       -- Lower = more natural curve
      gamma = 1.4,                    -- Higher = smoother gradient
      distance_stop_animating = 0.02, -- Lower = more sensitive

      hide_target_hack = false,
      legacy_computing_symbols_support = false,
    })

    -- OPTIMIZED HIGHLIGHTS untuk less blocky
    vim.cmd([[
      " HIGH BLEND untuk kurangi blocky appearance
      highlight SmearCursor guibg=#ff0000 guifg=#ffffff gui=NONE blend=50
      highlight SmearCursorInsert guibg=#ffd700 guifg=#000000 gui=NONE blend=50
      highlight SmearCursorVisual guibg=#ff0000 guifg=#ffffff gui=NONE blend=50

      " Cursor styling
      highlight Cursor guibg=#ff0000 guifg=#ffffff gui=NONE
      highlight CursorLineNr guifg=#ff4500 gui=bold

      " Optional: Add slight transparency to background
      highlight Normal guibg=NONE ctermbg=NONE
    ]])

    -- Keybindings untuk adjust slow motion
    vim.keymap.set('n', '<leader>t1', function()
      -- Subtle slow motion (fast)
      require('smear_cursor').setup({
        stiffness = 0.6,
        trailing_stiffness = 0.3,
        trailing_exponent = 0.15,
        gamma = 1.0,
        distance_stop_animating = 0.1,
      })
      vim.notify("⚡ Subtle slow motion", vim.log.levels.INFO)
    end, { desc = 'Subtle Slow Motion' })

    vim.keymap.set('n', '<leader>t2', function()
      -- Balanced slow motion (recommended)
      require('smear_cursor').setup({
        stiffness = 0.4,
        trailing_stiffness = 0.18,
        trailing_exponent = 0.06,
        gamma = 1.4,
        distance_stop_animating = 0.02,
      })
      vim.notify("✨ Balanced slow motion", vim.log.levels.INFO)
    end, { desc = 'Balanced Slow Motion' })

    vim.keymap.set('n', '<leader>t3', function()
      -- EXTREME slow motion (dramatic!)
      require('smear_cursor').setup({
        stiffness = 0.25,
        trailing_stiffness = 0.1,
        trailing_exponent = 0.02,
        gamma = 1.8,
        distance_stop_animating = 0.01,
      })
      vim.notify("🔥 EXTREME slow motion!", vim.log.levels.WARN)
    end, { desc = 'EXTREME Slow Motion' })

    vim.keymap.set('n', '<leader>ts', function()
      require('smear_cursor').toggle()
    end, { desc = 'Toggle Smear' })
  end,
}
