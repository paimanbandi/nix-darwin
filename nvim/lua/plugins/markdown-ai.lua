-- markdown-ai.lua
-- Main plugin with ALL diagram types support
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
    vim.notify("Claude CLI not found. Install: npm install -g @anthropic-ai/claude-cli", vim.log.levels.ERROR)
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

  vim.notify("🎨 Generating diagram... (10-30 seconds)", vim.log.levels.INFO)

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
        vim.notify("❌ Generation failed", vim.log.levels.ERROR)
        return
      end

      local response = table.concat(response_buffer, "\n")

      if not response:match("```mermaid") then
        vim.notify("❌ Invalid response: No mermaid blocks found", vim.log.levels.ERROR)
        return
      end

      local md_content = string.format([[# %s

Generated: %s
Source: %s

%s
]], title, os.date("%Y-%m-%d %H:%M:%S"), vim.fn.expand('%:t'), response)

      local file = io.open(output_file, "w")
      if file then
        file:write(md_content)
        file:close()

        vim.notify("✅ Diagram generated successfully!", vim.log.levels.INFO)

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

  if code_content == "" then
    vim.notify("⚠️  No content to analyze", vim.log.levels.WARN)
    return
  end

  -- Auto-detect best diagram type
  local analysis = detector.detect_diagram_type(code_content, filetype)
  local recommended, scores = detector.recommend_diagram_type(analysis)

  vim.notify("🔍 Analyzing code...", vim.log.levels.INFO)
  vim.notify("💡 Recommended: " .. recommended, vim.log.levels.INFO)

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
  elseif recommended == "er_diagram" then
    prompt = prompts.build_er_diagram_prompt(filetype, code_content)
  elseif recommended == "user_journey" then
    prompt = prompts.build_user_journey_prompt(filetype, code_content)
  elseif recommended == "gantt" then
    prompt = prompts.build_gantt_prompt(filetype, code_content)
  elseif recommended == "pie" then
    prompt = prompts.build_pie_prompt(filetype, code_content)
  elseif recommended == "quadrant" then
    prompt = prompts.build_quadrant_prompt(filetype, code_content)
  elseif recommended == "requirement" then
    prompt = prompts.build_requirement_prompt(filetype, code_content)
  elseif recommended == "gitgraph" then
    prompt = prompts.build_gitgraph_prompt(filetype, code_content)
  elseif recommended == "mindmap" then
    prompt = prompts.build_mindmap_prompt(filetype, code_content)
  elseif recommended == "timeline" then
    prompt = prompts.build_timeline_prompt(filetype, code_content)
  elseif recommended == "sankey" then
    prompt = prompts.build_sankey_prompt(filetype, code_content)
  elseif recommended == "xy_chart" then
    prompt = prompts.build_xy_chart_prompt(filetype, code_content)
  elseif recommended == "block_diagram" then
    prompt = prompts.build_block_diagram_prompt(filetype, code_content)
  elseif recommended == "packet" then
    prompt = prompts.build_packet_prompt(filetype, code_content)
  elseif recommended == "kanban" then
    prompt = prompts.build_kanban_prompt(filetype, code_content)
  elseif recommended == "architecture" then
    prompt = prompts.build_architecture_prompt(filetype, code_content)
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

  if code_content == "" then
    vim.notify("⚠️  No content to analyze", vim.log.levels.WARN)
    return
  end

  -- Show comprehensive selection menu
  local choice = vim.fn.confirm(
    "Select diagram type:",
    "&1.Flowchart\n" ..
    "&2.Sequence\n" ..
    "&3.Class\n" ..
    "&4.State\n" ..
    "&5.ER Diagram\n" ..
    "&6.User Journey\n" ..
    "&7.Gantt\n" ..
    "&8.Pie Chart\n" ..
    "&9.Quadrant\n" ..
    "1&0.Requirement\n" ..
    "11.&GitGraph\n" ..
    "12.&Mindmap\n" ..
    "13.&Timeline\n" ..
    "14.Sank&ey\n" ..
    "15.&XY Chart\n" ..
    "16.&Block\n" ..
    "17.&Packet\n" ..
    "18.K&anban\n" ..
    "19.&Architecture\n" ..
    "20.&Cancel",
    1
  )

  if choice == 20 or choice == 0 then
    return
  end

  local diagram_types = {
    "flowchart", "sequence", "class_diagram", "state_diagram", "er_diagram",
    "user_journey", "gantt", "pie", "quadrant", "requirement",
    "gitgraph", "mindmap", "timeline", "sankey", "xy_chart",
    "block_diagram", "packet", "kanban", "architecture"
  }

  local diagram_type = diagram_types[choice]
  local prompt

  -- Build appropriate prompt
  if diagram_type == "flowchart" then
    local complexity_choice = vim.fn.confirm(
      "Select complexity:",
      "&Simple (30 nodes)\n&Moderate (50 nodes)\n&Detailed (80 nodes)",
      2
    )
    local complexity = complexity_choice == 1 and "simple" or (complexity_choice == 3 and "detailed" or "moderate")
    prompt = prompts.build_flowchart_prompt(filetype, code_content, complexity)
  elseif diagram_type == "sequence" then
    prompt = prompts.build_sequence_prompt(filetype, code_content)
  elseif diagram_type == "class_diagram" then
    prompt = prompts.build_class_diagram_prompt(filetype, code_content)
  elseif diagram_type == "state_diagram" then
    prompt = prompts.build_state_diagram_prompt(filetype, code_content)
  elseif diagram_type == "er_diagram" then
    prompt = prompts.build_er_diagram_prompt(filetype, code_content)
  elseif diagram_type == "user_journey" then
    prompt = prompts.build_user_journey_prompt(filetype, code_content)
  elseif diagram_type == "gantt" then
    prompt = prompts.build_gantt_prompt(filetype, code_content)
  elseif diagram_type == "pie" then
    prompt = prompts.build_pie_prompt(filetype, code_content)
  elseif diagram_type == "quadrant" then
    prompt = prompts.build_quadrant_prompt(filetype, code_content)
  elseif diagram_type == "requirement" then
    prompt = prompts.build_requirement_prompt(filetype, code_content)
  elseif diagram_type == "gitgraph" then
    prompt = prompts.build_gitgraph_prompt(filetype, code_content)
  elseif diagram_type == "mindmap" then
    prompt = prompts.build_mindmap_prompt(filetype, code_content)
  elseif diagram_type == "timeline" then
    prompt = prompts.build_timeline_prompt(filetype, code_content)
  elseif diagram_type == "sankey" then
    prompt = prompts.build_sankey_prompt(filetype, code_content)
  elseif diagram_type == "xy_chart" then
    prompt = prompts.build_xy_chart_prompt(filetype, code_content)
  elseif diagram_type == "block_diagram" then
    prompt = prompts.build_block_diagram_prompt(filetype, code_content)
  elseif diagram_type == "packet" then
    prompt = prompts.build_packet_prompt(filetype, code_content)
  elseif diagram_type == "kanban" then
    prompt = prompts.build_kanban_prompt(filetype, code_content)
  elseif diagram_type == "architecture" then
    prompt = prompts.build_architecture_prompt(filetype, code_content)
  end

  local output_file = dir .. "/" .. filename .. "_" .. diagram_type .. ".md"
  local title = filename .. " - " .. diagram_type:gsub("_", " "):gsub("^%l", string.upper)

  vim.notify("🎨 Generating " .. diagram_type:gsub("_", " ") .. "...", vim.log.levels.INFO)

  M.call_claude(prompt, output_file, title)
