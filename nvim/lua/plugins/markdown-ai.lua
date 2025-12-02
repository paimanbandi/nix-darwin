-- Plugin untuk generate Mermaid diagram menggunakan Claude Code CLI
local M = {}

-- Helper function untuk validate Mermaid syntax
M.validate_mermaid = function(mermaid_content)
  local styled_nodes = {}
  for node_id in mermaid_content:gmatch("style%s+(%w+)%s+fill") do
    styled_nodes[node_id] = true
  end

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
  local check_cmd = "which claude"
  local claude_path = vim.fn.system(check_cmd):gsub("\n", "")

  if claude_path == "" then
    vim.notify("❌ Claude CLI not found! Install it first:", vim.log.levels.ERROR)
    vim.notify("npm install -g @anthropic-ai/claude-code", vim.log.levels.INFO)
    vim.notify("claude auth login", vim.log.levels.INFO)
    return
  end

  local temp_prompt = vim.fn.tempname() .. "_prompt.txt"
  local prompt_file = io.open(temp_prompt, "w")

  if not prompt_file then
    vim.notify("❌ Failed to create temp file", vim.log.levels.ERROR)
    return
  end

  prompt_file:write(prompt)
  prompt_file:close()

  vim.notify("🚀 Generating Mermaid diagram with Claude... (10-30 seconds)", vim.log.levels.INFO)

  local cmd = string.format("cat %s | claude", vim.fn.shellescape(temp_prompt))
  local response_buffer = {}

  vim.fn.jobstart(cmd, {
    stdout_buffered = true,
    on_stdout = function(_, data)
      if data then
        for _, line in ipairs(data) do
          if line ~= "" then
            table.insert(response_buffer, line)
          end
        end
      end
    end,
    on_stderr = function(_, data)
      if data and #data > 0 then
        local error_msg = table.concat(data, "\n")
        if error_msg ~= "" and not error_msg:match("^%s*$") then
          vim.notify("❌ Claude Error: " .. error_msg, vim.log.levels.ERROR)
        end
      end
    end,
    on_exit = function(_, exit_code)
      pcall(os.remove, temp_prompt)

      if exit_code ~= 0 then
        vim.notify(
          "❌ Generation failed (exit code: " .. exit_code .. "). Check login: claude auth login",
          vim.log.levels.ERROR
        )
        return
      end

      local response = table.concat(response_buffer, "\n")

      if response == "" or response:match("^%s*$") then
        vim.notify("❌ Empty response from Claude. Check authentication with: claude auth login", vim.log.levels.ERROR)
        return
      end

      -- VALIDATE: Check if response contains mermaid code blocks
      if not response:match("```mermaid") then
        vim.notify("❌ Invalid response: No mermaid code blocks found!", vim.log.levels.ERROR)
        vim.notify("⚠️  Response contains plain text instead of Mermaid syntax", vim.log.levels.WARN)
        vim.notify("💡 Try regenerating with <leader>mr or generate again with <leader>mg", vim.log.levels.INFO)

        -- Save invalid response for debugging
        local debug_file = output_file:gsub("%.md$", "_debug.txt")
        local file = io.open(debug_file, "w")
        if file then
          file:write("=== INVALID RESPONSE (Not Mermaid Syntax) ===\n\n")
          file:write("Expected: ```mermaid ... ```\n")
          file:write("Got plain text or invalid format instead.\n\n")
          file:write("=== RESPONSE CONTENT ===\n\n")
          file:write(response)
          file:close()
          vim.notify("📄 Invalid response saved to: " .. debug_file, vim.log.levels.INFO)
        end
        return
      end

      -- Validate mermaid syntax
      if not M.validate_mermaid(response) then
        vim.notify("⚠️  Warning: Some style definitions may not match nodes in diagram", vim.log.levels.WARN)
      end

      local md_content = string.format([[# %s

Generated Date: %s

%s
]], title, os.date("%Y-%m-%d %H:%M:%S"), response)

      local file = io.open(output_file, "w")
      if file then
        file:write(md_content)
        file:close()

        vim.notify("✅ Diagram generated successfully!", vim.log.levels.INFO)

        vim.schedule(function()
          vim.cmd("edit " .. vim.fn.fnameescape(output_file))

          vim.defer_fn(function()
            vim.cmd("MarkdownPreview")
            vim.notify("🌐 Preview opened in browser!", vim.log.levels.INFO)
          end, 200)
        end)
      else
        vim.notify("❌ Failed to write output file: " .. output_file, vim.log.levels.ERROR)
      end
    end
  })
