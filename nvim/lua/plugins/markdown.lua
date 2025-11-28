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
        disable_background = { "mermaid" },
        highlight = "",
      },
      heading = {
        sign = false,
        icons = {}
      },
    },
    ft = { "markdown", "mermaid" },
    config = function(_, opts)
      require("render-markdown").setup(opts)

      vim.api.nvim_set_hl(0, "RenderMarkdownCode", {
        fg = "#7aa2f7",
        bg = "NONE"
      })

      vim.api.nvim_set_hl(0, "RenderMarkdownCodeInline", {
        fg = "#7aa2f7",
        bg = "NONE"
      })

      vim.api.nvim_set_hl(0, "ColorColumn", {
        bg = "#1a1b26"
      })

      vim.api.nvim_create_autocmd("ColorScheme", {
        callback = function()
          vim.schedule(function()
            vim.api.nvim_set_hl(0, "RenderMarkdownCode", {
              fg = "#7aa2f7",
              bg = "NONE"
            })
            vim.api.nvim_set_hl(0, "RenderMarkdownCodeInline", {
              fg = "#7aa2f7",
              bg = "NONE"
            })
          end)
        end,
      })
    end,
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
          local start_line = vim.fn.search("```mermaid", "bnW")
          local end_line = vim.fn.search("```", "nW")

          if start_line > 0 and end_line > 0 then
            local lines = vim.api.nvim_buf_get_lines(0, start_line, end_line - 1, false)
            local temp_file = "/tmp/mermaid_temp.mmd"
            local base_name = vim.fn.expand("%:t:r")
            local output_file = vim.fn.expand("%:p:h") .. "/" .. base_name .. ".png"

            vim.fn.writefile(lines, temp_file)

            local chrome_paths = {
              "/Applications/Google Chrome.app/Contents/MacOS/Google Chrome",
              "/Applications/Arc.app/Contents/MacOS/Arc",
              "/Applications/Brave Browser.app/Contents/MacOS/Brave Browser",
              vim.fn.expand(
                "~/.cache/puppeteer/chrome/mac_arm-*/chrome-mac-arm64/Google Chrome for Testing.app/Contents/MacOS/Google Chrome for Testing"),
            }

            local chrome_path = nil
            for _, path in ipairs(chrome_paths) do
              local expanded = vim.fn.glob(path)
              if expanded ~= "" and vim.fn.filereadable(expanded) == 1 then
                chrome_path = expanded
                break
              end
            end

            if not chrome_path then
              vim.notify("Chrome not found! Please install Chrome, Arc, or Brave browser", vim.log.levels.ERROR)
              vim.notify("Or run: npx puppeteer browsers install chrome", vim.log.levels.INFO)
              return
            end

            local cmd = string.format(
              "PUPPETEER_EXECUTABLE_PATH='%s' mmdc -i %s -o %s -t dark -b white --scale 5 --width 4000 --height 4000 2>&1",
              chrome_path,
              vim.fn.shellescape(temp_file),
              vim.fn.shellescape(output_file)
            )

            vim.notify("Exporting with Chrome at: " .. chrome_path, vim.log.levels.INFO)
            local output = vim.fn.system(cmd)

            if vim.v.shell_error == 0 then
              vim.notify("Exported to: " .. output_file, vim.log.levels.INFO)
              vim.fn.system("open " .. vim.fn.shellescape(output_file))
            else
              vim.notify("Export failed! Error: " .. output, vim.log.levels.ERROR)
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
          local file = vim.fn.expand('%:p')
          local output_dir = vim.fn.expand("%:p:h") .. "/diagrams"

          vim.fn.mkdir(output_dir, "p")

          local base_name = vim.fn.expand("%:t:r")
          local output_file = output_dir .. "/" .. base_name .. ".png"

          local cmd = string.format(
            "mmdc -i %s -o %s -t dark -b white --scale 6 --width 5000 --height 5000",
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
        "<leader>mv",
        function()
          local start_line = vim.fn.search("```mermaid", "bnW")
          local end_line = vim.fn.search("```", "nW")

          if start_line > 0 and end_line > 0 then
            local lines = vim.api.nvim_buf_get_lines(0, start_line, end_line - 1, false)
            local temp_file = "/tmp/mermaid_temp.mmd"
            local base_name = vim.fn.expand("%:t:r")
            local output_file = vim.fn.expand("%:p:h") .. "/" .. base_name .. ".svg"

            vim.fn.writefile(lines, temp_file)

            local chrome_paths = {
              "/Applications/Google Chrome.app/Contents/MacOS/Google Chrome",
              "/Applications/Arc.app/Contents/MacOS/Arc",
              "/Applications/Brave Browser.app/Contents/MacOS/Brave Browser",
              vim.fn.expand(
                "~/.cache/puppeteer/chrome/mac_arm-*/chrome-mac-arm64/Google Chrome for Testing.app/Contents/MacOS/Google Chrome for Testing"),
            }

            local chrome_path = nil
            for _, path in ipairs(chrome_paths) do
              local expanded = vim.fn.glob(path)
              if expanded ~= "" and vim.fn.filereadable(expanded) == 1 then
                chrome_path = expanded
                break
              end
            end

            if not chrome_path then
              vim.notify("Chrome not found! Please install Chrome, Arc, or Brave browser", vim.log.levels.ERROR)
              vim.notify("Or run: npx puppeteer browsers install chrome", vim.log.levels.INFO)
              return
            end

            local cmd = string.format(
              "PUPPETEER_EXECUTABLE_PATH='%s' mmdc -i %s -o %s -t dark -b transparent 2>&1",
              chrome_path,
              vim.fn.shellescape(temp_file),
              vim.fn.shellescape(output_file)
            )

            vim.notify("Exporting to SVG with Chrome at: " .. chrome_path, vim.log.levels.INFO)
            local output = vim.fn.system(cmd)

            if vim.v.shell_error == 0 then
              vim.notify("Exported to: " .. output_file, vim.log.levels.INFO)
              vim.fn.system("open " .. vim.fn.shellescape(output_file))
            else
              vim.notify("Export failed! Error: " .. output, vim.log.levels.ERROR)
            end
          else
            vim.notify("No mermaid block found at cursor", vim.log.levels.WARN)
          end
        end,
        desc = "Export Mermaid Block to SVG"
      },
      {
        "<leader>mV",
        function()
          local file = vim.fn.expand('%:p')
          local output_dir = vim.fn.expand("%:p:h") .. "/diagrams"

          vim.fn.mkdir(output_dir, "p")

          local base_name = vim.fn.expand("%:t:r")
          local output_file = output_dir .. "/" .. base_name .. ".svg"

          local chrome_paths = {
            "/Applications/Google Chrome.app/Contents/MacOS/Google Chrome",
            "/Applications/Arc.app/Contents/MacOS/Arc",
            "/Applications/Brave Browser.app/Contents/MacOS/Brave Browser",
            vim.fn.expand(
              "~/.cache/puppeteer/chrome/mac_arm-*/chrome-mac-arm64/Google Chrome for Testing.app/Contents/MacOS/Google Chrome for Testing"),
          }

          local chrome_path = nil
          for _, path in ipairs(chrome_paths) do
            local expanded = vim.fn.glob(path)
            if expanded ~= "" and vim.fn.filereadable(expanded) == 1 then
              chrome_path = expanded
              break
            end
          end

          if not chrome_path then
            vim.notify("Chrome not found! Please install Chrome, Arc, or Brave browser", vim.log.levels.ERROR)
            vim.notify("Or run: npx puppeteer browsers install chrome", vim.log.levels.INFO)
            return
          end

          local cmd = string.format(
            "PUPPETEER_EXECUTABLE_PATH='%s' mmdc -i %s -o %s -t dark -b transparent 2>&1",
            chrome_path,
            vim.fn.shellescape(file),
            vim.fn.shellescape(output_file)
          )

          vim.notify("Exporting full document to SVG...", vim.log.levels.INFO)
          local output = vim.fn.system(cmd)

          if vim.v.shell_error == 0 then
            vim.notify("Exported to: " .. output_file, vim.log.levels.INFO)
            vim.fn.system("open " .. vim.fn.shellescape(output_file))
          else
            vim.notify("Export failed! Error: " .. output, vim.log.levels.ERROR)
          end
        end,
        desc = "Export All Mermaid to SVG"
      },
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
