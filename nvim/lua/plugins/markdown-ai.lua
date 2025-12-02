-- Plugin untuk generate Mermaid diagram menggunakan Claude Code CLI
local M = {}

-- Helper function untuk validate Mermaid syntax
M.validate_mermaid = function(mermaid_content)
  -- Extract node IDs from style definitions
  local styled_nodes = {}
  for node_id in mermaid_content:gmatch("style%s+(%w+)%s+fill") do
    styled_nodes[node_id] = true
  end

  -- Check if styled nodes exist in diagram
  local has_issues = false
  for node_id, _ in pairs(styled_nodes) do
    if not mermaid_content:match(node_id .. "%s*%[") and
        not mermaid_content:match(node_id .. "%s*%(") and
        not mermaid_content:match(node_id .. "%s*{") then
      print("Warning: Styled node '" .. node_id .. "' not found in diagram")
      has_issues = true
    end
  end

  return not has_issues
end

-- Helper function untuk call Claude Code
M.call_claude_code = function(prompt, output_file, title)
  -- Check if claude-code is installed
  local check_cmd = "which claude"
  local claude_path = vim.fn.system(check_cmd):gsub("\n", "")

  if claude_path == "" then
    vim.notify("Claude Code not found! Install it first:", vim.log.levels.ERROR)
    vim.notify("Add claude-code on your flake.nix!", vim.log.levels.INFO)
    vim.notify("claude auth login", vim.log.levels.INFO)
    return
  end

  -- Create temp file with prompt
  local temp_prompt = "/tmp/claude_prompt.txt"
  local prompt_file = io.open(temp_prompt, "w")
  if prompt_file then
    prompt_file:write(prompt)
    prompt_file:close()
  end

  vim.notify("Generating Mermaid diagram with Claude Code...", vim.log.levels.INFO)

  -- Call Claude Code
  local cmd = string.format("claude < %s", vim.fn.shellescape(temp_prompt))

  vim.fn.jobstart(cmd, {
    stdout_buffered = true,
    on_stdout = function(_, data)
      if data then
        local response = table.concat(data, "\n")

        -- Validate Mermaid syntax before saving
        if not M.validate_mermaid(response) then
          vim.notify("Warning: Generated Mermaid might have syntax issues. Check the output.", vim.log.levels.WARN)
        end

        -- Extract mermaid content from response
        local mermaid_content = response

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
      end
    end,
    on_stderr = function(_, data)
      if data and #data > 0 then
        local error_msg = table.concat(data, "\n")
        if error_msg ~= "" then
          vim.notify("Error: " .. error_msg, vim.log.levels.ERROR)
        end
      end
    end,
    on_exit = function(_, exit_code)
      if exit_code ~= 0 then
        vim.notify("Command failed. Make sure you're logged in: claude auth login", vim.log.levels.ERROR)
      end
    end
  })
end

-- Helper function untuk build prompt dengan syntax yang lebih strict
M.build_prompt = function(filetype, code_content)
  return string.format([[Analyze this %s code and create Mermaid diagrams with PERFECT syntax.

CRITICAL MERMAID SYNTAX RULES (MUST FOLLOW):
1. Node IDs MUST be simple alphanumeric: Start, Init, CheckAuth, LoadData, Done, etc.
2. NO SPACES in node IDs - use camelCase or underscore: CheckAuth not "Check Auth"
3. Node labels use brackets: Start[User Clicks Button]
4. Decision nodes use curly braces: CheckAuth{Is Authenticated?}
5. Rounded nodes use parentheses: Done([Process Complete])
6. Always use --> for arrows (solid line)
7. For conditional arrows: CheckAuth -->|Yes| LoadData
8. Style definitions MUST reference existing node IDs exactly

COLOR SCHEME (apply at END of each diagram):
- Blue for entry points: style Start fill:#4A90E2,stroke:#2E5C8A,stroke-width:3px,color:#fff
- Green for success: style Done fill:#50C878,stroke:#2D7A4A,stroke-width:3px,color:#fff
- Red for errors: style Error fill:#E74C3C,stroke:#A93226,stroke-width:2px,color:#fff
- Purple for database: style SaveDB fill:#9B59B6,stroke:#6C3483,stroke-width:2px,color:#fff
- Orange for decisions: style CheckAuth fill:#F39C12,stroke:#BA6F0A,stroke-width:2px,color:#fff

DIAGRAM STRATEGY FOR COMPLEX CODE:
- If code has >50 lines or >5 functions: Create 2-3 SEPARATE smaller diagrams
- Each diagram max 15-20 nodes for readability
- Separate by concerns: initialization, user flow, data operations

Diagram 1: Component Initialization and Setup
Diagram 2: Main User Interactions and Event Handlers
Diagram 3: API Calls and Data Flow (if applicable)

EXAMPLE PERFECT SYNTAX:
```mermaid
flowchart TD
    Start([User Opens Page]) --> Init[Initialize State]
    Init --> FetchData[Fetch User Data]
    FetchData --> CheckAuth{User Authenticated?}
    CheckAuth -->|Yes| LoadProfile[Load User Profile]
    CheckAuth -->|No| ShowLogin[Redirect to Login]
    LoadProfile --> SaveDB[Save to Database]
    SaveDB --> Done([Success])
    ShowLogin --> Done

    style Start fill:#4A90E2,stroke:#2E5C8A,stroke-width:3px,color:#fff
    style Done fill:#50C878,stroke:#2D7A4A,stroke-width:3px,color:#fff
    style CheckAuth fill:#F39C12,stroke:#BA6F0A,stroke-width:2px,color:#fff
    style SaveDB fill:#9B59B6,stroke:#6C3483,stroke-width:2px,color:#fff
```

REQUIREMENTS:
1. Use flowchart TD (top-down) for process flows
2. Use sequenceDiagram for API/service interactions (if many async calls)
3. Use classDiagram for complex object structures (if many classes/interfaces)
4. NO icons, NO emoji in labels
5. Keep node labels clear and concise
6. Verify ALL styled nodes exist in diagram
7. Test syntax mentally before returning

Code to analyze:
```%s
%s
```

Return ONLY valid mermaid code blocks wrapped in ```mermaid```, no explanations.
If code is complex, return multiple separate diagrams.]], filetype, filetype, code_content)
end

