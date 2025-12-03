return {
  {
    "MeanderingProgrammer/render-markdown.nvim",
    dependencies = {
      "nvim-treesitter/nvim-treesitter",
      "nvim-tree/nvim-web-devicons"
    },
    opts = {
      code = {
        sign = false,
        width = 'block',
        right_pad = 1,
        disable_background = { "mermaid" },
      },
      heading = {
        sign = false,
        icons = { '# ', '## ', '### ', '#### ', '##### ', '###### ' },
        backgrounds = { 'DiffAdd', 'DiffChange', 'DiffDelete', 'Normal', 'Normal', 'Normal' },
        foregrounds = {
          'MarkdownH1',
          'MarkdownH2',
          'MarkdownH3',
          'MarkdownH4',
          'MarkdownH5',
          'MarkdownH6',
        },
      },
      bullet = {
        enabled = true,
        icons = { '•', '◦', '▸', '▹' },
      },
      checkbox = {
        enabled = true,
        unchecked = { icon = '☐ ' },
        checked = { icon = '☑ ' },
      },
    },
    ft = { "markdown" },
    config = function(_, opts)
      require("render-markdown").setup(opts)

      -- Keybindings
      vim.keymap.set("n", "<leader>mr", "<cmd>RenderMarkdown toggle<cr>", { desc = "Toggle Render Markdown" })
      vim.keymap.set("n", "<leader>me", "<cmd>RenderMarkdown enable<cr>", { desc = "Enable Render Markdown" })
      vim.keymap.set("n", "<leader>md", "<cmd>RenderMarkdown disable<cr>", { desc = "Disable Render Markdown" })

      -- Custom highlights
      vim.api.nvim_set_hl(0, "RenderMarkdownCode", {
        bg = "#1a1b26"
      })
      vim.api.nvim_set_hl(0, "RenderMarkdownCodeInline", {
        bg = "#24283b",
        fg = "#7aa2f7"
      })
    end,
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
