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

  -- 4. Colorful winsep - Smooth window borders
  {
    "nvim-zh/colorful-winsep.nvim",
    event = "WinNew",
    config = function()
      require("colorful-winsep").setup({
        highlight = {
          bg = "#16161E",
          fg = "#ff4500",
        },
        -- Smooth animation
        interval = 20, -- Lower = smoother
        no_exec_files = {
          "packer", "TelescopePrompt", "mason", "NvimTree",
        },
        symbols = { "─", "│", "╭", "╮", "╰", "╯" }, -- Rounded corners!
        smooth = true,
      })
    end,
  },

  -- 5. Nvim-notify - Smooth notifications
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

  -- 6. Noice - Ultra smooth UI
  {
    "folke/noice.nvim",
    event = "VeryLazy",
    dependencies = {
      "MunifTanjim/nui.nvim",
      "rcarriga/nvim-notify",
    },
    config = function()
      require("noice").setup({
        lsp = {
          override = {
            ["vim.lsp.util.convert_input_to_markdown_lines"] = true,
            ["vim.lsp.util.stylize_markdown"] = true,
            ["cmp.entry.get_documentation"] = true,
          },
        },
        presets = {
          bottom_search = true,
          command_palette = true,
          long_message_to_split = true,
          inc_rename = false,
          lsp_doc_border = true,
        },
        views = {
          cmdline_popup = {
            position = {
              row = 5,
              col = "50%",
            },
            size = {
              width = 60,
              height = "auto",
            },
            border = {
              style = "rounded", -- Rounded = gak kotak!
              padding = { 0, 1 },
            },
            win_options = {
              winhighlight = {
                Normal = "Normal",
                FloatBorder = "DiagnosticInfo",
              },
              winblend = 20, -- Transparency
            },
          },
          popupmenu = {
            relative = "editor",
            position = {
              row = 8,
              col = "50%",
            },
            size = {
              width = 60,
              height = 10,
            },
            border = {
              style = "rounded",
              padding = { 0, 1 },
            },
            win_options = {
              winhighlight = {
                Normal = "Normal",
                FloatBorder = "DiagnosticInfo",
              },
              winblend = 20,
            },
          },
        },
      })
    end,
  },
}
