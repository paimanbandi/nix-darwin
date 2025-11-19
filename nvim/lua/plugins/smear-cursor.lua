return {
  "sphamba/smear-cursor.nvim",
  event = "VeryLazy",
  config = function()
    require("smear_cursor").setup({
      -- Cursor colors (fire theme)
      cursor_color = "#ff0000",
      normal_bg = "#ff0000",
      insert_bg = "#ffd700",
      visual_bg = "#ff0000",

      -- Smear behavior
      smear_between_buffers = true,
      smear_between_neighbor_lines = true,

      -- Settings
      stiffness = 0.5,
      trailing_stiffness = 0.25,
      trailing_exponent = 0.1,
      gamma = 1.2,
      distance_stop_animating = 0.05,
      hide_target_hack = false,
      legacy_computing_symbols_support = false,
    })

    -- Fire gradient highlights
    vim.cmd([[
      highlight SmearCursor guibg=#ff0000 guifg=#ffffff gui=NONE blend=40
      highlight SmearCursorInsert guibg=#ffd700 guifg=#000000 gui=NONE blend=40
      highlight SmearCursorVisual guibg=#ff0000 guifg=#ffffff gui=NONE blend=40

      highlight Cursor guibg=#ff0000 guifg=#ffffff gui=NONE
    ]])

    vim.keymap.set('n', '<leader>ts', function()
      require('smear_cursor').toggle()
    end, { desc = 'Toggle Smear Cursor' })
  end,
}
