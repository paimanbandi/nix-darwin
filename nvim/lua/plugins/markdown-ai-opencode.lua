-- markdown-ai-opencode.lua
-- Generate Mermaid diagrams using OpenCode.ai instead of Claude

local M = {}
local prompts = require("plugins.markdown-ai-prompts")
local detector = require("plugins.markdown-ai-detector")

-----------------------------------------------------------------------
-- 🧠 Helper: Call OpenCode.ai CLI
-----------------------------------------------------------------------
M.call_opencode = function(prompt, output_file, title)
  local oc_path = vim.fn.system("which opencode"):gsub("\n", "")

  if oc_path == "" then
    vim.notify("OpenCode.ai CLI not found. Install via: npm i -g @opencode-ai/cli",
      vim.log.levels.ERROR)
    return
  end

  local temp_prompt = vim.fn.tempname() .. "_prompt.txt"
  local pf = io.open(temp_prompt, "w")

  if not pf then
    vim.notify("Failed to create temporary prompt file", vim.log.levels.ERROR)
    return
  end

  pf:write(prompt)
  pf:close()

  vim.notify("🤖 OpenCode.ai generating diagram...", vim.log.levels.INFO)

  local cmd = string.format("cat %s | opencode chat", vim.fn.shellescape(temp_prompt))
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

    on_exit = function(_, exit)
      pcall(os.remove, temp_prompt)

      if exit ~= 0 then
        vim.notify("❌ OpenCode.ai generation failed", vim.log.levels.ERROR)
        return
      end

      local response = table.concat(response_buffer, "\n")
      if not response:match("```mermaid") then
        vim.notify("❌ Invalid response (no mermaid blocks found)", vim.log.levels.ERROR)
        return
      end

      local md = string.format([[# %s

Generated: %s
Engine: OpenCode.ai
Source: %s

%s
]], title, os.date("%Y-%m-%d %H:%M:%S"), vim.fn.expand("%:t"), response)

      local file = io.open(output_file, "w")
      if file then
        file:write(md)
        file:close()
      end

      vim.notify("✅ Mermaid diagram generated (OpenCode.ai)", vim.log.levels.INFO)

      vim.schedule(function()
        vim.cmd("edit " .. vim.fn.fnameescape(output_file))
        vim.defer_fn(function()
          vim.cmd("MarkdownPreview")
        end, 200)
      end)
    end,
  })
end

-----------------------------------------------------------------------
-- 🚀 Auto-generate (same logic as markdown-ai.lua)
-----------------------------------------------------------------------
M.generate_auto = function(complexity)
  local filetype = vim.bo.filetype
  local filename = vim.fn.expand('%:t:r')
  local dir      = vim.fn.expand('%:p:h')
  local lines    = vim.api.nvim_buf_get_lines(0, 0, -1, false)
  local content  = table.concat(lines, "\n")

  if content == "" then
    vim.notify("⚠️ Nothing to analyze", vim.log.levels.WARN)
    return
  end

  local analysis = detector.detect_diagram_type(content, filetype)
  local recommended = select(1, detector.recommend_diagram_type(analysis))

  vim.notify("🔎 Auto-detect: " .. recommended, vim.log.levels.INFO)

  local prompt
  if recommended == "flowchart" then
    prompt = prompts.build_flowchart_prompt(filetype, content, complexity or "moderate")
  elseif recommended == "sequence" then
    prompt = prompts.build_sequence_prompt(filetype, content)
  elseif recommended == "class_diagram" then
    prompt = prompts.build_class_diagram_prompt(filetype, content)
  elseif recommended == "state_diagram" then
    prompt = prompts.build_state_diagram_prompt(filetype, content)
  elseif recommended == "er_diagram" then
    prompt = prompts.build_er_diagram_prompt(filetype, content)
  elseif recommended == "user_journey" then
    prompt = prompts.build_user_journey_prompt(filetype, content)
  elseif recommended == "gantt" then
    prompt = prompts.build_gantt_prompt(filetype, content)
  elseif recommended == "pie" then
    prompt = prompts.build_pie_prompt(filetype, content)
  elseif recommended == "quadrant" then
    prompt = prompts.build_quadrant_prompt(filetype, content)
  elseif recommended == "requirement" then
    prompt = prompts.build_requirement_prompt(filetype, content)
  elseif recommended == "gitgraph" then
    prompt = prompts.build_gitgraph_prompt(filetype, content)
  elseif recommended == "mindmap" then
    prompt = prompts.build_mindmap_prompt(filetype, content)
  elseif recommended == "timeline" then
    prompt = prompts.build_timeline_prompt(filetype, content)
  elseif recommended == "sankey" then
    prompt = prompts.build_sankey_prompt(filetype, content)
  elseif recommended == "xy_chart" then
    prompt = prompts.build_xy_chart_prompt(filetype, content)
  elseif recommended == "block_diagram" then
    prompt = prompts.build_block_diagram_prompt(filetype, content)
  elseif recommended == "packet" then
    prompt = prompts.build_packet_prompt(filetype, content)
  elseif recommended == "kanban" then
    prompt = prompts.build_kanban_prompt(filetype, content)
  elseif recommended == "architecture" then
    prompt = prompts.build_architecture_prompt(filetype, content)
  else
    prompt = prompts.build_flowchart_prompt(filetype, content, complexity or "moderate")
  end

  local output_file = dir .. "/" .. filename .. "_oc_" .. recommended .. ".md"
  local title = filename .. " - " .. recommended:gsub("_", " "):gsub("^%l", string.upper)

  M.call_opencode(prompt, output_file, title)
