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

      -- INSANE SMOOTH SETTINGS! 🔥
      stiffness = 0.15,          -- Super low = trail panjang banget & ultra smooth
      trailing_stiffness = 0.05, -- Fade out super gradual
      trailing_exponent = 0.01,  -- Curve super halus kayak air

      -- Smoothness maximum
      gamma = 1.5, -- Higher = gradient super smooth

      -- Distance sensitivity
      distance_stop_animating = 0.01, -- Super sensitive = animasi terus menerus

      -- Hide cursor saat idle
      hide_target_hack = false,

      -- Legacy support
      legacy_computing_symbols_support = false,
    })

    -- Ultra smooth fire gradient highlights dengan transparency
    vim.cmd([[
      " Normal mode - Orange fire dengan blur effect
      highlight SmearCursor guibg=#ff4500 guifg=#ffffff gui=bold blend=40

      " Insert mode - Yellow/gold flame
      highlight SmearCursorInsert guibg=#ffd700 guifg=#000000 gui=bold blend=40

      " Visual mode - Red hot flame
      highlight SmearCursorVisual guibg=#ff0000 guifg=#ffffff gui=bold blend=40

      " Cursor styling untuk rounded look (gak kotak)
      highlight Cursor guibg=#ff4500 guifg=#ffffff gui=NONE blend=0
      highlight CursorLine guibg=NONE blend=0
      highlight CursorLineNr guifg=#ff4500 gui=bold

      " Terminal cursor shape untuk rounded
      set guicursor=n-v-c:block-Cursor/lCursor,i-ci-ve:ver25-Cursor/lCursor,r-cr:hor20-Cursor/lCursor
    ]])

    -- Advanced keybindings
    vim.keymap.set('n', '<leader>t0', function()
      -- INSANE mode (trail gila-gilaan!)
      require('smear_cursor').setup({
        stiffness = 0.08,
        trailing_stiffness = 0.02,
        trailing_exponent = 0.005,
        gamma = 2.0,
        distance_stop_animating = 0.005,
      })
      vim.notify("🔥 INSANE MODE ACTIVATED! 🔥", vim.log.levels.WARN)
    end, { desc = 'Smear: INSANE Mode' })

    vim.keymap.set('n', '<leader>t1', function()
      -- Subtle mode
      require('smear_cursor').setup({
        stiffness = 0.7,
        trailing_stiffness = 0.4,
        trailing_exponent = 0.2,
        gamma = 1.0,
        distance_stop_animating = 0.1,
      })
      vim.notify("Smear: Subtle mode", vim.log.levels.INFO)
    end, { desc = 'Smear: Subtle' })

    vim.keymap.set('n', '<leader>t2', function()
      -- Ultra smooth mode (recommended)
      require('smear_cursor').setup({
        stiffness = 0.15,
        trailing_stiffness = 0.05,
        trailing_exponent = 0.01,
        gamma = 1.5,
        distance_stop_animating = 0.01,
      })
      vim.notify("✨ Ultra Smooth mode", vim.log.levels.INFO)
    end, { desc = 'Smear: Ultra Smooth' })

    vim.keymap.set('n', '<leader>ts', function()
      require('smear_cursor').toggle()
    end, { desc = 'Toggle Smear Cursor' })
  end,
}
