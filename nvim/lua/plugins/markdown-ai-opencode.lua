-- plugins/markdown-ai-opencode.lua
return {
  lazy = true,
  keys = {
    { "<leader>ma", "<cmd>lua require('markdown-ai-opencode').generate_auto()<cr>",      desc = "Mermaid AI: Auto generate" },
    { "<leader>mm", "<cmd>lua require('markdown-ai-opencode').generate_menu()<cr>",      desc = "Mermaid AI: Choose type" },
    { "<leader>mf", "<cmd>lua require('markdown-ai-opencode').generate_flowchart()<cr>", desc = "Mermaid AI: Flowchart" },
    { "<leader>ms", "<cmd>lua require('markdown-ai-opencode').generate_sequence()<cr>",  desc = "Mermaid AI: Sequence" },
    { "<leader>mc", "<cmd>lua require('markdown-ai-opencode').generate_class()<cr>",     desc = "Mermaid AI: Class" },
    { "<leader>mt", "<cmd>lua require('markdown-ai-opencode').generate_state()<cr>",     desc = "Mermaid AI: State" },
    { "<leader>me", "<cmd>lua require('markdown-ai-opencode').generate_er()<cr>",        desc = "Mermaid AI: ER Diagram" },
    { "<leader>mg", "<cmd>lua require('markdown-ai-opencode').generate_gantt()<cr>",     desc = "Mermaid AI: Gantt" },
    { "<leader>mp", "<cmd>lua require('markdown-ai-opencode').preview()<cr>",            desc = "Mermaid AI: Preview" },
  },
  config = function()
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

    -- Setup
    M.setup = function(opts)
      M.config = vim.tbl_deep_extend("force", M.config, opts or {})
    end

    -- Detector
    M.detector = {
      detect_diagram_type = function(code_content, filetype)
        local analysis = {
          has_classes = false,
          has_functions = false,
          has_loops = false,
          has_conditionals = false,
          has_database = false,
          has_state_changes = false,
          has_async = false,
          has_timing = false,
          has_ui = false,
          has_network = false,
          has_data_flow = false,
          has_hierarchy = false,
          has_dependencies = false,
        }

        local lower_content = code_content:lower()

        if lower_content:match("class%s+") or lower_content:match("struct%s+") then
          analysis.has_classes = true
        end

        if lower_content:match("function%s+") or lower_content:match("def%s+") then
          analysis.has_functions = true
        end

        if lower_content:match("for%s*%(") or lower_content:match("while%s*%(") then
          analysis.has_loops = true
        end

        if lower_content:match("if%s*%(") or lower_content:match("switch%s*%(") then
          analysis.has_conditionals = true
        end

        if lower_content:match("select%s+") or lower_content:match("from%s+") then
          analysis.has_database = true
        end

        if lower_content:match("state%s+") or lower_content:match("transition") then
          analysis.has_state_changes = true
        end

        if lower_content:match("async") or lower_content:match("await") then
          analysis.has_async = true
        end

        if lower_content:match("timer") or lower_content:match("schedule") then
          analysis.has_timing = true
        end

        return analysis
      end,

      recommend_diagram_type = function(analysis)
        local scores = {
          flowchart = 0,
          sequenceDiagram = 0,
          classDiagram = 0,
          ["stateDiagram-v2"] = 0,
          erDiagram = 0,
          journey = 0,
          gantt = 0,
        }

        if analysis.has_functions then
          scores.flowchart = scores.flowchart + 3
          scores.sequenceDiagram = scores.sequenceDiagram + 2
        end

        if analysis.has_classes then
          scores.classDiagram = scores.classDiagram + 5
        end

        if analysis.has_conditionals then
          scores.flowchart = scores.flowchart + 2
        end

        if analysis.has_database then
          scores.erDiagram = scores.erDiagram + 5
        end

        if analysis.has_state_changes then
          scores["stateDiagram-v2"] = scores["stateDiagram-v2"] + 5
        end

        if analysis.has_async then
          scores.sequenceDiagram = scores.sequenceDiagram + 3
        end

        if analysis.has_timing then
          scores.gantt = scores.gantt + 4
        end

        local max_score = 0
        local recommended = "flowchart"

        for dtype, score in pairs(scores) do
          if score > max_score then
            max_score = score
            recommended = dtype
          end
        end

        return recommended, scores
      end
    }

    -- Prompts
    M.prompts = {
      build_flowchart_prompt = function(filetype, code_content, complexity)
        local complexity_text = "moderate complexity"
        if complexity == "simple" then
          complexity_text = "simple flow with 20-30 nodes"
        elseif complexity == "detailed" then
          complexity_text = "detailed flow with 70-100 nodes"
        end

        return string.format([[
Create a comprehensive Mermaid flowchart for the following %s code.
Use flowchart syntax (NOT graph syntax).

Code:
```%s
%s
Requirements:

Use flowchart TD or LR direction

Show complete process flow from start to end

Include decision points with diamond shapes {}

Show error handling paths

Group related operations using subgraphs

Use proper node shapes:

[] for processes

{} for decisions

(()) for start/end

{{}} for input/output

Include clear labels on edges

Make it %s

Output ONLY the Mermaid flowchart code between mermaid and tags.
]], filetype, filetype, code_content, complexity_text)
      end,
      build_sequence_prompt = function(filetype, code_content)
        return string.format([[
    Create a detailed Mermaid sequence diagram for the following %s code.

Code: %s
Requirements:

Identify all participants/actors

Show synchronous and asynchronous messages

Include activation bars

Show return messages with dashed lines

Add loops (loop), alternatives (alt), and parallel (par) sections

Include notes for important interactions

Show object creation/destruction if present

Make the timeline clear and logical

Output ONLY the Mermaid sequence diagram code between mermaid and tags.
]], filetype, filetype, code_content)
      end,
      build_class_diagram_prompt = function(filetype, code_content)
        return string.format([[
    Create a comprehensive Mermaid class diagram for the following %s code.

Code: %s
Requirements:

Show all classes with properties and methods

Use proper visibility: + public, - private, # protected

Include data types where apparent

Show inheritance with -->|>

Show composition with *-- and aggregation with o--

Show associations with --

Show dependencies with ..>

Identify interfaces and abstract classes

Group related classes logically

Output ONLY the Mermaid class diagram code between mermaid and tags.
]], filetype, filetype, code_content)
      end,
      build_state_diagram_prompt = function(filetype, code_content)
        return string.format([[
    Create a Mermaid state diagram (stateDiagram-v2) for the following %s code.

Code: %s
Requirements:

Identify all states from the code

Include initial [] and final [] states

Show transitions with triggers: --> label : event

Include composite states when appropriate

Show choice nodes for decisions

Include fork/join for parallel states

Add history states if applicable

Make the state flow clear

Output ONLY the Mermaid stateDiagram-v2 code between mermaid and tags.
]], filetype, filetype, code_content)
      end,
      build_er_diagram_prompt = function(filetype, code_content)
        return string.format([[
    Create a Mermaid ER diagram for the following %s code.

Code: %s
Requirements:

Identify all entities/tables

Show attributes for each entity

Identify primary keys

Show relationships with proper cardinality:

||--o{ for one-to-many

||--|| for one-to-one

}o--o{ for many-to-many

Show weak entities if present

Include foreign key relationships

Make the database schema clear

Output ONLY the Mermaid ER diagram code between mermaid and tags.
]], filetype, filetype, code_content)
      end,
      build_gantt_prompt = function(filetype, code_content)
        return string.format([[
    Create a Mermaid Gantt chart for the following %s code.

Code: %s
Requirements:

Identify tasks/processes with durations

Show task dependencies

Group related tasks into sections

Include milestones for key points

Show progress if applicable

Use appropriate date format

Make the timeline clear

Output ONLY the Mermaid Gantt chart code between mermaid and tags.
]], filetype, filetype, code_content)
      end,
    }
    -- Diagram types
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
    }

    -- Helper functions
    M.get_diagram_name = function(diagram_type)
      local names = {
        flowchart = "Flowchart",
        sequenceDiagram = "Sequence Diagram",
        classDiagram = "Class Diagram",
        ["stateDiagram-v2"] = "State Diagram",
        erDiagram = "ER Diagram",
        journey = "User Journey",
        gantt = "Gantt Chart",
        pie = "Pie Chart",
        quadrantChart = "Quadrant Chart",
        requirementDiagram = "Requirement Diagram",
        gitGraph = "Git Graph",
        C4Context = "C4 Diagram",
        mindmap = "Mind Map",
        timeline = "Timeline",
      }
      return names[diagram_type] or diagram_type
    end

    M.build_prompt = function(diagram_type, filetype, code_content, complexity)
      if diagram_type == "flowchart" then
        return M.prompts.build_flowchart_prompt(filetype, code_content, complexity)
      elseif diagram_type == "sequenceDiagram" then
        return M.prompts.build_sequence_prompt(filetype, code_content)
      elseif diagram_type == "classDiagram" then
        return M.prompts.build_class_diagram_prompt(filetype, code_content)
      elseif diagram_type == "stateDiagram-v2" then
        return M.prompts.build_state_diagram_prompt(filetype, code_content)
      elseif diagram_type == "erDiagram" then
        return M.prompts.build_er_diagram_prompt(filetype, code_content)
      elseif diagram_type == "gantt" then
        return M.prompts.build_gantt_prompt(filetype, code_content)
      else
        return string.format([[
    Create a Mermaid %s diagram for the following %s code.

Code: %s
Output ONLY the Mermaid %s diagram code between mermaid and tags.
]], M.get_diagram_name(diagram_type), filetype, filetype, code_content, diagram_type)
      end
    end
    -- Core generation function
    M.generate_diagram = function(diagram_type, complexity)
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

      -- Call OpenCode.ai
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
          local mermaid_code = response:match("```mermaid\n(.-)```") or response:match("```\n(.-)```")

          if not mermaid_code then
            vim.notify("No valid Mermaid diagram found", vim.log.levels.ERROR)
            return
          end

          local md_content = string.format([[# %s
      Generated: %s
Tool: OpenCode.ai
Model: %s
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

    -- Public API functions
    M.generate_auto = function()
      local filetype = vim.bo.filetype
      local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
      local code_content = table.concat(lines, "\n")

      if #code_content == 0 then
        vim.notify("Buffer is empty", vim.log.levels.WARN)
        return
      end

      local analysis = M.detector.detect_diagram_type(code_content, filetype)
      local detected_type = M.detector.recommend_diagram_type(analysis)

      vim.notify("Auto-detected: " .. M.get_diagram_name(detected_type), vim.log.levels.INFO)
      M.generate_diagram(detected_type, M.config.default_complexity)
    end

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
        M.generate_diagram(diagram_type, complexity)
      else
        M.generate_diagram(diagram_type)
      end
    end

    M.generate_flowchart = function() M.generate_diagram("flowchart", "moderate") end
    M.generate_sequence = function() M.generate_diagram("sequenceDiagram") end
    M.generate_class = function() M.generate_diagram("classDiagram") end
    M.generate_state = function() M.generate_diagram("stateDiagram-v2") end
    M.generate_er = function() M.generate_diagram("erDiagram") end
    M.generate_gantt = function() M.generate_diagram("gantt") end

    M.preview = function()
      local content = table.concat(vim.api.nvim_buf_get_lines(0, 0, -1, false), "\n")
      if not content:match("```mermaid") then
        vim.notify("No mermaid diagram found", vim.log.levels.WARN)
        return
      end
      vim.cmd("MarkdownPreview")
    end

    -- Initialize
    _G.markdown_ai_opencode = M
    M.setup()
  end
}
