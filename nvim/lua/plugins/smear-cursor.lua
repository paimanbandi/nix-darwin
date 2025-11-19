return {
  "sphantix/smear-cursor.nvim",
  event = "VeryLazy",
  config = function()
    require("smear_cursor").setup({
      -- Cursor color (fire orange)
      cursor_color = "#ff4500",

      -- Normal mode cursor color (bisa beda per mode)
      normal_bg = "#ff4500",
      insert_bg = "#ffd700", -- Kuning saat insert mode
      visual_bg = "#ff0000", -- Merah saat visual mode

      -- Smear settings
      smear_between_buffers = true,
      smear_between_neighbor_lines = true,

      -- Trail behavior
      stiffness = 0.6, -- Adjust ini untuk trail length (0.1 = panjang, 1.0 = pendek)
      trailing_stiffness = 0.3,
      trailing_exponent = 0.1,

      -- Smoothness
      gamma = 1.0,

      -- Performance
      legacy_computing_symbols_support = false,
      hide_target_hack = false,
    })

    -- Custom highlights untuk fire effect
    vim.cmd([[
      highlight SmearCursor guibg=#ff4500 guifg=#ffffff gui=bold
      highlight SmearCursorInsert guibg=#ffd700 guifg=#000000 gui=bold
      highlight SmearCursorVisual guibg=#ff0000 guifg=#ffffff gui=bold
    ]])

    -- Keybindings
    vim.keymap.set('n', '<leader>ts', function()
      require('smear_cursor').toggle()
      vim.notify(
        vim.g.smear_cursor_enabled and "Smear cursor enabled" or "Smear cursor disabled",
        vim.log.levels.INFO
      )
    end, { desc = 'Toggle Smear Cursor' })
  end,
}
