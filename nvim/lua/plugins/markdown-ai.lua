-- markdown-ai.lua
-- Main interface and keymaps

local M = {}
local config = require("plugins.markdown-ai-config")
local core = require("plugins.markdown-ai-core")
local providers = require("plugins.markdown-ai-providers")
local prompts = require("plugins.markdown-ai-prompts")
local detector = require("plugins.markdown-ai-detector")

-- Setup plugin
M.setup = function(user_config)
  config.setup(user_config)

  -- Register keymaps
  M.register_keymaps()

  vim.notify("✅ Mermaid Diagram Generator ready", vim.log.levels.INFO)
end

-- Register keymaps
M.register_keymaps = function()
  local keymaps = {
    -- Auto-generate with default provider
    {
      "<leader>ma",
      function() M.generate_auto() end,
      desc = "📊 Generate Diagram (Auto)"
    },

    -- Auto-generate with simple complexity
    {
      "<leader>mA",
      function() M.generate_auto("simple") end,
      desc = "📊 Generate Simple Diagram"
    },

    -- Manual selection with provider choice
    {
      "<leader>md",
      function() M.generate_manual() end,
      desc = "📝 Generate Diagram (Choose)"
    },

    -- Generate with specific provider
    {
      "<leader>mp",
      function() M.generate_with_provider_choice() end,
      desc = "🤖 Generate with Provider"
    },

    -- Preview diagram
    {
      "<leader>mv",
      function() M.preview_diagram() end,
      desc = "👁️ Preview Diagram"
    },

    -- Show provider status
    {
      "<leader>ms",
      function() config.show_provider_status() end,
      desc = "🔧 Show Provider Status"
    },

    -- Show help
    {
      "<leader>mh",
      function() M.show_help() end,
      desc = "❓ Show Help"
    },

    -- Set default provider
    {
      "<leader>mc",
      function() M.configure_provider() end,
      desc = "⚙️ Configure Provider"
    },
  }

  for _, keymap in ipairs(keymaps) do
    vim.keymap.set("n", keymap[1], keymap[2], { desc = keymap.desc })
  end
end

-- Auto-generate diagram
M.generate_auto = function(complexity)
  local code_content = core.get_buffer_content()
  if not code_content then return end

  local filetype = vim.bo.filetype
  local diagram_type, scores = core.auto_detect_diagram(code_content, filetype)

  vim.notify("🔍 Detected: " .. diagram_type, vim.log.levels.INFO)

  M.generate_diagram(diagram_type, complexity)
end

-- Generate diagram with specific type
M.generate_diagram = function(diagram_type, complexity, provider_name)
  local code_content = core.get_buffer_content()
  if not code_content then return end

  local filetype = vim.bo.filetype
  local prompt = core.build_diagram_prompt(diagram_type, filetype, code_content, complexity)

  local output_file = core.generate_output_filename(diagram_type)
  local title = core.get_diagram_title(diagram_type)

  local provider = provider_name or config.config.provider

  vim.notify("🎨 Generating " .. diagram_type .. " with " .. provider .. "...", vim.log.levels.INFO)

  providers.call_provider(provider, prompt, output_file, title, function(success, mermaid_code, provider_used)
    if success and mermaid_code then
      local saved = core.save_diagram_file(mermaid_code, output_file, title, provider_used)
      if saved then
        M.open_and_preview(output_file)
      end
    end
  end)
end

-- Manual generation with provider choice
M.generate_manual = function()
  providers.select_provider(function(provider)
    if not provider then return end

    -- Then select diagram type
    M.select_diagram_type(function(diagram_type)
      if not diagram_type then return end

      -- Optional: select complexity for flowcharts
      local complexity = "moderate"
      if diagram_type == "flowchart" then
        complexity = M.select_complexity()
        if not complexity then return end
      end

      M.generate_diagram(diagram_type, complexity, provider)
    end)
  end)
end

-- Generate with provider choice only
M.generate_with_provider_choice = function()
  providers.select_provider(function(provider)
    if not provider then return end

    local code_content = core.get_buffer_content()
    if not code_content then return end

    local filetype = vim.bo.filetype
    local diagram_type = core.auto_detect_diagram(code_content, filetype)

    M.generate_diagram(diagram_type, "moderate", provider)
  end)
end

