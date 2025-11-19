return {
  -- Smear cursor untuk cursor utama
  {
    "sphamba/smear-cursor.nvim",
    event = "VeryLazy",
    config = function()
      require("smear_cursor").setup({
        cursor_color = "#ff0000",
        normal_bg = "#ff0000",
        insert_bg = "#ffd700",
        visual_bg = "#ff0000",

        smear_between_buffers = true,
        smear_between_neighbor_lines = true,

        stiffness = 0.45,
        trailing_stiffness = 0.2,
        trailing_exponent = 0.08,
        gamma = 1.3,
        distance_stop_animating = 0.03,

        hide_target_hack = false,
        legacy_computing_symbols_support = false,
      })

      vim.cmd([[
        highlight SmearCursor guibg=#ff0000 guifg=#ffffff gui=NONE blend=45
        highlight SmearCursorInsert guibg=#ffd700 guifg=#000000 gui=NONE blend=45
        highlight SmearCursorVisual guibg=#ff0000 guifg=#ffffff gui=NONE blend=45
        highlight Cursor guibg=#ff0000 guifg=#ffffff gui=NONE
        highlight CursorLineNr guifg=#ff4500 gui=bold
      ]])

      vim.keymap.set('n', '<leader>ts', function()
        require('smear_cursor').toggle()
      end, { desc = 'Toggle Smear' })
    end,
  },

  -- Hybrid trail di MARGIN KIRI (FAST VERSION!)
  {
    "luukvbaal/statuscol.nvim",
    event = "VeryLazy",
    config = function()
      -- Trail state (global untuk fast access)
      _G.gutter_trail = {}
      local max_len = 12
      local last_line = 0

      local function get_trail_symbol(index)
        -- Hybrid symbols: blocks → shades → circles → dots
        if index == 1 then
          return "█", "GutterRed"
        elseif index == 2 then
          return "█", "GutterOrange"
        elseif index == 3 then
          return "▓", "GutterOrange2"
        elseif index == 4 then
          return "▒", "GutterOrange3"
        elseif index == 5 then
          return "●", "GutterOrange4"
        elseif index == 6 then
          return "○", "GutterOrange5"
        elseif index == 7 then
          return "•", "GutterOrange6"
        else
          return "·", "GutterOrange7"
        end
      end

      -- FAST UPDATE: Update trail immediately on cursor move
      vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI" }, {
        callback = function()
          local cur = vim.fn.line('.')

          -- Only update if line changed
          if cur ~= last_line then
            last_line = cur

            -- Update trail immediately
            table.insert(_G.gutter_trail, 1, cur)

            -- Keep max length
            while #_G.gutter_trail > max_len do
              table.remove(_G.gutter_trail)
            end

            -- Force redraw statuscolumn (FAST!)
            vim.cmd('redrawstatus')
          end
        end,
      })

      vim.api.nvim_create_autocmd("BufEnter", {
        callback = function()
          _G.gutter_trail = {}
          last_line = 0
        end,
      })

      -- Fire gradient colors
      vim.cmd([[
        highlight GutterRed guifg=#ff0000 gui=bold
        highlight GutterOrange guifg=#ff1010 gui=NONE
        highlight GutterOrange2 guifg=#ff2020 gui=NONE
        highlight GutterOrange3 guifg=#ff3030 gui=NONE
        highlight GutterOrange4 guifg=#ff4545 gui=NONE
        highlight GutterOrange5 guifg=#ff5a5a gui=NONE
        highlight GutterOrange6 guifg=#ff6f6f gui=NONE
        highlight GutterOrange7 guifg=#ff8484 gui=NONE
      ]])

      local builtin = require("statuscol.builtin")
      require("statuscol").setup({
        relculright = true,
        segments = {
          -- TRAIL DI MARGIN PALING KIRI (sebelum line number)
          {
            text = {
              function(args)
                local line = args.lnum
                local trail = _G.gutter_trail or {}

                -- Check if line is in trail (FAST lookup)
                for i, tline in ipairs(trail) do
                  if line == tline then
                    local sym, hl = get_trail_symbol(i)
                    return sym
                  end
                end

                return " " -- Space kalau gak ada trail
              end,
              " "          -- Extra space after symbol
            },
            condition = { true },
            click = "v:lua.ScLa",
          },
          -- LINE NUMBERS (setelah trail)
          {
            text = { builtin.lnumfunc, " " },
            condition = { true, builtin.not_empty },
            click = "v:lua.ScLa",
          },
          -- SIGNS (git, diagnostics, dll)
          {
            sign = {
              namespace = { ".*" },
              maxwidth = 1,
              colwidth = 2,
              auto = false,
            },
            click = "v:lua.ScSa",
          },
        },
      })

      vim.cmd([[
        highlight LineNr guifg=#666666 gui=NONE
        highlight CursorLineNr guifg=#ff0000 gui=bold
      ]])

      -- Keybindings untuk adjust trail
      vim.keymap.set('n', '<leader>t1', function()
        max_len = 6
        _G.gutter_trail = {}
        vim.notify("Trail: Short (6)", vim.log.levels.INFO)
      end, { desc = 'Short Trail' })

      vim.keymap.set('n', '<leader>t2', function()
        max_len = 10
        _G.gutter_trail = {}
        vim.notify("Trail: Medium (10)", vim.log.levels.INFO)
      end, { desc = 'Medium Trail' })

      vim.keymap.set('n', '<leader>t3', function()
        max_len = 14
        _G.gutter_trail = {}
        vim.notify("Trail: Long (14)", vim.log.levels.INFO)
      end, { desc = 'Long Trail' })
    end,
  },
}
