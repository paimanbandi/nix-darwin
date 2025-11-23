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
        callbacks = {
          on_enable = function(_, win)
            vim.wo[win].conceallevel = 2
            vim.wo[win].concealcursor = "c"
          end
        }
      })
    end
  },
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
      },
      heading = {
        sign = false,
        icons = {}
      },
    },
    ft = { "markdown", "mermaid" },
  },
  {
    "iamcco/markdown-preview.nvim",
    keys = {
      { "<leader>mp", "<cmd>MarkdownPreview<cr>",       desc = "Mermaid/Markdown Preview" },
      { "<leader>ms", "<cmd>MarkdownPreviewStop<cr>",   desc = "Stop Mermaid Preview" },
      { "<leader>mt", "<cmd>MarkdownPreviewToggle<cr>", desc = "Toggle Mermaid Preview" },
      {
        "<leader>me",
        function()
          -- Cari mermaid block
          local start_line = vim.fn.search("```mermaid", "bnW")
          local end_line = vim.fn.search("```", "nW")

          if start_line > 0 and end_line > 0 then
            -- Ambil lines mermaid (skip ```mermaid line)
            local lines = vim.api.nvim_buf_get_lines(0, start_line, end_line - 1, false)

            -- Temporary file
            local temp_file = "/tmp/mermaid_temp.mmd"
            local output_file = vim.fn.expand("%:p:h") .. "/diagram_" .. os.time() .. ".png"

            -- Write to temp file
            vim.fn.writefile(lines, temp_file)

            -- Export dengan mmdc (sudah ada di Nix)
            local cmd = string.format(
              "mmdc -i %s -o %s -t dark -b transparent --scale 3 --width 2400 --height 2400",
              temp_file,
              output_file
            )

            vim.fn.system(cmd)

            if vim.v.shell_error == 0 then
              vim.notify("Exported to: " .. output_file, vim.log.levels.INFO)
              -- Optional: buka file dengan preview
              vim.fn.system("open " .. output_file)
            else
              vim.notify("Export failed!", vim.log.levels.ERROR)
            end
          else
            vim.notify("No mermaid block found at cursor", vim.log.levels.WARN)
          end
        end,
        desc = "Export Mermaid Block to PNG"
      },
      {
        "<leader>mE",
        function()
          -- Export whole file (semua mermaid blocks)
          local file = vim.fn.expand('%:p')
          local output_dir = vim.fn.expand("%:p:h") .. "/diagrams"

          -- Create diagrams directory
          vim.fn.mkdir(output_dir, "p")

          local output_file = output_dir .. "/" .. vim.fn.expand("%:t:r") .. "_" .. os.time() .. ".png"

          local cmd = string.format(
            "mmdc -i %s -o %s -t dark -b transparent --scale 4 --width 3000 --height 3000",
            file,
            output_file
          )

          vim.notify("Exporting full document...", vim.log.levels.INFO)
          vim.fn.system(cmd)

          if vim.v.shell_error == 0 then
            vim.notify("Exported to: " .. output_file, vim.log.levels.INFO)
            vim.fn.system("open " .. output_file)
          else
            vim.notify("Export failed!", vim.log.levels.ERROR)
          end
        end,
        desc = "Export All Mermaid to PNG (High Quality)"
      },
      {
        "<leader>ml",
        function()
          -- Open in Mermaid Live Editor
          local start_line = vim.fn.search("```mermaid", "bnW")
          local end_line = vim.fn.search("```", "nW")

          if start_line > 0 and end_line > 0 then
            local lines = vim.api.nvim_buf_get_lines(0, start_line, end_line - 1, false)
            local content = table.concat(lines, "\n")

            -- Base64 encode
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