end

-- Preview diagram
M.preview = function()
  local content = table.concat(vim.api.nvim_buf_get_lines(0, 0, -1, false), "\n")
  if not content:match("```mermaid") then
    vim.notify("⚠️  No mermaid diagram found in current buffer", vim.log.levels.WARN)
    return
  end
  vim.cmd("MarkdownPreview")
end

-- Show help
M.show_help = function()
  local help_text = [[
╔══════════════════════════════════════════════════════════╗
║         Mermaid Diagram Generator - Quick Help           ║
╠══════════════════════════════════════════════════════════╣
║ <leader>ma  - Auto-generate (detect best type)          ║
║ <leader>mA  - Auto-generate (simple/compact)            ║
║ <leader>md  - Manual selection (choose type)            ║
║ <leader>mp  - Preview current diagram                   ║
║ <leader>mh  - Show this help                            ║
╠══════════════════════════════════════════════════════════╣
║ Available Diagram Types (19 total):                     ║
║                                                          ║
║ Core: Flowchart, Sequence, Class, State, ER             ║
║ UX: User Journey, Gantt, Timeline                       ║
║ Data: Pie, Quadrant, XY Chart, Sankey                   ║
║ Project: Requirement, Kanban, Mindmap                   ║
║ Dev: GitGraph, Architecture (C4), Block, Packet         ║
╚══════════════════════════════════════════════════════════╝
]]
  vim.notify(help_text, vim.log.levels.INFO)
end

return {
  "iamcco/markdown-preview.nvim",
  keys = {
    {
      "<leader>ma",
      function()
        M.generate_auto("moderate")
      end,
      desc = "📊 Generate Diagram (Auto-detect)"
    },
    {
      "<leader>mA",
      function()
        M.generate_auto("simple")
      end,
      desc = "📊 Generate Simple Diagram (Auto)"
    },
    {
      "<leader>md",
      function()
        M.generate_manual()
      end,
      desc = "📝 Generate Diagram (Choose type)"
    },
    {
      "<leader>mp",
      function()
        M.preview()
      end,
      desc = "👁️  Preview Diagram"
    },
    {
      "<leader>mh",
      function()
        M.show_help()
      end,
      desc = "❓ Show Help"
    },
  },
}
