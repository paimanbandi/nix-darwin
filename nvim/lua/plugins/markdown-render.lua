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
      vim.keymap.set("n", "<leader>mr", "<cmd>RenderMarkdown toggle<cr>", { desc = "Toggle Render Markdown" })
      vim.keymap.set("n", "<leader>me", "<cmd>RenderMarkdown enable<cr>", { desc = "Enable Render Markdown" })
      vim.keymap.set("n", "<leader>md", "<cmd>RenderMarkdown disable<cr>", { desc = "Disable Render Markdown" })
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
    cmd = { "MarkdownPreview", "MarkdownPreviewStop", "MarkdownPreviewToggle" },
    ft = { "markdown", "mermaid" },
    build = "cd app && npx --yes yarn install",
    init = function()
      vim.g.mkdp_theme = 'dark'
      vim.g.mkdp_auto_start = 0
      vim.g.mkdp_auto_close = 1
      vim.g.mkdp_refresh_slow = 0
      vim.g.mkdp_command_for_global = 0
      vim.g.mkdp_open_to_the_world = 0
      vim.g.mkdp_browser = ''
      vim.g.mkdp_echo_preview_url = 1

      -- ⬇️ MATIKAN sync scroll — ini biang keroknya
      -- Ketika kita klik anchor link, sync scroll langsung "tarik" balik
      -- ke posisi cursor di nvim. Jadi scroll ke section gagal.
      vim.g.mkdp_preview_options = {
        mkit = {},
        katex = {},
        uml = {},
        maid = {
          theme = 'dark',
        },
        disable_sync_scroll = 1,       -- ⬅️ DIUBAH: 0 → 1 (matikan sync scroll)
        sync_scroll_type = 'relative', -- ⬅️ DIUBAH: 'middle' → 'relative' (fallback kalau di-enable lagi)
        hide_yaml_meta = 1,
        sequence_diagrams = {},
        flowchart_diagrams = {},
        content_editable = false,
        disable_filename = 0,
        toc = {} -- ⬅️ DITAMBAH: enable TOC anchor support
      }

      -- ⬇️ DITAMBAH: custom CSS untuk smooth scroll + scroll-margin
      -- supaya heading gak ketutup di atas saat anchor di-klik
      vim.g.mkdp_markdown_css = vim.fn.expand("~/.config/nvim/markdown-preview.css")

      vim.api.nvim_create_autocmd("FileType", {
        pattern = { "markdown", "mermaid" },
        callback = function(args)
          local buf = args.buf
          vim.keymap.set("n", "<leader>mp", "<cmd>MarkdownPreview<cr>",
            { buffer = buf, desc = "Markdown Preview", silent = true })
          vim.keymap.set("n", "<leader>ms", "<cmd>MarkdownPreviewStop<cr>",
            { buffer = buf, desc = "Stop Preview", silent = true })
          vim.keymap.set("n", "<leader>mt", "<cmd>MarkdownPreviewToggle<cr>",
            { buffer = buf, desc = "Toggle Preview", silent = true })

          -- ⬇️ DITAMBAH: toggle sync scroll on-demand
          -- Kadang kita pengen sync scroll nyala lagi (saat editing)
          -- Kadang pengen mati (saat navigasi via TOC)
          vim.keymap.set("n", "<leader>mc", function()
            if vim.g.mkdp_preview_options.disable_sync_scroll == 1 then
              vim.g.mkdp_preview_options.disable_sync_scroll = 0
              vim.notify("Sync scroll: ON", vim.log.levels.INFO)
            else
              vim.g.mkdp_preview_options.disable_sync_scroll = 1
              vim.notify("Sync scroll: OFF (TOC links akan work)", vim.log.levels.INFO)
            end
          end, { buffer = buf, desc = "Toggle Sync Scroll", silent = true })

          vim.keymap.set("n", "<leader>ml", function()
            local start_line = vim.fn.search("```mermaid", "bnW")
            local end_line = vim.fn.search("```", "nW")
            if start_line > 0 and end_line > 0 then
              local lines = vim.api.nvim_buf_get_lines(0, start_line, end_line - 1, false)
              local content = table.concat(lines, "\n")
              local encoded = vim.fn.system('echo "' .. content:gsub('"', '\\"') .. '" | base64')
              encoded = encoded:gsub("\n", "")
              local url = "https://mermaid.live/edit#pako:" .. encoded
              vim.fn.system("open '" .. url .. "'")
              vim.notify("Opening in Mermaid Live...", vim.log.levels.INFO)
            else
              vim.notify("No mermaid block found at cursor", vim.log.levels.WARN)
            end
          end, { buffer = buf, desc = "Open Mermaid in Live Editor", silent = true })
        end,
      })
    end,
  }
}
