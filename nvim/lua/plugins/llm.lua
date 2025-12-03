-- ~/.config/nvim/lua/plugins/llm.lua
return {
  "huggingface/llm.nvim",
  lazy = false,
  config = function()
    local spinner_frames = { "⠋", "⠙", "⠹", "⠸", "⠼", "⠴", "⠦", "⠧", "⠇", "⠏" }

    local function ollama_query(prompt_text, action_name, save_to_file)
      local mode = vim.api.nvim_get_mode().mode
      if mode ~= "v" and mode ~= "V" and mode ~= "\22" then
        vim.notify("Please select code in visual mode", vim.log.levels.WARN)
        return
      end

      local start_line = vim.fn.line("'<")
      local end_line = vim.fn.line("'>")
      local lines = vim.api.nvim_buf_get_lines(0, start_line - 1, end_line, false)
      local code = table.concat(lines, "\n")

      if code == "" then
        vim.notify("No code selected", vim.log.levels.WARN)
        return
      end

      local filetype = vim.bo.filetype or "text"
      local full_prompt = string.format(
        "%s\n\nThis is %s code:\n\n```%s\n%s\n```",
        prompt_text,
        filetype,
        filetype,
        code
      )

      vim.notify("🤖 " .. action_name .. "...", vim.log.levels.INFO)

      local tmp_file = vim.fn.tempname()
      local f = io.open(tmp_file, "w")
      if not f then
        vim.notify("❌ Failed to create temp file", vim.log.levels.ERROR)
        return
      end

      local json_payload = vim.fn.json_encode({
        model = "qwen2.5-coder:7b",
        prompt = full_prompt,
        stream = true,
      })
      f:write(json_payload)
      f:close()

      local cmd = string.format("curl -s http://127.0.0.1:11434/api/generate -d @%s", tmp_file)

      local output_file = nil
      local output_dir = nil

      if save_to_file then
        -- Get current file directory
        local current_file_path = vim.fn.expand("%:p")
        if current_file_path == "" then
          output_dir = vim.fn.getcwd()
        else
          output_dir = vim.fn.fnamemodify(current_file_path, ":h")
        end

        local current_file = vim.fn.expand("%:t:r")
        if current_file == "" then
          current_file = "untitled"
        end

        local timestamp = os.date("%Y%m%d_%H%M%S")
        local action_slug = action_name:lower():gsub(" ", "_")

        -- Build full path
        output_file = string.format("%s/%s_%s_%s.md", output_dir, current_file, action_slug, timestamp)

        -- Debug: show where file will be saved
        vim.notify("📁 Will save to: " .. output_file, vim.log.levels.INFO)
      end

      vim.cmd("vsplit")
      local response_buf = vim.api.nvim_create_buf(false, true)
      vim.api.nvim_set_current_buf(response_buf)

      if output_file then
        vim.api.nvim_buf_set_name(response_buf, output_file)
        vim.bo[response_buf].buftype = "" -- Make it a real file
        vim.bo[response_buf].buflisted = true
      else
        vim.api.nvim_buf_set_name(response_buf, "Ollama: " .. action_name)
        vim.bo[response_buf].buftype = "nofile"
      end

      vim.bo[response_buf].bufhidden = "wipe"

      local spinner_idx = 1
      local loading_timer = vim.loop.new_timer()
      local is_loading = true

      local function update_loading()
        if is_loading then
          vim.schedule(function()
            local spinner = spinner_frames[spinner_idx]
            spinner_idx = (spinner_idx % #spinner_frames) + 1

            vim.api.nvim_buf_set_lines(response_buf, 0, -1, false, {
              spinner .. " Generating response...",
              "",
              "Please wait, this may take a moment.",
              "",
              "Model: qwen2.5-coder:7b",
            })
          end)
        end
      end

      loading_timer:start(0, 100, vim.schedule_wrap(update_loading))

      local accumulated_response = {}
      local has_response = false

      vim.fn.jobstart(cmd, {
        stdout_buffered = false,
        on_stdout = function(_, data)
          for _, line in ipairs(data) do
            if line ~= "" then
              local ok_json, result = pcall(vim.fn.json_decode, line)
              if ok_json and result.response then
                if not has_response then
                  has_response = true
                  is_loading = false
                  loading_timer:stop()
                end

                table.insert(accumulated_response, result.response)

                vim.schedule(function()
                  local full_text = table.concat(accumulated_response, "")
                  local response_lines = vim.split(full_text, "\n")
                  vim.api.nvim_buf_set_lines(response_buf, 0, -1, false, response_lines)
                end)
              end
            end
          end
        end,
        on_stderr = function(_, data)
          if data and #data > 0 and data[1] ~= "" then
            is_loading = false
            loading_timer:stop()
            vim.schedule(function()
              vim.api.nvim_buf_set_lines(response_buf, 0, -1, false, {
                "❌ Error occurred:",
                "",
                unpack(data)
              })
              vim.notify("❌ Error: " .. table.concat(data, "\n"), vim.log.levels.ERROR)
            end)
          end
        end,
        on_exit = function(_, exit_code)
          is_loading = false
          loading_timer:stop()
          loading_timer:close()

          vim.schedule(function()
            if exit_code == 0 then
              if not has_response then
                vim.api.nvim_buf_set_lines(response_buf, 0, -1, false, {
                  "⚠️  No response received from Ollama.",
                })
              else
                vim.bo[response_buf].filetype = "markdown"

                if output_file then
                  -- Force save
                  vim.bo[response_buf].modified = true

                  -- Try to save
                  local save_ok, save_err = pcall(function()
                    vim.cmd("write!")
                  end)

                  if save_ok then
                    -- Verify file exists
                    if vim.fn.filereadable(output_file) == 1 then
                      vim.notify("✅ Saved to: " .. output_file, vim.log.levels.INFO)
                    else
                      vim.notify("⚠️  Write command succeeded but file not found: " .. output_file, vim.log.levels.WARN)
                    end
                  else
                    vim.notify("❌ Failed to save: " .. tostring(save_err), vim.log.levels.ERROR)
                    vim.notify("💡 Try manual save: :w " .. output_file, vim.log.levels.INFO)
                  end
                else
                  vim.notify("✅ Done!", vim.log.levels.INFO)
                end
              end
            else
              vim.api.nvim_buf_set_lines(response_buf, 0, -1, false, {
                "❌ Request failed (exit code: " .. exit_code .. ")",
              })
              vim.notify("❌ Failed with exit code: " .. exit_code, vim.log.levels.ERROR)
            end

            vim.fn.delete(tmp_file)
          end)
        end,
      })
    end

    vim.keymap.set("v", "<leader>mc", function()
      ollama_query(
        "Add clear inline comments explaining the logic. Use the appropriate comment syntax for the language.",
        "Add Comments",
        false
      )
    end, { desc = "Add Comments" })

    vim.keymap.set("v", "<leader>md", function()
      local filetype = vim.bo.filetype
      local prompt = ""

      if filetype == "lua" then
        prompt = [[Generate comprehensive technical documentation in LuaDoc/EmmyLua format.

STRUCTURE YOUR RESPONSE AS FOLLOWS:

# Module/Function Overview
Provide a concise 2-3 sentence description of the main purpose and responsibility.

# API Documentation
For each function/class, include:
---@class ClassName (if applicable)
---@field fieldName type Description

---@param paramName type Description of parameter
---@return returnType Description of return value
function functionName(params)

# Architecture & Design
- Key design patterns used
- Component relationships
- Data flow

# Usage Examples
Provide 2-3 practical code examples showing:
1. Basic usage
2. Advanced usage
3. Common patterns

# Configuration
List any configuration options with:
- Parameter name
- Type
- Default value
- Description

# Dependencies
List external dependencies and their purpose.

# Notes & Best Practices
Include any important considerations or recommendations.]]
      elseif filetype == "typescript" or filetype == "typescriptreact" or filetype == "javascript" or filetype == "javascriptreact" then
        prompt = [[Generate comprehensive technical documentation in professional format.

STRUCTURE YOUR RESPONSE AS FOLLOWS:

# Component/Module Overview
## Purpose
Concise 2-3 sentence description of main functionality.

## Key Features
- Feature 1: Brief description
- Feature 2: Brief description
- Feature 3: Brief description

# API Reference
## Props/Parameters
| Name | Type | Required | Default | Description |
|------|------|----------|---------|-------------|
| propName | type | yes/no | value | Description |

## Methods/Functions
```typescript
functionName(params): returnType
```
Description of what the function does.

**Parameters:**
- `param1` (type): Description
- `param2` (type): Description

**Returns:**
- type: Description

**Example:**
```typescript
// Example usage
```

# Architecture
## Component Structure
Describe the component hierarchy and organization.

## State Management
Explain how state is managed (useState, custom hooks, etc.)

## Data Flow
Describe how data flows through the component.

# Usage Examples
## Basic Usage
```typescript
// Simple example
```

## Advanced Usage
```typescript
// Complex example with all features
```

## Common Patterns
```typescript
// Frequently used patterns
```

# Integration Guide
## Dependencies
List required packages and their versions.

## Setup
Step-by-step setup instructions.

# Best Practices
- Practice 1: Explanation
- Practice 2: Explanation
- Practice 3: Explanation

# Troubleshooting
Common issues and solutions.]]
      elseif filetype == "python" then
        prompt = [[Generate comprehensive technical documentation in Python format.

STRUCTURE YOUR RESPONSE AS FOLLOWS:

# Module/Class Overview
"""
Brief 2-3 sentence description of the module's purpose.
"""

# API Documentation
For each class/function, provide:
```python
class ClassName:
    """
    Comprehensive class description.

    Attributes:
        attr1 (type): Description
        attr2 (type): Description
    """

def function_name(param1: type, param2: type) -> return_type:
    """
    Function description.

    Args:
        param1: Description of param1
        param2: Description of param2

    Returns:
        Description of return value

    Raises:
        ExceptionType: When this exception is raised

    Examples:
        >>> function_name(value1, value2)
        expected_output
    """
```

# Architecture
Describe the module/class design and patterns used.

# Usage Examples
## Basic Example
```python
# Simple usage
```

## Advanced Example
```python
# Complex usage with all features
```

# Configuration
List configuration options if applicable.

# Dependencies
Required packages and versions.

# Best Practices
Guidelines for using this module effectively.]]
      else
        prompt = [[Generate comprehensive technical documentation.

STRUCTURE YOUR RESPONSE AS FOLLOWS:

# Overview
Provide 2-3 sentence description of purpose and functionality.

# Key Components
List and describe main components/functions.

# API Reference
Document all public interfaces with:
- Function/method signatures
- Parameter descriptions
- Return value descriptions
- Example usage

# Architecture
Explain design patterns and structure.

# Usage Examples
Provide practical examples showing:
1. Basic usage
2. Advanced usage
3. Common patterns

# Best Practices
List recommendations and guidelines.

# Dependencies
List external dependencies.]]
      end

      ollama_query(prompt, "Generate Docs", true)
    end, { desc = "Generate Docs" })

    vim.keymap.set("v", "<leader>mt", function()
      ollama_query(
        "Generate complete unit tests using the appropriate testing framework for this language.",
        "Generate Tests",
        true
      )
    end, { desc = "Generate Tests" })

    vim.keymap.set("v", "<leader>me", function()
      ollama_query(
        "Explain this code in detail.",
        "Explain Code",
        false
      )
    end, { desc = "Explain Code" })

    vim.keymap.set("v", "<leader>mr", function()
      ollama_query(
        "Refactor this code following best practices.",
        "Refactor",
        false
      )
    end, { desc = "Refactor" })

    vim.keymap.set("v", "<leader>mf", function()
      ollama_query(
        "Find and fix bugs in this code.",
        "Fix Bugs",
        false
      )
    end, { desc = "Fix Bugs" })

    vim.keymap.set("v", "<leader>mp", function()
      ollama_query(
        "Optimize this code for better performance.",
        "Optimize",
        false
      )
    end, { desc = "Optimize" })

    vim.keymap.set("v", "<leader>mh", function()
      ollama_query(
        "Add comprehensive error handling.",
        "Error Handling",
        false
      )
    end, { desc = "Error Handling" })
  end,
}
