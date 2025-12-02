-- markdown-ai-opencode.lua
-- Complete Mermaid diagram generator using OpenCode.ai
-- Supports ALL Mermaid diagram types

local M = {}

-- Configuration
M.config = {
  opencode_cmd = "opencode",
  default_model = "gpt-4",
  max_tokens = 4000,
  temperature = 0.2,
  output_dir = nil,
  auto_preview = true,
  preview_delay = 200,
  default_complexity = "moderate",
}

-- ALL Mermaid diagram types from official documentation
M.diagram_types = {
  "flowchart",
  "sequenceDiagram",
  "classDiagram",
  "stateDiagram-v2",
  "erDiagram",
  "journey",
  "gantt",
  "pie",
  "quadrantChart",
  "requirementDiagram",
  "gitGraph",
  "C4Context",
  "mindmap",
  "timeline",
  "zenuml",
  "sankey-beta",
  "xyChart",
  "block",
  "packet",
  "kanban",
  "architecture",
  "radar",
  "treemap"
}

-- Get readable names
M.get_diagram_name = function(diagram_type)
  local names = {
    flowchart = "Flowchart",
    sequenceDiagram = "Sequence Diagram",
    classDiagram = "Class Diagram",
    ["stateDiagram-v2"] = "State Diagram",
    erDiagram = "Entity Relationship Diagram",
    journey = "User Journey",
    gantt = "Gantt Chart",
    pie = "Pie Chart",
    quadrantChart = "Quadrant Chart",
    requirementDiagram = "Requirement Diagram",
    gitGraph = "Git Graph",
    C4Context = "C4 Diagram",
    mindmap = "Mind Map",
    timeline = "Timeline",
    zenuml = "ZenUML",
    ["sankey-beta"] = "Sankey Diagram",
    xyChart = "XY Chart",
    block = "Block Diagram",
    packet = "Packet Diagram",
    kanban = "Kanban Board",
    architecture = "Architecture Diagram",
    radar = "Radar Chart",
    treemap = "Tree Map"
  }
  return names[diagram_type] or diagram_type
end

-- Setup
M.setup = function(user_config)
  M.config = vim.tbl_deep_extend("force", M.config, user_config or {})
end

-- Validate Mermaid syntax
M.validate_mermaid = function(content)
  if not content then return false end

  local styled_nodes = {}
  for node_id in content:gmatch("style%s+(%w+)%s+fill") do
    styled_nodes[node_id] = true
  end

  local has_issues = false
  for node_id, _ in pairs(styled_nodes) do
    if not content:match(node_id .. "%s*%[") and
        not content:match(node_id .. "%s*%(") and
        not content:match(node_id .. "%s*{") then
      has_issues = true
    end
  end

  local is_valid = false
  for _, dtype in ipairs(M.diagram_types) do
    if content:match("^%s*" .. dtype) then
      is_valid = true
      break
    end
  end

  if content:match("^%s*%%%{%s*init") then
    is_valid = true
  end

  return is_valid and not has_issues
end

