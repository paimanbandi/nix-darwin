return {
  -- SmoothCursor untuk animasi di gutter (line numbers)
  {
    "gen740/SmoothCursor.nvim",
    event = "VeryLazy",
    config = function()
      require('smoothcursor').setup({
        type = "default",
        cursor = "",           -- Cursor utama invisible (pakai smear-cursor)
        texthl = "SmoothCursor",
        linehl = "CursorLine", -- PENTING: Animate line highlight!

        fancy = {
          enable = true,
          head = {
            cursor = "", -- Kosong, biar gak double dengan smear
            texthl = "SmoothCursorHead",
            linehl = nil
          },
          body = {
            -- Trail di gutter (symbols kecil di sebelah line number)
            { cursor = "", texthl = "SmoothCursorRed",     linehl = "SmoothLine1" },
            { cursor = "", texthl = "SmoothCursorOrange",  linehl = "SmoothLine2" },
            { cursor = "", texthl = "SmoothCursorOrange2", linehl = "SmoothLine3" },
          },
          tail = { cursor = nil, texthl = "SmoothCursor" }
        },

        autostart = true,
        always_redraw = true,
        flyin_effect = nil,
        speed = 20,
        intervals = 30,
        priority = 10,
        timeout = 3000,
        threshold = 2,
      })

      -- Colors untuk gutter animation
      vim.api.nvim_set_hl(0, "SmoothCursor", { fg = "NONE", bg = "NONE" })
      vim.api.nvim_set_hl(0, "SmoothCursorHead", { fg = "NONE", bg = "NONE" })
      vim.api.nvim_set_hl(0, "SmoothCursorRed", { fg = "NONE", bg = "NONE" })
      vim.api.nvim_set_hl(0, "SmoothCursorOrange", { fg = "NONE", bg = "NONE" })
      vim.api.nvim_set_hl(0, "SmoothCursorOrange2", { fg = "NONE", bg = "NONE" })

      -- Line highlight untuk gutter (subtle glow effect)
      vim.api.nvim_set_hl(0, "SmoothLine1", { bg = "#2a1a1a" })
      vim.api.nvim_set_hl(0, "SmoothLine2", { bg = "#1f1515" })
      vim.api.nvim_set_hl(0, "SmoothLine3", { bg = "#1a1010" })
    end,
  },

  -- Animated line number di gutter
  {
    "lukas-reineke/virt-column.nvim",
    event = "VeryLazy",
    config = function()
      require("virt-column").setup()
    end,
  },
}
