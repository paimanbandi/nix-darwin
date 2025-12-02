-- Plugin untuk generate Mermaid diagram menggunakan Claude AI
local M = {}

-- Helper function untuk call Claude API
M.call_claude_api = function(prompt, output_file, title)
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
    api_key,
    json_prompt
  )

  vim.fn.jobstart(curl_cmd, {
    stdout_buffered = true,
    on_stdout = function(_, data)
      if data then
        local response = table.concat(data, "\n")
        local ok, json = pcall(vim.fn.json_decode, response)

        if ok and json.content and json.content[1] then
          local mermaid_content = json.content[1].text

          local md_content = string.format([[# %s

Generated Date: %s

%s
]], title, os.date("%Y-%m-%d %H:%M:%S"), mermaid_content)

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
end

-- Helper function untuk build prompt
M.build_prompt = function(filetype, code_content)
  return string.format([[Analyze this %s code and create a comprehensive Mermaid diagram.

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
end

-- Function untuk generate dari full file
M.generate_from_file = function()
  local filepath = vim.fn.expand('%:p')
  local filetype = vim.bo.filetype
  local filename = vim.fn.expand('%:t:r')
  local dir = vim.fn.expand('%:p:h')

  local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
  local code_content = table.concat(lines, "\n")

  local output_file = dir .. "/" .. filename .. "_diagram.md"

  vim.notify("Generating Mermaid diagram with Claude AI...", vim.log.levels.INFO)

  local prompt = M.build_prompt(filetype, code_content)
  local title = filename .. " - Generated Diagram\n\nGenerated from: " .. vim.fn.expand('%:t')

  M.call_claude_api(prompt, output_file, title)
end

-- Function untuk generate dari visual selection
M.generate_from_selection = function()
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

  local prompt = M.build_prompt(filetype, code_content)
  local title = "Selection Diagram\n\nGenerated from visual selection"

  M.call_claude_api(prompt, output_file, title)
end

return {
  "iamcco/markdown-preview.nvim",
  keys = {
    {
      "<leader>mg",
      function()
        M.generate_from_file()
      end,
      desc = "Generate Mermaid with Claude AI"
    },
    {
      "<leader>mG",
      function()
        M.generate_from_selection()
      end,
      desc = "Generate Mermaid from Visual Selection",
      mode = "v"
    },
  },
}
