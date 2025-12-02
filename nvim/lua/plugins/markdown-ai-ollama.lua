-- markdown-ai-ollama.lua
-- COMPLETE VERSION with ALL 19 diagram types
local M = {}
local prompts = require("plugins.markdown-ai-prompts")
local detector = require("plugins.markdown-ai-detector")

M.check = function()
  local result = vim.fn.system("ollama list 2>/dev/null")
  return result:match("qwen") or result:match("llama") or result:match("deepseek")
end

-- Generate with specific diagram type
M.generate = function(diagram_type, complexity)
  if not M.check() then
    vim.notify("❌ Run: ollama pull qwen2.5-coder:7b", vim.log.levels.ERROR)
    return
  end

  local filetype = vim.bo.filetype
  local filename = vim.fn.expand('%:t:r')
  local dir = vim.fn.expand('%:p:h')

  local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
  local code = table.concat(lines, "\n")

  if code == "" then
    vim.notify("⚠️  Empty file", vim.log.levels.WARN)
    return
  end

  -- Build prompt based on diagram type
  local prompt
  if diagram_type == "flowchart" then
    prompt = prompts.build_flowchart_prompt(filetype, code, complexity or "moderate")
  elseif diagram_type == "sequence" then
    prompt = prompts.build_sequence_prompt(filetype, code)
  elseif diagram_type == "class_diagram" then
    prompt = prompts.build_class_diagram_prompt(filetype, code)
  elseif diagram_type == "state_diagram" then
    prompt = prompts.build_state_diagram_prompt(filetype, code)
  elseif diagram_type == "er_diagram" then
    prompt = prompts.build_er_diagram_prompt(filetype, code)
  elseif diagram_type == "user_journey" then
    prompt = prompts.build_user_journey_prompt(filetype, code)
  elseif diagram_type == "gantt" then
    prompt = prompts.build_gantt_prompt(filetype, code)
  elseif diagram_type == "pie" then
    prompt = prompts.build_pie_prompt(filetype, code)
  elseif diagram_type == "quadrant" then
    prompt = prompts.build_quadrant_prompt(filetype, code)
  elseif diagram_type == "requirement" then
    prompt = prompts.build_requirement_prompt(filetype, code)
  elseif diagram_type == "gitgraph" then
    prompt = prompts.build_gitgraph_prompt(filetype, code)
  elseif diagram_type == "mindmap" then
    prompt = prompts.build_mindmap_prompt(filetype, code)
  elseif diagram_type == "timeline" then
    prompt = prompts.build_timeline_prompt(filetype, code)
  elseif diagram_type == "sankey" then
    prompt = prompts.build_sankey_prompt(filetype, code)
  elseif diagram_type == "xy_chart" then
    prompt = prompts.build_xy_chart_prompt(filetype, code)
  elseif diagram_type == "block_diagram" then
    prompt = prompts.build_block_diagram_prompt(filetype, code)
  elseif diagram_type == "packet" then
    prompt = prompts.build_packet_prompt(filetype, code)
  elseif diagram_type == "kanban" then
    prompt = prompts.build_kanban_prompt(filetype, code)
  elseif diagram_type == "architecture" then
    prompt = prompts.build_architecture_prompt(filetype, code)
  else
    prompt = prompts.build_flowchart_prompt(filetype, code, "moderate")
  end

  local output = dir .. "/" .. filename .. "_" .. diagram_type .. "_ollama.md"
  local prompt_file = dir .. "/.prompt_tmp.txt"

  local pf = io.open(prompt_file, "w")
  if not pf then
    vim.notify("❌ Cannot write", vim.log.levels.ERROR)
    return
  end
  pf:write(prompt)
  pf:close()

  vim.notify("🤖 Generating " .. diagram_type .. "...", vim.log.levels.INFO)

  local cmd = string.format('ollama run qwen2.5-coder:7b < %s', vim.fn.shellescape(prompt_file))

  vim.fn.jobstart({ 'bash', '-c', cmd }, {
    stdout_buffered = true,
    on_stdout = function(_, data)
      if not data then return end

      local response = table.concat(data, "\n")
      os.remove(prompt_file)

      if response == "" then
        vim.notify("❌ Empty response", vim.log.levels.ERROR)
        return
      end

      -- Extract mermaid
      local mermaid = response:match("```mermaid\n(.-)\n```")
      if mermaid then
        mermaid = "```mermaid\n" .. mermaid .. "\n```"
      else
        mermaid = response:match("```mermaid(.-)```")
        if mermaid then
          mermaid = "```mermaid" .. mermaid .. "```"
        end
      end

      if not mermaid then
        vim.notify("❌ No mermaid found", vim.log.levels.ERROR)

        -- Save debug
        local debug = output:gsub("%.md$", "_debug.txt")
        local df = io.open(debug, "w")
        if df then
          df:write("=== OLLAMA RESPONSE ===\n\n" .. response)
          df:close()
          vim.notify("📄 Debug: " .. debug, vim.log.levels.INFO)
        end
        return
      end

      -- Clean syntax
      mermaid = mermaid:gsub('"', ''):gsub("'", '')
      mermaid = mermaid:gsub('%[([^%]]+)%]', function(label)
        if #label > 20 then
          return '[' .. label:sub(1, 17) .. '...]'
        end
        return '[' .. label .. ']'
      end)

      -- Create markdown
      local title = filename .. " - " .. diagram_type:gsub("_", " "):upper()
      local md = string.format([[# %s

Generated: %s
Provider: Ollama (qwen2.5-coder:7b)
Source: %s

%s

---
*Generated locally with Ollama - Free & Unlimited*
]], title, os.date("%Y-%m-%d %H:%M:%S"), vim.fn.expand('%:t'), mermaid)

      local out = io.open(output, "w")
      if out then
        out:write(md)
        out:close()

        vim.schedule(function()
          vim.notify("✅ Diagram created!", vim.log.levels.INFO)
          vim.cmd("edit " .. vim.fn.fnameescape(output))
          vim.defer_fn(function()
            vim.cmd("MarkdownPreview")
          end, 500)
        end)
      end
    end,
  })