-- Select diagram type
M.select_diagram_type = function(callback)
  local diagram_types = {
    "flowchart", "sequence", "class_diagram", "state_diagram", "er_diagram",
    "user_journey", "gantt", "pie", "quadrant", "requirement",
    "gitgraph", "mindmap", "timeline", "sankey", "xy_chart",
    "block_diagram", "packet", "kanban", "architecture"
  }

  local display_names = {
    "Flowchart", "Sequence Diagram", "Class Diagram", "State Diagram", "ER Diagram",
    "User Journey", "Gantt Chart", "Pie Chart", "Quadrant Chart", "Requirement Diagram",
    "Git Graph", "Mind Map", "Timeline", "Sankey Diagram", "XY Chart",
    "Block Diagram", "Packet Diagram", "Kanban Board", "Architecture Diagram"
  }

  local menu_text = "Select Diagram Type:\n\n"
  for i, display_name in ipairs(display_names) do
    menu_text = menu_text .. string.format("&%d. %s\n", i, display_name)
  end

  menu_text = menu_text .. string.format("&%d. Cancel", #diagram_types + 1)

  local choice = vim.fn.confirm(menu_text, "", #diagram_types + 1)

  if choice == 0 or choice > #diagram_types then
    if callback then callback(nil) end
    return nil
  end

  local selected_type = diagram_types[choice]

  if callback then
    callback(selected_type)
  end

  return selected_type
end

-- Select complexity level
M.select_complexity = function()
  local choice = vim.fn.confirm(
    "Select Complexity Level:",
    "&1. Simple (20-30 nodes)\n&2. Moderate (40-50 nodes)\n&3. Detailed (70-80 nodes)\n&4. Cancel",
    2
  )

  if choice == 1 then
    return "simple"
  elseif choice == 2 then
    return "moderate"
  elseif choice == 3 then
    return "detailed"
  else
    return nil
  end
end

-- Open and preview diagram
M.open_and_preview = function(filepath)
  vim.schedule(function()
    vim.cmd("edit " .. vim.fn.fnameescape(filepath))
    vim.defer_fn(function()
      vim.cmd("MarkdownPreview")
    end, 300)
  end)
end

-- Preview current diagram
M.preview_diagram = function()
  local content = table.concat(vim.api.nvim_buf_get_lines(0, 0, -1, false), "\n")
  if not content:match("```mermaid") then
    vim.notify("⚠️  No mermaid diagram found in current buffer", vim.log.levels.WARN)
    return
  end
  vim.cmd("MarkdownPreview")
end

-- Configure provider
M.configure_provider = function()
  local choice = vim.fn.confirm(
    "Configure:",
    "&1. Set Default Provider\n&2. Toggle Auto-detect\n&3. Change Save Path\n&4. Cancel",
    1
  )

  if choice == 1 then
    providers.select_provider(function(provider)
      if provider then
        config.set_default_provider(provider)
      end
    end)
  elseif choice == 2 then
    config.config.auto_detect = not config.config.auto_detect
    local status = config.config.auto_detect and "enabled" or "disabled"
    vim.notify("✅ Auto-detect " .. status, vim.log.levels.INFO)
  elseif choice == 3 then
    local new_path = vim.fn.input("Save path: ", config.config.save_path)
    if new_path and new_path ~= "" then
      config.config.save_path = new_path
      vim.fn.mkdir(new_path, "p")
      vim.notify("✅ Save path set to: " .. new_path, vim.log.levels.INFO)
    end
  end
end

-- Show help
M.show_help = function()
  local help_text = [[
╔══════════════════════════════════════════════════════════╗
║      Multi-Provider Diagram Generator - Quick Help       ║
╠══════════════════════════════════════════════════════════╣
║ <leader>ma  - Auto-generate (default provider)          ║
║ <leader>mA  - Auto-generate (simple/compact)            ║
║ <leader>md  - Manual (choose provider + diagram type)   ║
║ <leader>mp  - Choose provider only                      ║
║ <leader>mv  - Preview current diagram                   ║
║ <leader>ms  - Show provider status                      ║
║ <leader>mc  - Configure settings                        ║
║ <leader>mh  - Show this help                            ║
╠══════════════════════════════════════════════════════════╣
║ Supported Providers: Claude, DeepSeek, OpenAI           ║
║ Default: Claude                                         ║
╚══════════════════════════════════════════════════════════╝
]]

  vim.notify(help_text, vim.log.levels.INFO)
end

return {
  setup = M.setup,
  generate_auto = M.generate_auto,
  generate_manual = M.generate_manual,
  preview_diagram = M.preview_diagram,
  show_help = M.show_help,
}