-- Extract mermaid code
M.extract_mermaid_code = function(response)
  if not response then return nil end

  local mermaid_blocks = {}

  for block in response:gmatch("```%s*mermaid%s*\n(.-)```") do
    table.insert(mermaid_blocks, block)
  end

  for block in response:gmatch("```%s*\n(.-)```") do
    local is_mermaid = false
    for _, dtype in ipairs(M.diagram_types) do
      if block:match("^%s*" .. dtype) then
        is_mermaid = true
        break
      end
    end
    if block:match("^%s*%%%{%s*init") then is_mermaid = true end
    if is_mermaid then table.insert(mermaid_blocks, block) end
  end

  if #mermaid_blocks == 0 then
    for _, dtype in ipairs(M.diagram_types) do
      if response:match("^%s*" .. dtype) then
        return response
      end
    end
    if response:match("^%s*%%%{%s*init") then return response end
  end

  if #mermaid_blocks > 0 then
    table.sort(mermaid_blocks, function(a, b) return #a > #b end)
    return mermaid_blocks[1]
  end

  return nil
end

-- Call OpenCode.ai
M.call_opencode = function(prompt, output_file, title)
  local opencode_path = vim.fn.system("which " .. M.config.opencode_cmd):gsub("\n", "")

  if opencode_path == "" then
    vim.notify("OpenCode CLI not found. Install: npm install -g opencode.ai", vim.log.levels.ERROR)
    return
  end

  vim.notify("Generating " .. title .. " with OpenCode.ai...", vim.log.levels.INFO)

  local temp_prompt = vim.fn.tempname() .. "_prompt.txt"
  local prompt_file = io.open(temp_prompt, "w")
  if not prompt_file then
    vim.notify("Failed to create temp file", vim.log.levels.ERROR)
    return
  end
  prompt_file:write(prompt)
  prompt_file:close()

  local cmd = string.format("%s generate --prompt-file %s --model %s --max-tokens %d --temperature %.1f",
    M.config.opencode_cmd, vim.fn.shellescape(temp_prompt),
    M.config.default_model, M.config.max_tokens, M.config.temperature)

  local response_buffer = {}

  vim.fn.jobstart(cmd, {
    stdout_buffered = true,
    on_stdout = function(_, data)
      if data then
        for _, line in ipairs(data) do
          if line ~= "" then table.insert(response_buffer, line) end
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
      local mermaid_code = M.extract_mermaid_code(response)

      if not mermaid_code then
        vim.notify("No valid Mermaid diagram found", vim.log.levels.ERROR)
        return
      end

      local md_content = string.format([[# %s

Generated: %s
Tool: OpenCode.ai
Model: %s

```mermaid
%s
Generated from code analysis.]], title, os.date("%Y-%m-%d %H:%M:%S"), M.config.default_model, mermaid_code)
      local output_dir = vim.fn.fnamemodify(output_file, ":h")
      if output_dir ~= "." and vim.fn.isdirectory(output_dir) == 0 then
        vim.fn.mkdir(output_dir, "p")
      end

      local file = io.open(output_file, "w")
      if file then
        file:write(md_content)
        file:close()

        vim.notify("Diagram saved: " .. output_file, vim.log.levels.INFO)

        if M.config.auto_preview then
          vim.schedule(function()
            vim.cmd("edit " .. vim.fn.fnameescape(output_file))
            vim.defer_fn(function()
              vim.cmd("MarkdownPreview")
            end, M.config.preview_delay)
          end)
        end
      end
    end

  })
end

-- Build prompts for ALL diagram types
M.build_prompt = function(diagram_type, filetype, code_content, complexity)
  local base_prompt = "Generate a Mermaid %s diagram for the following code.\n\nCode Language: %s\nCode:\n%s\n%s\n\n\n"
  local specifics = ""
  local end_instruction =
  "Output ONLY the Mermaid diagram code between mermaid and markers. Use proper Mermaid %s syntax.\n"

  if diagram_type == "flowchart" then
    specifics =
        "Create a flowchart showing process flow. Use flowchart TD or LR syntax (not 'graph'). Include: nodes with proper shapes (rectangle [], diamond {}, circle (()), parallelogram {{}}), edges with labels, subgraphs for grouping, and logical flow direction. Complexity: " ..
        (complexity or "moderate") .. ".\n"
  elseif diagram_type == "sequenceDiagram" then
    specifics =
    "Create a sequence diagram showing interactions over time. Include: participants, synchronous/asynchronous messages, activation bars, return messages, loops (loop), alternatives (alt/opt), notes, and proper timing.\n"
  elseif diagram_type == "classDiagram" then
    specifics =
    "Create a class diagram showing object-oriented structure. Include: classes with methods/properties, visibility (+ public, - private, # protected), inheritance (-->|>), composition (*--), aggregation (o--), associations (--), dependencies (..>), and interfaces.\n"
  elseif diagram_type == "stateDiagram-v2" then
    specifics =
    "Create a state diagram showing state transitions. Use stateDiagram-v2 syntax. Include: states, initial [*] and final [*], transitions with events (--> label : event), composite states, choice nodes, fork/join, and history states.\n"
  elseif diagram_type == "erDiagram" then
    specifics =
    "Create an Entity Relationship diagram. Include: entities with attributes, primary keys (PK), relationships with cardinality (||--o{ one-to-many, ||--|| one-to-one, }o--o{ many-to-many), weak entities, and foreign keys.\n"
  elseif diagram_type == "journey" then
    specifics =
    "Create a User Journey diagram. Include: sections, tasks with actors, states (active, done, pending), and connections showing user flow through different stages.\n"
  elseif diagram_type == "gantt" then
    specifics =
    "Create a Gantt chart. Include: title, date format, sections, tasks with IDs/durations/dependencies, milestones, and progress tracking.\n"
  elseif diagram_type == "pie" then
    specifics = "Create a Pie chart. Include: title, data values with labels, and show distribution percentages.\n"
  elseif diagram_type == "quadrantChart" then
    specifics =
    "Create a Quadrant chart. Include: title, x-axis label, y-axis label, quadrant labels (Q1-Q4), and plotted points with labels.\n"
  elseif diagram_type == "requirementDiagram" then
    specifics =
    "Create a Requirement diagram. Include: requirements with IDs/types, relationships (contains, derives, satisfies, verifies), and elements (container, rectangle, ellipse).\n"
  elseif diagram_type == "gitGraph" then
    specifics =
    "Create a Git Graph. Include: main branch, feature branches, commits with messages/hashes, merge operations, tags, and checkout points.\n"
  elseif diagram_type == "C4Context" then
    specifics =
    "Create a C4 Context diagram. Include: system boundary, people/systems, containers, relationships with labels/technologies, and proper C4 notation.\n"
  elseif diagram_type == "mindmap" then
    specifics =
    "Create a Mind Map. Include: root node, branches, leaves, hierarchical structure, and use shapes/colors for different categories.\n"
  elseif diagram_type == "timeline" then
    specifics =
    "Create a Timeline. Include: title, sections, events with dates/descriptions, and chronological ordering.\n"
  elseif diagram_type == "zenuml" then
    specifics =
    "Create a ZenUML sequence diagram. Include: participants, messages with conditions/loops, lifelines, notes, and proper ZenUML syntax.\n"
  elseif diagram_type == "sankey-beta" then
    specifics =
    "Create a Sankey Diagram. Include: nodes representing sources/targets, flows with values, labels, and show energy/material/information flow.\n"
  elseif diagram_type == "xyChart" then
    specifics =
    "Create an XY Chart. Include: x-axis and y-axis labels, data points/series, grid lines, legends, and proper chart formatting.\n"
  elseif diagram_type == "block" then
    specifics =
    "Create a Block Diagram. Include: blocks with labels, connections between blocks, input/output points, and hierarchical structure.\n"
  elseif diagram_type == "packet" then
    specifics =
    "Create a Packet Diagram. Include: protocol layers, packet headers, data segments, encapsulation, and network flow.\n"
  elseif diagram_type == "kanban" then
    specifics =
    "Create a Kanban Board. Include: columns (To Do, In Progress, Done), cards with titles/descriptions, assignees, and swimlanes.\n"
  elseif diagram_type == "architecture" then
    specifics =
    "Create an Architecture Diagram. Include: components, layers, dependencies, data flow, and technology stack.\n"
  elseif diagram_type == "radar" then
    specifics =
    "Create a Radar Chart. Include: axes representing metrics, data series, area shading, and comparative analysis.\n"
  elseif diagram_type == "treemap" then
    specifics =
    "Create a Tree Map. Include: hierarchical data structure, rectangles sized by value, color coding, and nested levels.\n"
  end

  return string.format(base_prompt .. specifics .. end_instruction,
    M.get_diagram_name(diagram_type), filetype, filetype, code_content, diagram_type)
end

-- Generate diagram
M.generate = function(diagram_type, complexity)
  local filetype = vim.bo.filetype
  local filename = vim.fn.expand('%:t:r')
  local dir = M.config.output_dir or vim.fn.expand('%:p:h')

  local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
  local code_content = table.concat(lines, "\n")

  if #code_content == 0 then
    vim.notify("Buffer is empty", vim.log.levels.WARN)
    return
  end

  local prompt = M.build_prompt(diagram_type, filetype, code_content, complexity)
  local output_file = dir .. "/" .. filename .. "_" .. diagram_type .. ".md"
  local title = filename .. " - " .. M.get_diagram_name(diagram_type)

  M.call_opencode(prompt, output_file, title)
end

-- Interactive menu
M.generate_menu = function()
  local choices = {}
  for i, dtype in ipairs(M.diagram_types) do
    table.insert(choices, string.format("&%d. %s", i, M.get_diagram_name(dtype)))
  end
  table.insert(choices, "&Cancel")

  local choice = vim.fn.confirm(
    "Select Mermaid Diagram Type:",
    table.concat(choices, "\n"),
    1
  )

  if choice == 0 or choice > #M.diagram_types then return end

  local diagram_type = M.diagram_types[choice]

  if diagram_type == "flowchart" then
    local complexity_choice = vim.fn.confirm(
      "Select complexity:",
      "&Simple (20-30 nodes)\n&Moderate (40-60 nodes)\n&Detailed (70-100 nodes)",
      2
    )
    local complexity = "moderate"
    if complexity_choice == 1 then
      complexity = "simple"
    elseif complexity_choice == 3 then
      complexity = "detailed"
    end
    M.generate(diagram_type, complexity)
  else
    M.generate(diagram_type)
  end
end

-- Auto-detect and generate
M.generate_auto = function()
  local filetype = vim.bo.filetype
  local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
  local code_content = table.concat(lines, "\n")

  if #code_content == 0 then
    vim.notify("Buffer is empty", vim.log.levels.WARN)
    return
  end

  -- Simple detection
  local lower_content = code_content:lower()
  local detected_type = "flowchart"

  if lower_content:match("class%s+") or lower_content:match("struct%s+") then
    detected_type = "classDiagram"
  elseif lower_content:match("async%s+") or lower_content:match("await%s+") then
    detected_type = "sequenceDiagram"
  elseif lower_content:match("state%s+") or lower_content:match("transition%s+") then
    detected_type = "stateDiagram-v2"
  elseif lower_content:match("select%s+") or lower_content:match("from%s+") then
    detected_type = "erDiagram"
  elseif lower_content:match("time%s+") or lower_content:match("schedule%s+") then
    detected_type = "gantt"
  end

  vim.notify("Auto-detected: " .. M.get_diagram_name(detected_type), vim.log.levels.INFO)
  M.generate(detected_type, "moderate")
end

-- Quick shortcuts for common diagrams
M.quick_flowchart = function() M.generate("flowchart", "moderate") end
M.quick_sequence = function() M.generate("sequenceDiagram") end
M.quick_class = function() M.generate("classDiagram") end
M.quick_state = function() M.generate("stateDiagram-v2") end
M.quick_er = function() M.generate("erDiagram") end
M.quick_gantt = function() M.generate("gantt") end

-- Preview
M.preview = function()
  local content = table.concat(vim.api.nvim_buf_get_lines(0, 0, -1, false), "\n")
  if not content:match("```mermaid") then
    vim.notify("No mermaid diagram found", vim.log.levels.WARN)
    return
  end
  vim.cmd("MarkdownPreview")
end

-- Key bindings setup
M.set_keymaps = function()
  local map = function(mode, lhs, rhs, desc)
    vim.keymap.set(mode, lhs, rhs, { noremap = true, silent = true, desc = desc })
  end

  -- Main bindings
  map('n', '<leader>ma', M.generate_auto, 'OpenCode: Auto-generate diagram')
  map('n', '<leader>mm', M.generate_menu, 'OpenCode: Choose diagram type')

  -- Quick diagrams
  map('n', '<leader>mf', M.quick_flowchart, 'OpenCode: Flowchart')
  map('n', '<leader>ms', M.quick_sequence, 'OpenCode: Sequence Diagram')
  map('n', '<leader>mc', M.quick_class, 'OpenCode: Class Diagram')
  map('n', '<leader>mt', M.quick_state, 'OpenCode: State Diagram')
  map('n', '<leader>me', M.quick_er, 'OpenCode: ER Diagram')
  map('n', '<leader>mg', M.quick_gantt, 'OpenCode: Gantt Chart')

  -- Preview
  map('n', '<leader>mp', M.preview, 'OpenCode: Preview diagram')
end

-- Initialize
M.init = function()
  M.set_keymaps()
  vim.notify("OpenCode Mermaid Generator loaded with " .. #M.diagram_types .. " diagram types", vim.log.levels.INFO)
end

-- Export
return M