end

-- Auto-detect and generate
M.auto = function(complexity)
  local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
  local code = table.concat(lines, "\n")

  if code == "" then
    vim.notify("⚠️  No content", vim.log.levels.WARN)
    return
  end

  -- Auto-detect
  local analysis = detector.detect_diagram_type(code, vim.bo.filetype)
  local recommended = detector.recommend_diagram_type(analysis)

  vim.notify("💡 Detected: " .. recommended, vim.log.levels.INFO)

  M.generate(recommended, complexity)
end

-- Manual selection
M.manual = function()
  local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
  local code = table.concat(lines, "\n")

  if code == "" then
    vim.notify("⚠️  No content", vim.log.levels.WARN)
    return
  end

  local choice = vim.fn.confirm(
    "Select diagram type:",
    "&1.Flowchart\n" ..
    "&2.Sequence\n" ..
    "&3.Class\n" ..
    "&4.State\n" ..
    "&5.ER\n" ..
    "&6.User Journey\n" ..
    "&7.Gantt\n" ..
    "&8.Pie\n" ..
    "&9.Quadrant\n" ..
    "1&0.Requirement\n" ..
    "11.&GitGraph\n" ..
    "12.&Mindmap\n" ..
    "13.&Timeline\n" ..
    "14.&Sankey\n" ..
    "15.X&Y Chart\n" ..
    "16.&Block\n" ..
    "17.&Packet\n" ..
    "18.&Kanban\n" ..
    "19.&Architecture\n" ..
    "20.&Cancel",
    1
  )

  if choice == 20 or choice == 0 then return end

  local types = {
    "flowchart", "sequence", "class_diagram", "state_diagram", "er_diagram",
    "user_journey", "gantt", "pie", "quadrant", "requirement",
    "gitgraph", "mindmap", "timeline", "sankey", "xy_chart",
    "block_diagram", "packet", "kanban", "architecture"
  }

  local diagram_type = types[choice]
  local complexity = nil

  if diagram_type == "flowchart" then
    local comp_choice = vim.fn.confirm(
      "Complexity:",
      "&Simple\n&Moderate\n&Detailed",
      2
    )
    complexity = comp_choice == 1 and "simple" or (comp_choice == 3 and "detailed" or "moderate")
  end

  M.generate(diagram_type, complexity)
end

-- Show info
M.info = function()
  local ok = M.check()
  local models = vim.fn.system("ollama list 2>&1 | grep -v '^NAME'")

  vim.notify(string.format([[
╔══════════════════════════════════════════════════════════╗
║         Ollama Mermaid Generator (COMPLETE)              ║
╠══════════════════════════════════════════════════════════╣
║  Status: %s
║  Diagram Types: 19 supported
║
║  <leader>ml  - Auto-detect & generate
║  <leader>mL  - Manual selection
║  <leader>mS  - Simple auto (compact)
║  <leader>mi  - Show this info
╠══════════════════════════════════════════════════════════╣
║  Available Types:
║  • Core: Flowchart, Sequence, Class, State, ER
║  • UX: User Journey, Gantt, Timeline
║  • Data: Pie, Quadrant, XY Chart, Sankey
║  • Project: Requirement, Kanban, Mindmap
║  • Dev: GitGraph, Architecture, Block, Packet
╠══════════════════════════════════════════════════════════╣
║  Models:
%s
╠══════════════════════════════════════════════════════════╣
║  NOTE: For very complex files, Claude (<leader>ma)
║  may produce better results.
╚══════════════════════════════════════════════════════════╝
]], ok and "✅ Ready" or "❌ Not Ready", models), vim.log.levels.INFO)
end

return {
  "iamcco/markdown-preview.nvim",
  keys = {
    {
      "<leader>ml",
      function() M.auto("moderate") end,
      desc = "🤖 Ollama: Auto Diagram"
    },
    {
      "<leader>mL",
      function() M.manual() end,
      desc = "🤖 Ollama: Manual Select"
    },
    {
      "<leader>mS",
      function() M.auto("simple") end,
      desc = "🤖 Ollama: Simple Auto"
    },
    {
      "<leader>mi",
      function() M.info() end,
      desc = "ℹ️  Ollama: Info"
    },
  },
}