-- Function untuk generate dari full file
M.generate_from_file = function()
  local filetype = vim.bo.filetype
  local filename = vim.fn.expand('%:t:r')
  local dir = vim.fn.expand('%:p:h')

  local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
  local code_content = table.concat(lines, "\n")

  -- Check if file is too large
  local line_count = #lines
  if line_count > 500 then
    local confirm = vim.fn.confirm(
      string.format("File has %d lines. This might take a while. Continue?", line_count),
      "&Yes\n&No",
      2
    )
    if confirm ~= 1 then
      return
    end
  end

  local output_file = dir .. "/" .. filename .. "_diagram.md"

  local prompt = M.build_prompt(filetype, code_content)
  local title = filename .. " - Generated Diagram\n\nGenerated from: " .. vim.fn.expand('%:t')

  M.call_claude_code(prompt, output_file, title)
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

  local prompt = M.build_prompt(filetype, code_content)
  local title = "Selection Diagram\n\nGenerated from visual selection"

  M.call_claude_code(prompt, output_file, title)
end

-- Function untuk regenerate diagram yang error
M.regenerate_current = function()
  -- Check if current file is a diagram file
  local current_file = vim.fn.expand('%:p')
  if not current_file:match("_diagram%.md$") and not current_file:match("selection_diagram%.md$") then
    vim.notify("Current file is not a generated diagram. Use this on *_diagram.md files.", vim.log.levels.WARN)
    return
  end

  -- Get original file path from the markdown content
  local lines = vim.api.nvim_buf_get_lines(0, 0, 5, false)
  local source_file = nil
  for _, line in ipairs(lines) do
    local match = line:match("Generated from:%s*(.+)")
    if match then
      source_file = match
      break
    end
  end

  if not source_file then
    vim.notify("Cannot find source file information in diagram.", vim.log.levels.ERROR)
    return
  end

  -- Find and open source file
  local dir = vim.fn.expand('%:p:h')
  local source_path = dir .. "/" .. source_file

  if vim.fn.filereadable(source_path) == 0 then
    vim.notify("Source file not found: " .. source_path, vim.log.levels.ERROR)
    return
  end

  -- Read source file
  local source_lines = vim.fn.readfile(source_path)
  local code_content = table.concat(source_lines, "\n")

  -- Detect filetype from extension
  local ext = source_file:match("%.(%w+)$")
  local filetype_map = {
    ts = "typescript",
    tsx = "typescriptreact",
    js = "javascript",
    jsx = "javascriptreact",
    py = "python",
    lua = "lua",
    go = "go",
    rs = "rust",
    java = "java",
  }
  local filetype = filetype_map[ext] or ext or "text"

  vim.notify("Regenerating diagram from " .. source_file .. "...", vim.log.levels.INFO)

  local prompt = M.build_prompt(filetype, code_content)
  local filename = source_file:match("^(.+)%.")
  local title = filename .. " - Generated Diagram (Regenerated)\n\nGenerated from: " .. source_file

  M.call_claude_code(prompt, current_file, title)
end

-- Function untuk quick preview tanpa save
M.preview_diagram = function()
  local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
  local content = table.concat(lines, "\n")

  -- Check if content has mermaid
  if not content:match("```mermaid") then
    vim.notify("No mermaid diagram found in current buffer", vim.log.levels.WARN)
    return
  end

  vim.cmd("MarkdownPreview")
end

return {
  "iamcco/markdown-preview.nvim",
  keys = {
    {
      "<leader>mg",
      function()
        M.generate_from_file()
      end,
      desc = "Generate Mermaid with Claude Code"
    },
    {
      "<leader>mG",
      function()
        M.generate_from_selection()
      end,
      desc = "Generate Mermaid from Visual Selection",
      mode = "v"
    },
    {
      "<leader>mr",
      function()
        M.regenerate_current()
      end,
      desc = "Regenerate Current Diagram"
    },
    {
      "<leader>mp",
      function()
        M.preview_diagram()
      end,
      desc = "Preview Mermaid Diagram"
    },
  },
}
