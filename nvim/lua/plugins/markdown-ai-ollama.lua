-- markdown-ai-ollama.lua
-- Generate Mermaid diagrams using Ollama (local, unlimited, FREE)
-- NO OpenCode needed - direct Ollama API call!

local M = {}
local detector = require("plugins.markdown-ai-detector")

-- Check if Ollama is installed and running
M.check_ollama = function()
  -- Check if ollama command exists
  local handle = io.popen("which ollama 2>/dev/null")
  if not handle then
    return false, "Cannot execute which command"
  end

  local result = handle:read("*a")
  handle:close()

  if result == "" or not result:match("ollama") then
    return false, [[❌ Ollama not installed!

Install:
  brew install ollama

Download model:
  ollama pull qwen2.5-coder:7b

Start server:
  ollama serve
  # or: brew services start ollama]]
  end

  -- Check if Ollama server is running
  local server_handle = io.popen("curl -s http://localhost:11434/api/tags 2>/dev/null")
  if not server_handle then
    return false, "Cannot check Ollama server"
  end

  local server_response = server_handle:read("*a")
  server_handle:close()

  if server_response == "" or not server_response:match("models") then
    return false, [[❌ Ollama server not running!

Start server:
  ollama serve
  # or: brew services start ollama

Check status:
  curl http://localhost:11434/api/tags]]
  end

  return true, nil
end

-- Get list of installed Ollama models
M.list_models = function()
  local handle = io.popen("ollama list 2>/dev/null")
  if not handle then
    return {}
  end

  local result = handle:read("*a")
  handle:close()

  local models = {}
  -- Parse ollama list output
  for line in result:gmatch("[^\r\n]+") do
    -- Skip header line
    if not line:match("^NAME") then
      -- Extract model name (first column)
      local model = line:match("^([^%s:]+:?[^%s]*)")
      if model and model ~= "" then
        table.insert(models, model)
      end
    end
  end

  return models
end

-- Build optimized prompt for Ollama code models
M.build_prompt = function(diagram_type, code_content, filetype)
  -- Truncate code if too long
  local max_length = 3000
  local truncated_code = code_content
  if #code_content > max_length then
    truncated_code = code_content:sub(1, max_length) .. "\n... (truncated)"
  end

  local diagram_specs = {
    flowchart = {
      type = "flowchart",
      directive = "flowchart TD",
      description = "process flow with nodes and arrows",
      example = [[flowchart TD
    Start([Begin]) --> Process[Main Process]
    Process --> Decision{Check Condition}
    Decision -->|Yes| Success[Success]
    Decision -->|No| Error[Error]
    Success --> End([Complete])
    Error --> End]]
    },
    sequence = {
      type = "sequence diagram",
      directive = "sequenceDiagram",
      description = "interaction between components over time",
      example = [[sequenceDiagram
    participant User
    participant System
    participant Database
    User->>System: Request Data
    System->>Database: Query
    Database-->>System: Results
    System-->>User: Display Data]]
    },
    class_diagram = {
      type = "class diagram",
      directive = "classDiagram",
      description = "classes, methods, and relationships",
      example = [[classDiagram
    class User {
        +String name
        +String email
        +login()
        +logout()
    }
    class Admin {
        +String role
        +manageUsers()
    }
    User <|-- Admin]]
    },
    state_diagram = {
      type = "state diagram",
      directive = "stateDiagram-v2",
      description = "state transitions",
      example = [[stateDiagram-v2
    [*] --> Idle
    Idle --> Processing
    Processing --> Success
    Processing --> Error
    Success --> [*]
    Error --> Idle]]
    },
    er_diagram = {
      type = "ER diagram",
      directive = "erDiagram",
      description = "database entity relationships",
      example = [[erDiagram
    USER ||--o{ ORDER : places
    ORDER ||--|{ ITEM : contains
    USER {
        int id
        string name
    }]]
    }
  }

  local spec = diagram_specs[diagram_type] or diagram_specs.flowchart

  -- Build comprehensive prompt
  return string.format([[You are an expert at creating Mermaid diagrams. Analyze the provided %s code and create a %s.

CRITICAL OUTPUT RULES:
1. Output MUST start with: ```mermaid
2. Second line MUST be: %s
3. End with: ```
4. NO explanations before or after the code block
5. NO comments inside the diagram
6. Use REAL content from the code (not placeholder text)
7. Keep it clear and focused

EXAMPLE FORMAT:
```mermaid
%s
```

CODE TO ANALYZE (%s):
%s

CREATE THE MERMAID DIAGRAM NOW (output ONLY the code block):]],
    filetype,
    spec.description,
    spec.directive,
    spec.example,
    filetype,
    truncated_code
  )
end

-- Extract mermaid block from Ollama response
M.extract_mermaid = function(response)
  if not response or response == "" then
    return nil, "Empty response"
  end

  -- Try to find mermaid code block
  local mermaid = response:match("(```mermaid.-)```")
  if mermaid then
    return mermaid .. "```", nil
  end

  -- Try to find any code block that looks like mermaid
  local code_block = response:match("```(%w+)%s*\n(.-)\n```")
  if code_block then
    local content = response:match("```%w+%s*\n(.-)\n```")
    if content and (content:match("flowchart") or content:match("sequenceDiagram") or
          content:match("classDiagram") or content:match("stateDiagram") or
          content:match("erDiagram")) then
      return "```mermaid\n" .. content .. "\n```", nil
    end
  end

  -- Try raw format (no backticks)
  if response:match("^%s*flowchart") or response:match("^%s*sequenceDiagram") or
      response:match("^%s*classDiagram") or response:match("^%s*stateDiagram") or
      response:match("^%s*erDiagram") then
    local clean = response:gsub("^%s+", ""):gsub("%s+$", "")
    return "```mermaid\n" .. clean .. "\n```", nil
  end

  return nil, "No valid mermaid diagram found in response"
end

-- Main generate function - calls Ollama directly
M.generate = function(diagram_type, model)
  -- Check Ollama status
  local ok, err = M.check_ollama()
  if not ok then
    vim.notify(err, vim.log.levels.ERROR)
    return
  end

  -- Get available models
  local models = M.list_models()
  if #models == 0 then
    vim.notify([[❌ No Ollama models found!

Install a model:
  ollama pull qwen2.5-coder:7b

Or check:
  ollama list]], vim.log.levels.ERROR)
    return
  end

  -- Select model
  local selected_model = model or models[1]

  -- Check if model exists
  local model_exists = false
  for _, m in ipairs(models) do
    if m == selected_model then
      model_exists = true
      break
    end
  end

  if not model_exists then
    vim.notify("Model not found: " .. selected_model .. "\nAvailable: " .. table.concat(models, ", "),
      vim.log.levels.ERROR)
    return
  end

  -- Get current file info
  local filetype = vim.bo.filetype
  local filename = vim.fn.expand('%:t:r')
  local dir = vim.fn.expand('%:p:h')

  -- Get code content
  local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
  local code_content = table.concat(lines, "\n")

  if code_content == "" then
    vim.notify("⚠️  No content to analyze", vim.log.levels.WARN)
    return
  end

  -- Build prompt
  local prompt = M.build_prompt(diagram_type, code_content, filetype)

  -- Create temp files
  local temp_prompt = os.tmpname()
  local temp_output = os.tmpname()

  -- Write prompt to file
  local prompt_file = io.open(temp_prompt, "w")
  if not prompt_file then
    vim.notify("❌ Cannot create temp file", vim.log.levels.ERROR)
    return
  end
  prompt_file:write(prompt)
  prompt_file:close()

  -- Output file path
  local output_file = dir .. "/" .. filename .. "_" .. diagram_type .. "_ollama.md"

  -- Show notification
  vim.notify("🤖 Generating with Ollama...", vim.log.levels.INFO)
  vim.notify("Model: " .. selected_model, vim.log.levels.INFO)
  vim.notify("⏱️  Processing locally (10-60s)...", vim.log.levels.INFO)

  -- Build command - call Ollama directly
  local cmd = string.format(
    'ollama run %s "$(cat %s)" > %s 2>&1',
    vim.fn.shellescape(selected_model),
    vim.fn.shellescape(temp_prompt),
    vim.fn.shellescape(temp_output)
  )

  -- Execute async
  vim.fn.jobstart({ 'bash', '-c', cmd }, {
    on_exit = function(_, exit_code)
      vim.schedule(function()
        -- Read output
        local output_file_handle = io.open(temp_output, "r")
        if not output_file_handle then
          os.remove(temp_prompt)
          os.remove(temp_output)
          vim.notify("❌ Failed to read Ollama output", vim.log.levels.ERROR)
          return
        end

        local response = output_file_handle:read("*all")
        output_file_handle:close()

        -- Cleanup temp files
        os.remove(temp_prompt)
        os.remove(temp_output)

        -- Check for errors
        if exit_code ~= 0 then
          vim.notify("❌ Ollama command failed (exit " .. exit_code .. ")", vim.log.levels.ERROR)
          if response and response ~= "" then
            vim.notify("Error: " .. response:sub(1, 200), vim.log.levels.WARN)
          end
          return
        end

        if not response or response == "" then
          vim.notify("❌ Empty response from Ollama", vim.log.levels.ERROR)
          return
        end

        -- Extract mermaid diagram
        local mermaid, extract_err = M.extract_mermaid(response)

        if not mermaid then
          vim.notify("❌ " .. (extract_err or "Could not extract mermaid diagram"), vim.log.levels.ERROR)
          vim.notify("Response preview:\n" .. response:sub(1, 300), vim.log.levels.WARN)

          -- Save debug file
          local debug_file = output_file:gsub("%.md$", "_debug.txt")
          local debug_handle = io.open(debug_file, "w")
          if debug_handle then
            debug_handle:write("=== OLLAMA RESPONSE ===\n\n")
            debug_handle:write(response)
            debug_handle:close()
            vim.notify("Debug saved: " .. debug_file, vim.log.levels.INFO)
          end
          return
        end

        -- Create final markdown content
        local title = filename .. " - " .. diagram_type:gsub("_", " "):upper()
        local markdown_content = string.format([[# %s

Generated: %s
Provider: Ollama (Local)
Model: %s
Source: %s

%s

---
*Generated locally with Ollama - 100%% free and unlimited!*
]],
          title,
          os.date("%Y-%m-%d %H:%M:%S"),
          selected_model,
          vim.fn.expand('%:t'),
          mermaid
        )

        -- Write markdown file
        local final_file = io.open(output_file, "w")
        if not final_file then
          vim.notify("❌ Cannot write output file", vim.log.levels.ERROR)
          return
        end

        final_file:write(markdown_content)
        final_file:close()

        -- Success!
        vim.notify("✅ Diagram generated successfully!", vim.log.levels.INFO)

        -- Open file and preview
        vim.cmd("edit " .. vim.fn.fnameescape(output_file))
        vim.defer_fn(function()
          vim.cmd("MarkdownPreview")
        end, 300)
      end)
    end
  })
end

-- Auto-detect diagram type and generate
M.auto = function()
  local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
  local code = table.concat(lines, "\n")

  if code == "" then
    vim.notify("⚠️  No content to analyze", vim.log.levels.WARN)
    return
  end

  -- Auto-detect diagram type
  local analysis = detector.detect_diagram_type(code, vim.bo.filetype)
  local recommended = detector.recommend_diagram_type(analysis)

  vim.notify("💡 Detected: " .. recommended, vim.log.levels.INFO)

  -- Generate with default model
  M.generate(recommended, nil)
end

-- Manual selection of diagram type and model
M.manual = function()
  -- First, select diagram type
  local diagram_choice = vim.fn.confirm(
    "Select Diagram Type:",
    "&1. Flowchart\n&2. Sequence\n&3. Class\n&4. State\n&5. ER\n&Cancel",
    1
  )

  if diagram_choice == 0 or diagram_choice == 6 then
    return
  end

  local diagram_types = {
    "flowchart",
    "sequence",
    "class_diagram",
    "state_diagram",
    "er_diagram"
  }

  local selected_diagram = diagram_types[diagram_choice]

  -- Get available models
  local models = M.list_models()

  if #models == 0 then
    vim.notify("❌ No models. Run: ollama pull qwen2.5-coder:7b", vim.log.levels.ERROR)
    return
  end

  -- If only one model, use it
  if #models == 1 then
    M.generate(selected_diagram, models[1])
    return
  end

  -- Show model selection
  local model_menu = "Select Model:\n"
  for i, model in ipairs(models) do
    model_menu = model_menu .. "&" .. i .. ". " .. model .. "\n"
  end
  model_menu = model_menu .. "&Cancel"

  local model_choice = vim.fn.confirm(model_menu, model_menu, 1)

  if model_choice == 0 or model_choice > #models then
    return
  end

  M.generate(selected_diagram, models[model_choice])
end

-- Show Ollama status and info
M.info = function()
  local ok, err = M.check_ollama()
  local models = M.list_models()

  local status = ok and "✅ Ready" or "❌ Not Ready"
  local model_count = #models

  local info_text = string.format([[
╔══════════════════════════════════════════════════════════╗
║         Ollama Mermaid Diagram Generator                 ║
╠══════════════════════════════════════════════════════════╣
║ Status: %s
║ Models Installed: %d
╠══════════════════════════════════════════════════════════╣
║ Keybindings:                                             ║
║   <leader>ml  - Auto-detect & generate                  ║
║   <leader>mL  - Manual selection (diagram + model)      ║
║   <leader>mi  - Show this info                          ║
╠══════════════════════════════════════════════════════════╣]], status, model_count)

  if #models > 0 then
    info_text = info_text .. "\n║ Available Models:\n"
    for i, model in ipairs(models) do
      info_text = info_text .. string.format("║   %d. %s\n", i, model)
    end
  else
    info_text = info_text .. [[
║ No models installed!
║
║ Install recommended model:
║   ollama pull qwen2.5-coder:7b
]]
  end

  if not ok then
    info_text = info_text .. [[
╠══════════════════════════════════════════════════════════╣
║ ERROR:
]] .. err .. "\n"
  end

  info_text = info_text .. [[
╠══════════════════════════════════════════════════════════╣
║ Recommended Models:                                      ║
║   • qwen2.5-coder:7b     (best for code, 4GB RAM)       ║
║   • deepseek-coder:6.7b  (alternative, 4GB RAM)         ║
║   • codellama:7b         (Meta's model, 4GB RAM)        ║
╠══════════════════════════════════════════════════════════╣
║ Features:                                                ║
║   ✅ 100% Free & Unlimited                              ║
║   ✅ Runs Locally (no internet needed)                  ║
║   ✅ Private (code never leaves your machine)           ║
║   ✅ Fast after first load                              ║
╚══════════════════════════════════════════════════════════╝
]]

  vim.notify(info_text, vim.log.levels.INFO)
end

-- Install recommended model helper
M.install_model = function()
  local choice = vim.fn.confirm(
    "Install which model?",
    "&1. qwen2.5-coder:7b (recommended)\n&2. deepseek-coder:6.7b\n&3. codellama:7b\n&Cancel",
    1
  )

  if choice == 0 or choice == 4 then return end

  local models_map = {
    "qwen2.5-coder:7b",
    "deepseek-coder:6.7b",
    "codellama:7b"
  }

  local model = models_map[choice]

  vim.notify("📥 Installing " .. model .. "...", vim.log.levels.INFO)
  vim.notify("This may take 5-10 minutes (downloading ~4GB)", vim.log.levels.INFO)

  local cmd = "ollama pull " .. model

  vim.fn.jobstart(cmd, {
    on_stdout = function(_, data)
      if data then
        for _, line in ipairs(data) do
          if line ~= "" then
            print(line)
          end
        end
      end
    end,
    on_exit = function(_, exit_code)
      if exit_code == 0 then
        vim.notify("✅ Model installed: " .. model, vim.log.levels.INFO)
        vim.notify("Ready to use! Press <leader>ml to generate", vim.log.levels.INFO)
      else
        vim.notify("❌ Failed to install model", vim.log.levels.ERROR)
      end
    end
  })
end

-- Plugin configuration
return {
  "iamcco/markdown-preview.nvim",
  keys = {
    {
      "<leader>ml",
      function()
        M.auto()
      end,
      desc = "🤖 Ollama: Auto Diagram"
    },
    {
      "<leader>mL",
      function()
        M.manual()
      end,
      desc = "🤖 Ollama: Manual Select"
    },
    {
      "<leader>mi",
      function()
        M.info()
      end,
      desc = "ℹ️  Ollama: Info & Status"
    },
    {
      "<leader>mI",
      function()
        M.install_model()
      end,
      desc = "📥 Ollama: Install Model"
    },
  },
}