end

-- COMPREHENSIVE PROMPT - Single detailed diagram
M.build_prompt_comprehensive = function(filetype, code_content)
  return string.format([[Analyze this %s code and create ONE comprehensive, detailed Mermaid flowchart diagram.

CRITICAL REQUIREMENT: You MUST return VALID MERMAID SYNTAX wrapped in ```mermaid``` code blocks.
DO NOT return plain text ASCII art, simple arrows, or any other format.

CORRECT MERMAID FORMAT (YOU MUST FOLLOW EXACTLY):
```mermaid
flowchart TD
    Start([Component Mount]) --> Init[Initialize State]
    Init --> CheckPlatform{Platform = iOS?}
    CheckPlatform -->|Yes| LoadData[Load Data]
    CheckPlatform -->|No| Skip[Skip Setup]
    LoadData --> Done([Complete])

    style Start fill:#2563eb,stroke:#1e40af,stroke-width:3px,color:#fff
    style CheckPlatform fill:#fed7aa,stroke:#f97316,stroke-width:2px,color:#000
    style Done fill:#50C878,stroke:#2D7A4A,stroke-width:3px,color:#fff
```

WRONG FORMATS (DO NOT USE):
❌ Plain text: Start --> Init --> CheckPlatform
❌ ASCII art: Start ---> Init ===> CheckPlatform
❌ Without code blocks: flowchart TD (must wrap in ```mermaid```)

MERMAID SYNTAX RULES:
1. MUST start with ```mermaid
2. MUST have "flowchart TD" directive
3. MUST end with ```
4. Node IDs: simple alphanumeric only (Start, Init, CheckAuth, LoadData)
   - NO SPACES in IDs
   - Use camelCase: CheckPlatform not "Check Platform"
5. Arrows: use --> for all connections
6. Conditional arrows: NodeId -->|Condition| NextNode
7. Node shapes:
   - Start/End: Start([Label Text])
   - Process: NodeId[Label Text]
   - Decision: NodeId{Question?}

DIAGRAM STRUCTURE (include all major flows):
1. Component mount and initialization
2. Conditional setup based on platform/state
3. Event listener registration and automatic triggers
4. User-initiated actions (buttons, clicks, forms)
5. Async operations (API calls, data sync, database)
6. Success paths and state updates
7. Error handling and rollback mechanisms
8. Component cleanup and unmount

COMPREHENSIVE FLOW (40-80 nodes for complex components):
- Show ALL decision points
- Include ALL error paths
- Show complete user interaction flows
- Include background/async operations
- Show cleanup and unmount

COLOR SCHEME (apply style definitions at END of diagram):
Use these exact style formats:

style Start fill:#2563eb,stroke:#1e40af,stroke-width:3px,color:#fff
  → Use for: Start and End nodes

style Init fill:#dbeafe,stroke:#3b82f6,stroke-width:2px,color:#000
  → Use for: Regular process nodes, initialization, rendering

style CheckPlatform fill:#fed7aa,stroke:#f97316,stroke-width:2px,color:#000
  → Use for: Decision nodes, conditional checks, branching

style SyncAPI fill:#e9d5ff,stroke:#a855f7,stroke-width:2px,color:#000
  → Use for: Async operations, API calls, database, background tasks

style Success fill:#bbf7d0,stroke:#22c55e,stroke-width:2px,color:#000
  → Use for: Success operations, positive outcomes

style Error fill:#fecaca,stroke:#ef4444,stroke-width:2px,color:#000
  → Use for: Error handling, failed operations, rollbacks

style UserClick fill:#fef08a,stroke:#eab308,stroke-width:2px,color:#000
  → Use for: User actions, button clicks, form submissions

Code to analyze:
```%s
%s
```

FINAL CHECKLIST BEFORE RETURNING:
✓ Response starts with ```mermaid
✓ Has "flowchart TD" directive
✓ All node IDs are simple alphanumeric (no spaces)
✓ Uses --> for arrows (not ---> or other variants)
✓ All styled nodes exist in the diagram
✓ Response ends with ```
✓ No plain text or ASCII art

Return ONLY the mermaid code block. No explanations before or after.]], filetype, filetype, code_content)
end

