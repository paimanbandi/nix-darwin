-- Main plugin with intelligent diagram type selection
local M = {}
local prompts = require("plugins.markdown-ai-prompts")
local detector = require("plugins.markdown-ai-detector")

-- Validate Mermaid syntax
M.validate_mermaid = function(content)
  local styled_nodes = {}
  for node_id in content:gmatch("style%s+(%w+)%s+fill") do
    styled_nodes[node_id] = true
  end

  local has_issues = false
  for node_id, _ in pairs(styled_nodes) do
    if not content:match(node_id .. "%s*%[") and
        not content:match(node_id .. "%s*%(") and
        not content:match(node_id .. "%s*{") then
      print("Warning: Styled node '" .. node_id .. "' not found")
      has_issues = true
    end
  end

  return not has_issues
end

-- Call Claude CLI
M.call_claude = function(prompt, output_file, title)
  local claude_path = vim.fn.system("which claude"):gsub("\n", "")

  if claude_path == "" then
    vim.notify("Claude CLI not found", vim.log.levels.ERROR)
    return
  end

  local temp_prompt = vim.fn.tempname() .. "_prompt.txt"
  local prompt_file = io.open(temp_prompt, "w")

  if not prompt_file then
    vim.notify("Failed to create temp file", vim.log.levels.ERROR)
    return
  end

  prompt_file:write(prompt)
  prompt_file:close()

  vim.notify("Generating diagram... (10-30 seconds)", vim.log.levels.INFO)

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
    on_exit = function(_, exit_code)
      pcall(os.remove, temp_prompt)

      if exit_code ~= 0 then
        vim.notify("Generation failed", vim.log.levels.ERROR)
        return
      end

      local response = table.concat(response_buffer, "\n")

      if not response:match("```mermaid") then
        vim.notify("Invalid response: No mermaid blocks", vim.log.levels.ERROR)
        return
      end

      local md_content = string.format([[# %s

Generated Date: %s

%s
]], title, os.date("%Y-%m-%d %H:%M:%S"), response)

      local file = io.open(output_file, "w")
      if file then
        file:write(md_content)
        file:close()

        vim.notify("Diagram generated successfully", vim.log.levels.INFO)

        vim.schedule(function()
          vim.cmd("edit " .. vim.fn.fnameescape(output_file))
          vim.defer_fn(function()
            vim.cmd("MarkdownPreview")
          end, 200)
        end)
      end
    end
  })
end

-- Generate with auto-detection
M.generate_auto = function(complexity)
  local filetype = vim.bo.filetype
  local filename = vim.fn.expand('%:t:r')
  local dir = vim.fn.expand('%:p:h')

  local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
  local code_content = table.concat(lines, "\n")

  -- Auto-detect best diagram type
  local analysis = detector.detect_diagram_type(code_content, filetype)
  local recommended, scores = detector.recommend_diagram_type(analysis)

  vim.notify("Analyzing code...", vim.log.levels.INFO)
  vim.notify("Recommended: " .. recommended, vim.log.levels.INFO)

  -- Generate based on recommendation
  local prompt
  if recommended == "flowchart" then
    prompt = prompts.build_flowchart_prompt(filetype, code_content, complexity or "moderate")
  elseif recommended == "sequence" then
    prompt = prompts.build_sequence_prompt(filetype, code_content)
  elseif recommended == "class_diagram" then
    prompt = prompts.build_class_diagram_prompt(filetype, code_content)
  elseif recommended == "state_diagram" then
    prompt = prompts.build_state_diagram_prompt(filetype, code_content)
  else
    prompt = prompts.build_flowchart_prompt(filetype, code_content, complexity or "moderate")
  end

  local output_file = dir .. "/" .. filename .. "_" .. recommended .. ".md"
  local title = filename .. " - " .. recommended:gsub("_", " "):gsub("^%l", string.upper)

  M.call_claude(prompt, output_file, title)
end

-- Generate with manual selection
M.generate_manual = function()
  local filetype = vim.bo.filetype
  local filename = vim.fn.expand('%:t:r')
  local dir = vim.fn.expand('%:p:h')

  local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
  local code_content = table.concat(lines, "\n")

  -- Show selection menu
  local choice = vim.fn.confirm(
    "Select diagram type:",
    "&Flowchart (Process Flow)\n" ..
    "&Sequence (Time-based Interactions)\n" ..
    "&Class (Object Structure)\n" ..
    "S&tate (State Transitions)\n" ..
    "&ER (Database Schema)\n" ..
    "&Cancel",
    1
  )

  if choice == 6 or choice == 0 then
    return
  end

  local diagram_type
  local prompt

  if choice == 1 then
    diagram_type = "flowchart"

    -- Ask for complexity
    local complexity_choice = vim.fn.confirm(
      "Select complexity:",
      "&Simple (30 nodes)\n&Moderate (50 nodes)\n&Detailed (80 nodes)",
      2
    )

    local complexity = "moderate"
    if complexity_choice == 1 then
      complexity = "simple"
    elseif complexity_choice == 3 then
      complexity = "detailed"
    end

    prompt = prompts.build_flowchart_prompt(filetype, code_content, complexity)
  elseif choice == 2 then
    diagram_type = "sequence"
    prompt = prompts.build_sequence_prompt(filetype, code_content)
  elseif choice == 3 then
    diagram_type = "class_diagram"
    prompt = prompts.build_class_diagram_prompt(filetype, code_content)
  elseif choice == 4 then
    diagram_type = "state_diagram"
    prompt = prompts.build_state_diagram_prompt(filetype, code_content)
  elseif choice == 5 then
    diagram_type = "er_diagram"
    prompt = prompts.build_er_diagram_prompt(filetype, code_content)
  end

  local output_file = dir .. "/" .. filename .. "_" .. diagram_type .. ".md"
  local title = filename .. " - " .. diagram_type:gsub("_", " "):gsub("^%l", string.upper)

  vim.notify("Generating " .. diagram_type:gsub("_", " ") .. "...", vim.log.levels.INFO)

  M.call_claude(prompt, output_file, title)
end

-- Preview diagram
M.preview = function()
  local content = table.concat(vim.api.nvim_buf_get_lines(0, 0, -1, false), "\n")
  if not content:match("```mermaid") then
    vim.notify("No mermaid diagram found", vim.log.levels.WARN)
    return
  end
  vim.cmd("MarkdownPreview")
end

return {
  "iamcco/markdown-preview.nvim",
  keys = {
    {
      "<leader>ma",
      function()
        M.generate_auto("moderate")
      end,
      desc = "Generate Diagram (Auto-detect type)"
    },
    {
      "<leader>mA",
      function()
        M.generate_auto("simple")
      end,
      desc = "Generate Simple Diagram (Auto)"
    },
    {
      "<leader>md",
      function()
        M.generate_manual()
      end,
      desc = "Generate Diagram (Choose type)"
    },
    {
      "<leader>mp",
      function()
        M.preview()
      end,
      desc = "Preview Diagram"
    },
  },
}
