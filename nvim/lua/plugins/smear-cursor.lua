return {
  "sphamba/smear-cursor.nvim",
  event = "VeryLazy",
  config = function()
    require("smear_cursor").setup({
      -- Cursor colors (fire theme)
      cursor_color = "#ff4500",
      normal_bg = "#ff4500",
      insert_bg = "#ffd700",
      visual_bg = "#ff0000",

      -- Smear behavior
      smear_between_buffers = true,
      smear_between_neighbor_lines = true,

      -- SMOOTH SETTINGS
      stiffness = 0.4,           -- Lower = trail lebih panjang & smooth (default: 0.6)
      trailing_stiffness = 0.15, -- Lower = fade out lebih gradual (default: 0.3)
      trailing_exponent = 0.05,  -- Lower = trail lebih halus (default: 0.1)

      -- Smoothness & quality
      gamma = 1.2, -- Slightly higher = smoother gradient (default: 1.0)

      -- Distance calculation
      distance_stop_animating = 0.05, -- Lower = animasi lebih sering (default: 0.1)

      -- Hide cursor saat idle (opsional)
      hide_target_hack = false,

      -- Legacy support
      legacy_computing_symbols_support = false,
    })

    -- Enhanced fire gradient highlights
    vim.cmd([[
      " Normal mode - Orange fire
      highlight SmearCursor guibg=#ff4500 guifg=#ffffff gui=bold blend=30

      " Insert mode - Yellow/gold flame
      highlight SmearCursorInsert guibg=#ffd700 guifg=#000000 gui=bold blend=30

      " Visual mode - Red hot flame
      highlight SmearCursorVisual guibg=#ff0000 guifg=#ffffff gui=bold blend=30

      " Optional: Custom cursor line untuk tambah efek
      highlight CursorLine guibg=#1a1a2e blend=20
      highlight CursorLineNr guifg=#ff4500 gui=bold
    ]])

    -- Keybindings untuk adjust smoothness on-the-fly
    vim.keymap.set('n', '<leader>t1', function()
      -- Subtle mode (trail pendek)
      require('smear_cursor').setup({
        stiffness = 0.7,
        trailing_stiffness = 0.4,
        trailing_exponent = 0.2,
      })
      vim.notify("Smear: Subtle mode", vim.log.levels.INFO)
    end, { desc = 'Smear: Subtle' })

    vim.keymap.set('n', '<leader>t2', function()
      -- Balanced mode (default smooth)
      require('smear_cursor').setup({
        stiffness = 0.4,
        trailing_stiffness = 0.15,
        trailing_exponent = 0.05,
      })
      vim.notify("Smear: Balanced mode", vim.log.levels.INFO)
    end, { desc = 'Smear: Balanced' })

    vim.keymap.set('n', '<leader>t3', function()
      -- Dramatic mode (trail panjang banget!)
      require('smear_cursor').setup({
        stiffness = 0.2,
        trailing_stiffness = 0.05,
        trailing_exponent = 0.01,
      })
      vim.notify("Smear: Dramatic mode", vim.log.levels.INFO)
    end, { desc = 'Smear: Dramatic' })

    vim.keymap.set('n', '<leader>ts', function()
      require('smear_cursor').toggle()
      vim.notify("Smear cursor toggled", vim.log.levels.INFO)
    end, { desc = 'Toggle Smear Cursor' })
  end,
}