end

-----------------------------------------------------------------------
-- 🎛 Manual selection (same menu as main plugin)
-----------------------------------------------------------------------
M.generate_manual = function()
  local filetype = vim.bo.filetype
  local filename = vim.fn.expand("%:t:r")
  local dir      = vim.fn.expand("%:p:h")

  local lines    = vim.api.nvim_buf_get_lines(0, 0, -1, false)
  local content  = table.concat(lines, "\n")

  if content == "" then
    vim.notify("⚠️ No content", vim.log.levels.WARN)
    return
  end

  local choice = vim.fn.confirm(
    "Pick diagram type (OpenCode.ai):",
    "&1.Flowchart\n&2.Sequence\n&3.Class\n&4.State\n&5.ER\n&6.User-Journey\n&7.Gantt\n&8.Pie\n&9.Quadrant\n1&0.Requirement\n11.&GitGraph\n12.&Mindmap\n13.&Timeline\n14.San&key\n15.&XY\n16.&Block\n17.&Packet\n18.K&anban\n19.&Architecture\n20.&Cancel",
    1
  )
  if choice == 20 or choice == 0 then return end

  local types = {
    "flowchart", "sequence", "class_diagram", "state_diagram", "er_diagram",
    "user_journey", "gantt", "pie", "quadrant", "requirement",
    "gitgraph", "mindmap", "timeline", "sankey", "xy_chart",
    "block_diagram", "packet", "kanban", "architecture",
  }

  local t = types[choice]
  local prompt

  if t == "flowchart" then
    local c = vim.fn.confirm("Complexity?", "&Simple\n&Moderate\n&Detailed", 2)
    local lvl = ({ "simple", "moderate", "detailed" })[c]
    prompt = prompts.build_flowchart_prompt(filetype, content, lvl)
  elseif t == "sequence" then
    prompt = prompts.build_sequence_prompt(filetype, content)
  elseif t == "class_diagram" then
    prompt = prompts.build_class_diagram_prompt(filetype, content)
  elseif t == "state_diagram" then
    prompt = prompts.build_state_diagram_prompt(filetype, content)
  elseif t == "er_diagram" then
    prompt = prompts.build_er_diagram_prompt(filetype, content)
  elseif t == "user_journey" then
    prompt = prompts.build_user_journey_prompt(filetype, content)
  elseif t == "gantt" then
    prompt = prompts.build_gantt_prompt(filetype, content)
  elseif t == "pie" then
    prompt = prompts.build_pie_prompt(filetype, content)
  elseif t == "quadrant" then
    prompt = prompts.build_quadrant_prompt(filetype, content)
  elseif t == "requirement" then
    prompt = prompts.build_requirement_prompt(filetype, content)
  elseif t == "gitgraph" then
    prompt = prompts.build_gitgraph_prompt(filetype, content)
  elseif t == "mindmap" then
    prompt = prompts.build_mindmap_prompt(filetype, content)
  elseif t == "timeline" then
    prompt = prompts.build_timeline_prompt(filetype, content)
  elseif t == "sankey" then
    prompt = prompts.build_sankey_prompt(filetype, content)
  elseif t == "xy_chart" then
    prompt = prompts.build_xy_chart_prompt(filetype, content)
  elseif t == "block_diagram" then
    prompt = prompts.build_block_diagram_prompt(filetype, content)
  elseif t == "packet" then
    prompt = prompts.build_packet_prompt(filetype, content)
  elseif t == "kanban" then
    prompt = prompts.build_kanban_prompt(filetype, content)
  elseif t == "architecture" then
    prompt = prompts.build_architecture_prompt(filetype, content)
  end

  local output_file = dir .. "/" .. filename .. "_oc_" .. t .. ".md"
  local title = filename .. " - " .. t:gsub("_", " "):gsub("^%l", string.upper)

  M.call_opencode(prompt, output_file, title)
end

-----------------------------------------------------------------------
-- 🔑 Keybindings (mirroring markdown-ai, prefix: <leader>mo)
-----------------------------------------------------------------------
return {
  "iamcco/markdown-preview.nvim",
  keys = {
    {
      "<leader>mo",
      function() M.generate_auto("moderate") end,
      desc = "🧪 OpenCode.ai Auto Diagram"
    },
    {
      "<leader>mO",
      function() M.generate_auto("simple") end,
      desc = "🧪 OpenCode.ai Simple Auto Diagram"
    },
    {
      "<leader>mD",
      function() M.generate_manual() end,
      desc = "🧪 OpenCode.ai Manual Diagram"
    },
  }
}