-- MODULAR PROMPT - Multiple focused diagrams
M.build_prompt_modular = function(filetype, code_content)
  return string.format([[Analyze this %s code and create 2-3 focused, modular Mermaid diagrams.

CRITICAL: You MUST return VALID MERMAID SYNTAX in ```mermaid``` code blocks.
DO NOT return plain text or ASCII art.

CORRECT FORMAT (MUST FOLLOW EXACTLY):
```mermaid
flowchart TD
    Start([Component Mount]) --> Init[Initialize State]
    Init --> CheckPlatform{iOS Platform?}
    CheckPlatform -->|Yes| SetupIOS[Setup iOS Features]
    CheckPlatform -->|No| SetupGeneric[Setup Generic]

    style Start fill:#2563eb,stroke:#1e40af,stroke-width:3px,color:#fff
    style CheckPlatform fill:#fed7aa,stroke:#f97316,stroke-width:2px,color:#000
```
```mermaid
flowchart TD
    UserClick([User Clicks Connect]) --> Validate{Platform Valid?}
    Validate -->|Yes| RequestPerms[Request Permissions]
    Validate -->|No| ShowError[Show Error]

    style UserClick fill:#fef08a,stroke:#eab308,stroke-width:2px,color:#000
    style ShowError fill:#fecaca,stroke:#ef4444,stroke-width:2px,color:#000
```

SEPARATE INTO LOGICAL MODULES:

**Module 1: Initialization & Setup Flow** (max 20 nodes)
- Component mount
- State initialization
- Platform checks
- Conditional setup
- Listener registration

**Module 2: User Interactions Flow** (max 20 nodes)
- User action triggers
- Connect/disconnect flows
- Manual sync operations
- Search and filter actions
- UI state updates

**Module 3: API & Data Operations Flow** (max 20 nodes, if applicable)
- API calls
- Data synchronization
- Background operations
- Success/error handling
- State persistence

MERMAID SYNTAX RULES (same as comprehensive):
1. MUST wrap in ```mermaid ... ```
2. MUST use "flowchart TD" directive
3. Simple node IDs (no spaces)
4. Use --> for arrows
5. Use -->|Label| for conditional arrows

COLOR SCHEME (apply to each diagram):
- Blue (#2563eb): start/end nodes
- Light Blue (#dbeafe): regular processes
- Orange (#fed7aa): decisions
- Purple (#e9d5ff): async/API operations
- Green (#bbf7d0): success states
- Red (#fecaca): errors
- Yellow (#fef08a): user actions

Code to analyze:
```%s
%s
```

REQUIREMENTS:
- Return 2-3 SEPARATE ```mermaid``` code blocks
- Each diagram max 15-20 nodes for readability
- Each diagram independently understandable
- Apply color coding to each diagram
- Use proper Mermaid syntax (NOT plain text)

CHECKLIST:
✓ Each diagram wrapped in ```mermaid```
✓ Each has "flowchart TD"
✓ All node IDs simple alphanumeric
✓ Uses --> arrows
✓ Ends with ```

Return ONLY the mermaid code blocks.]], filetype, filetype, code_content)
end

-- Function untuk generate dari full file
M.generate_from_file = function(use_comprehensive)
  local filetype = vim.bo.filetype
  local filename = vim.fn.expand('%:t:r')
  local dir = vim.fn.expand('%:p:h')

  local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
  local code_content = table.concat(lines, "\n")

  local line_count = #lines

  -- Notify if file is large (no confirmation dialog)
  if line_count > 500 then
    vim.notify("📄 Large file detected (" .. line_count .. " lines). Generation may take 30-60 seconds...",
      vim.log.levels.WARN)
  end

  local output_file = dir .. "/" .. filename .. "_diagram.md"

  local prompt
  local style_desc
  if use_comprehensive then
    prompt = M.build_prompt_comprehensive(filetype, code_content)
    style_desc = "Comprehensive"
  else
    prompt = M.build_prompt_modular(filetype, code_content)
    style_desc = "Modular"
  end

  vim.notify("📊 Generating " .. style_desc .. " diagram for " .. filename .. "...", vim.log.levels.INFO)

  local title = filename .. " - Generated Diagram (" .. style_desc .. ")\n\nGenerated from: " .. vim.fn.expand('%:t')

  M.call_claude_code(prompt, output_file, title)
end

-- Function untuk generate dari visual selection
M.generate_from_selection = function()
  local start_pos = vim.fn.getpos("'<")
  local end_pos = vim.fn.getpos("'>")

  if start_pos[2] == 0 or end_pos[2] == 0 then
    vim.notify("⚠️  No selection found. Use visual mode first!", vim.log.levels.WARN)
    return
  end

  local lines = vim.api.nvim_buf_get_lines(0, start_pos[2] - 1, end_pos[2], false)
  local code_content = table.concat(lines, "\n")

  if code_content == "" then
    vim.notify("⚠️  No selection found. Use visual mode first!", vim.log.levels.WARN)
    return
  end

  local filetype = vim.bo.filetype
  local dir = vim.fn.expand('%:p:h')
  local output_file = dir .. "/selection_diagram.md"

  vim.notify("📊 Generating diagram from selection (" .. #lines .. " lines)...", vim.log.levels.INFO)

  -- Selection always uses comprehensive style
  local prompt = M.build_prompt_comprehensive(filetype, code_content)
  local title = "Selection Diagram\n\nGenerated from visual selection"

  M.call_claude_code(prompt, output_file, title)
end

-- Function untuk regenerate diagram yang error
M.regenerate_current = function()
  local current_file = vim.fn.expand('%:p')
  if not current_file:match("_diagram%.md$") and not current_file:match("selection_diagram%.md$") then
    vim.notify("⚠️  Current file is not a generated diagram. Use this on *_diagram.md files.", vim.log.levels.WARN)
    return
  end

  local lines = vim.api.nvim_buf_get_lines(0, 0, 10, false)
  local source_file = nil
  for _, line in ipairs(lines) do
    local match = line:match("Generated from:%s*(.+)")
    if match then
      source_file = match
      break
    end
  end

  if not source_file then
    vim.notify("❌ Cannot find source file information in diagram.", vim.log.levels.ERROR)
    return
  end

  local dir = vim.fn.expand('%:p:h')
  local source_path = dir .. "/" .. source_file

  if vim.fn.filereadable(source_path) == 0 then
    vim.notify("❌ Source file not found: " .. source_path, vim.log.levels.ERROR)
    return
  end

  local source_lines = vim.fn.readfile(source_path)
  local code_content = table.concat(source_lines, "\n")

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
    cpp = "cpp",
    c = "c",
  }
  local filetype = filetype_map[ext] or ext or "text"

  -- Ask user which style to use for regeneration
  local choice = vim.fn.confirm(
    "Regenerate " .. source_file .. " as:",
    "&Comprehensive (single detailed)\n&Modular (multiple simple)\n&Cancel",
    1
  )

  if choice == 3 or choice == 0 then
    return
  end

  local prompt
  local style_desc
  if choice == 1 then
    prompt = M.build_prompt_comprehensive(filetype, code_content)
    style_desc = "Comprehensive"
  else
    prompt = M.build_prompt_modular(filetype, code_content)
    style_desc = "Modular"
  end

  vim.notify("🔄 Regenerating as " .. style_desc .. " diagram...", vim.log.levels.INFO)

  local filename = source_file:match("^(.+)%.")
  local title = filename .. " - Regenerated (" .. style_desc .. ")\n\nGenerated from: " .. source_file

  M.call_claude_code(prompt, current_file, title)
end

-- Function untuk quick preview tanpa save
M.preview_diagram = function()
  local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
  local content = table.concat(lines, "\n")

  if not content:match("```mermaid") then
    vim.notify("⚠️  No mermaid diagram found in current buffer", vim.log.levels.WARN)
    return
  end

  vim.notify("🌐 Opening preview in browser...", vim.log.levels.INFO)
  vim.cmd("MarkdownPreview")
end

return {
  "iamcco/markdown-preview.nvim",
  keys = {
    {
      "<leader>mg",
      function()
        M.generate_from_file(true)
      end,
      desc = "Generate Comprehensive Mermaid (Single Detailed)"
    },
    {
      "<leader>mm",
      function()
        M.generate_from_file(false)
      end,
      desc = "Generate Modular Mermaid (Multiple Simple)"
    },
    {
      "<leader>mG",
      function()
        M.generate_from_selection()
      end,
      desc = "Generate Mermaid from Selection",
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
