-- ~/.config/nvim/lua/plugins/markdown.lua
return {
  {
    "OXY2DEV/markview.nvim",
    lazy = false,
    dependencies = {
      "nvim-treesitter/nvim-treesitter",
      "nvim-tree/nvim-web-devicons"
    },
    config = function()
      require("markview").setup({
        modes = { "n", "no", "c" },
        hybrid_modes = { "n" },

        -- Heading styles
        headings = {
          enable = true,
          shift_width = 0,
          heading_1 = {
            style = "icon",
            icon = "󰼏  ",
            hl = "MarkviewHeading1"
          },
          heading_2 = {
            style = "icon",
            icon = "󰎨  ",
            hl = "MarkviewHeading2"
          },
          heading_3 = {
            style = "icon",
            icon = "󰼑  ",
            hl = "MarkviewHeading3"
          },
        },

        -- Code blocks
        code_blocks = {
          enable = true,
          style = "language",
          pad_amount = 1,
        },

        -- Checkboxes
        checkboxes = {
          enable = true,
          checked = { text = "✔", hl = "MarkviewCheckboxChecked" },
          unchecked = { text = "✘", hl = "MarkviewCheckboxUnchecked" },
          pending = { text = "⏳", hl = "MarkviewCheckboxPending" },
        },

        -- Horizontal rules
        horizontal_rules = {
          enable = true,
        },

        -- Links
        links = {
          enable = true,
          hyperlinks = {
            icon = "🔗 ",
          },
        },

        callbacks = {
          on_enable = function(_, win)
            vim.wo[win].conceallevel = 2
            vim.wo[win].concealcursor = "c"
          end
        },

        -- HAPUS buf_ignore - biar AI docs juga di-render
      })

      -- Keybindings
      vim.keymap.set("n", "<leader>mw", "<cmd>Markview toggle<cr>", { desc = "Toggle Markview" })
      vim.keymap.set("n", "<leader>mwe", "<cmd>Markview enableAll<cr>", { desc = "Enable Markview" })
      vim.keymap.set("n", "<leader>mwd", "<cmd>Markview disableAll<cr>", { desc = "Disable Markview" })
    end
  },

  {
    "iamcco/markdown-preview.nvim",
    keys = {
      { "<leader>mp", "<cmd>MarkdownPreview<cr>",       desc = "Markdown Preview" },
      { "<leader>ms", "<cmd>MarkdownPreviewStop<cr>",   desc = "Stop Preview" },
      { "<leader>mt", "<cmd>MarkdownPreviewToggle<cr>", desc = "Toggle Preview" },
      {
        "<leader>ml",
        function()
          local start_line = vim.fn.search("```mermaid", "bnW")
          local end_line = vim.fn.search("```", "nW")
          if start_line > 0 and end_line > 0 then
            local lines = vim.api.nvim_buf_get_lines(0, start_line, end_line - 1, false)
            local content = table.concat(lines, "\n")
            local encoded = vim.fn.system('echo "' .. content:gsub('"', '\\"') .. '" | base64')
            encoded = encoded:gsub("\n", "")
            local url = "https://mermaid.live/edit#pako:eNp" .. encoded
            vim.fn.system("open '" .. url .. "'")
            vim.notify("Opening in Mermaid Live...", vim.log.levels.INFO)
          else
            vim.notify("No mermaid block found at cursor", vim.log.levels.WARN)
          end
        end,
        desc = "Open Mermaid in Live Editor"
      },
    },
    build = function()
      vim.fn["mkdp#util#install"]()
    end,
    ft = { "markdown", "mermaid" },
    config = function()
      vim.g.mkdp_theme = 'dark'
      vim.g.mkdp_auto_start = 0
      vim.g.mkdp_auto_close = 1
      vim.g.mkdp_refresh_slow = 0
      vim.g.mkdp_command_for_global = 0
      vim.g.mkdp_open_to_the_world = 0
      vim.g.mkdp_browser = ''
      vim.g.mkdp_echo_preview_url = 1
      vim.g.mkdp_preview_options = {
        mkit = {},
        katex = {},
        uml = {},
        maid = {
          theme = 'dark',
        },
        disable_sync_scroll = 0,
        sync_scroll_type = 'middle',
        hide_yaml_meta = 1,
        sequence_diagrams = {},
        flowchart_diagrams = {},
        content_editable = false,
      }
    end
  }
}
