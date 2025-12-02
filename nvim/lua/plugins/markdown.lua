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
      {
        "<leader>mg",
        function()
          local filepath = vim.fn.expand('%:p')
          local filetype = vim.bo.filetype
          local filename = vim.fn.expand('%:t:r')
          local dir = vim.fn.expand('%:p:h')

          local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
          local code_content = table.concat(lines, "\n")

          local output_file = dir .. "/" .. filename .. "_diagram.md"

          vim.notify("Generating Mermaid diagram with Claude AI...", vim.log.levels.INFO)

          local prompt = string.format([[Analyze this %s code and create a comprehensive Mermaid diagram.

Requirements:
1. Use flowchart for process flows
2. Use classDiagram for object structures
3. Use sequenceDiagram for API calls or interactions
4. Apply beautiful color scheme using style definitions:
   - Blue for entry points: style NodeName fill:#4A90E2,stroke:#2E5C8A,stroke-width:3px,color:#fff
   - Green for success states: style NodeName fill:#50C878,stroke:#2D7A4A,stroke-width:3px,color:#fff
   - Red for errors: style NodeName fill:#E74C3C,stroke:#A93226,stroke-width:2px,color:#fff
   - Purple for database operations: style NodeName fill:#9B59B6,stroke:#6C3483,stroke-width:2px,color:#fff
   - Orange for decision points: style NodeName fill:#F39C12,stroke:#BA6F0A,stroke-width:2px,color:#fff
5. Make arrows clear and easy to follow
6. Include all important functions, classes, and flows
7. DO NOT use any icons or emoji in node labels
8. Use clear text labels only

Code to analyze:
```%s
%s
```

Return ONLY the mermaid code block(s) wrapped in ```mermaid```, no explanations before or after.]], filetype, filetype,
            code_content)

          local api_key = os.getenv("ANTHROPIC_API_KEY")

          if not api_key then
            vim.notify("ANTHROPIC_API_KEY not found! Set it in your environment", vim.log.levels.ERROR)
            vim.notify("Run: export ANTHROPIC_API_KEY='your-key-here'", vim.log.levels.INFO)
            return
          end

          local json_prompt = vim.fn.json_encode(prompt)
          json_prompt = json_prompt:gsub("'", "'\\''")

          local curl_cmd = string.format(
            [[curl -s https://api.anthropic.com/v1/messages -H "content-type: application/json" -H "x-api-key: %s" -H "anthropic-version: 2023-06-01" -d '{"model": "claude-sonnet-4-20250514", "max_tokens": 4096, "messages": [{"role": "user", "content": %s}]}']],
            api_key, json_prompt)

          vim.fn.jobstart(curl_cmd, {
            stdout_buffered = true,
            on_stdout = function(_, data)
              if data then
                local response = table.concat(data, "\n")
                local ok, json = pcall(vim.fn.json_decode, response)

                if ok and json.content and json.content[1] then
                  local mermaid_content = json.content[1].text

                  local md_content = string.format([[# %s - Generated Diagram

Generated from: %s
Date: %s

%s
]], filename, vim.fn.expand('%:t'), os.date("%Y-%m-%d %H:%M:%S"), mermaid_content)

                  local file = io.open(output_file, "w")
                  if file then
                    file:write(md_content)
                    file:close()

                    vim.notify("Diagram generated: " .. output_file, vim.log.levels.INFO)

                    vim.cmd("edit " .. vim.fn.fnameescape(output_file))

                    vim.schedule(function()
                      vim.cmd("MarkdownPreview")
                    end)
                  else
                    vim.notify("Failed to write file", vim.log.levels.ERROR)
                  end
                else
                  vim.notify("Failed to parse Claude response", vim.log.levels.ERROR)
                  if response then
                    print("Response:", response)
                  end
                end
              end
            end,
            on_stderr = function(_, data)
              if data and #data > 0 then
                local error_msg = table.concat(data, "\n")
                if error_msg ~= "" then
                  vim.notify("API Error: " .. error_msg, vim.log.levels.ERROR)
                end
              end
            end,
            on_exit = function(_, exit_code)
              if exit_code ~= 0 then
                vim.notify("Command failed with exit code: " .. exit_code, vim.log.levels.ERROR)
              end
            end
          })
        end,
        desc = "Generate Mermaid with Claude AI"
      },
      {
        "<leader>mG",
        function()
          local start_pos = vim.fn.getpos("'<")
          local end_pos = vim.fn.getpos("'>")

          if start_pos[2] == 0 or end_pos[2] == 0 then
            vim.notify("No selection found. Use visual mode first!", vim.log.levels.WARN)
            return
          end

          local lines = vim.api.nvim_buf_get_lines(0, start_pos[2] - 1, end_pos[2], false)
          local code_content = table.concat(lines, "\n")

          if code_content == "" then
            vim.notify("No selection found. Use visual mode first!", vim.log.levels.WARN)
            return
          end

          local filetype = vim.bo.filetype
          local dir = vim.fn.expand('%:p:h')
          local output_file = dir .. "/selection_diagram.md"

          vim.notify("Generating Mermaid from selection...", vim.log.levels.INFO)

          local prompt = string.format([[Analyze this %s code selection and create a focused Mermaid diagram.

Requirements:
1. Use flowchart for process flows
2. Use classDiagram for object structures
3. Use sequenceDiagram for API calls or interactions
4. Apply beautiful color scheme using style definitions:
   - Blue for entry points: style NodeName fill:#4A90E2,stroke:#2E5C8A,stroke-width:3px,color:#fff
   - Green for success states: style NodeName fill:#50C878,stroke:#2D7A4A,stroke-width:3px,color:#fff
   - Red for errors: style NodeName fill:#E74C3C,stroke:#A93226,stroke-width:2px,color:#fff
   - Purple for database operations: style NodeName fill:#9B59B6,stroke:#6C3483,stroke-width:2px,color:#fff
   - Orange for decision points: style NodeName fill:#F39C12,stroke:#BA6F0A,stroke-width:2px,color:#fff
5. Make arrows clear and easy to follow
6. Focus on the selected code logic
7. DO NOT use any icons or emoji in node labels
8. Use clear text labels only

Code selection to analyze:
```%s
%s
```

Return ONLY the mermaid code block(s) wrapped in ```mermaid```, no explanations before or after.]], filetype, filetype,
            code_content)

          local api_key = os.getenv("ANTHROPIC_API_KEY")

          if not api_key then
            vim.notify("ANTHROPIC_API_KEY not found! Set it in your environment", vim.log.levels.ERROR)
            vim.notify("Run: export ANTHROPIC_API_KEY='your-key-here'", vim.log.levels.INFO)
            return
          end

          local json_prompt = vim.fn.json_encode(prompt)
          json_prompt = json_prompt:gsub("'", "'\\''")

          local curl_cmd = string.format(
            [[curl -s https://api.anthropic.com/v1/messages -H "content-type: application/json" -H "x-api-key: %s" -H "anthropic-version: 2023-06-01" -d '{"model": "claude-sonnet-4-20250514", "max_tokens": 4096, "messages": [{"role": "user", "content": %s}]}']],
            api_key, json_prompt)

          vim.fn.jobstart(curl_cmd, {
            stdout_buffered = true,
            on_stdout = function(_, data)
              if data then
                local response = table.concat(data, "\n")
                local ok, json = pcall(vim.fn.json_decode, response)

                if ok and json.content and json.content[1] then
                  local mermaid_content = json.content[1].text

                  local md_content = string.format([[# Selection Diagram

Generated from visual selection
Date: %s

%s
]], os.date("%Y-%m-%d %H:%M:%S"), mermaid_content)

                  local file = io.open(output_file, "w")
                  if file then
                    file:write(md_content)
                    file:close()

                    vim.notify("Diagram generated: " .. output_file, vim.log.levels.INFO)

                    vim.cmd("edit " .. vim.fn.fnameescape(output_file))

                    vim.schedule(function()
                      vim.cmd("MarkdownPreview")
                    end)
                  else
                    vim.notify("Failed to write file", vim.log.levels.ERROR)
                  end
                else
                  vim.notify("Failed to parse Claude response", vim.log.levels.ERROR)
                  if response then
                    print("Response:", response)
                  end
                end
              end
            end,
            on_stderr = function(_, data)
              if data and #data > 0 then
                local error_msg = table.concat(data, "\n")
                if error_msg ~= "" then
                  vim.notify("API Error: " .. error_msg, vim.log.levels.ERROR)
                end
              end
            end,
            on_exit = function(_, exit_code)
              if exit_code ~= 0 then
                vim.notify("Command failed with exit code: " .. exit_code, vim.log.levels.ERROR)
              end
            end
          })
        end,
        desc = "Generate Mermaid from Visual Selection",
        mode = "v"
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
