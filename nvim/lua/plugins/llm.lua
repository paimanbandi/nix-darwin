-- ~/.config/nvim/lua/plugins/llm.lua
return {
  "huggingface/llm.nvim",
  lazy = false,
  config = function()
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

      -- Create temporary file untuk prompt
      local tmp_file = vim.fn.tempname()
      local f = io.open(tmp_file, "w")
      if not f then
        vim.notify("❌ Failed to create temp file", vim.log.levels.ERROR)
        return
      end

      -- Use streaming for better responsiveness
      local json_payload = vim.fn.json_encode({
        model = "qwen2.5-coder:7b",
        prompt = full_prompt,
        stream = true, -- Changed to true for streaming
      })
      f:write(json_payload)
      f:close()

      local cmd = string.format("curl -s http://127.0.0.1:11434/api/generate -d @%s", tmp_file)

      local output_file = nil
      if save_to_file then
        local current_file = vim.fn.expand("%:t:r")
        if current_file == "" then
          current_file = "untitled"
        end
        local timestamp = os.date("%Y%m%d_%H%M%S")
        local action_slug = action_name:lower():gsub(" ", "_")
        output_file = string.format("%s_%s_%s.md", current_file, action_slug, timestamp)
      end

      vim.cmd("vsplit")
      local response_buf = vim.api.nvim_create_buf(false, true)
      vim.api.nvim_set_current_buf(response_buf)

      if output_file then
        vim.api.nvim_buf_set_name(response_buf, output_file)
        vim.bo[response_buf].buftype = ""
      else
        vim.api.nvim_buf_set_name(response_buf, "Ollama: " .. action_name)
        vim.bo[response_buf].buftype = "nofile"
      end

      vim.api.nvim_buf_set_lines(response_buf, 0, -1, false, { "Generating response..." })
      vim.bo[response_buf].bufhidden = "wipe"

      local accumulated_response = {}

      vim.fn.jobstart(cmd, {
        stdout_buffered = false, -- Process streaming data line by line
        on_stdout = function(_, data)
          for _, line in ipairs(data) do
            if line ~= "" then
              local ok_json, result = pcall(vim.fn.json_decode, line)
              if ok_json and result.response then
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
            vim.schedule(function()
              vim.notify("❌ Error: " .. table.concat(data, "\n"), vim.log.levels.ERROR)
            end)
          end
        end,
        on_exit = function(_, exit_code)
          vim.schedule(function()
            if exit_code == 0 then
              vim.bo[response_buf].filetype = "markdown"
              vim.bo[response_buf].modified = false

              if output_file then
                vim.cmd("write")
                vim.notify("✅ Saved to: " .. output_file, vim.log.levels.INFO)
              else
                vim.notify("✅ Done!", vim.log.levels.INFO)
              end
            else
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
      local doc_format = "appropriate documentation format"

      if filetype == "lua" then
        doc_format = "LuaDoc/EmmyLua format (---@param, ---@return, etc)"
      elseif filetype == "python" then
        doc_format = "Python docstring format"
      elseif filetype == "javascript" or filetype == "typescript" then
        doc_format = "JSDoc format"
      end

      ollama_query(
        string.format(
          "Generate comprehensive documentation using %s. Include function/class description, parameters with types, return values, and usage examples.",
          doc_format),
        "Generate Docs",
        true
      )
    end, { desc = "Generate Docs" })

    vim.keymap.set("v", "<leader>mt", function()
      ollama_query(
        "Generate complete unit tests using the appropriate testing framework for this language. Include edge cases, error handling, and happy path scenarios.",
        "Generate Tests",
        true
      )
    end, { desc = "Generate Tests" })

    vim.keymap.set("v", "<leader>me", function()
      ollama_query(
        "Explain this code in detail. Cover the logic, purpose, and any complex parts.",
        "Explain Code",
        false
      )
    end, { desc = "Explain Code" })

    vim.keymap.set("v", "<leader>mr", function()
      ollama_query(
        "Refactor this code following best practices. Improve readability and maintainability.",
        "Refactor",
        false
      )
    end, { desc = "Refactor" })

    vim.keymap.set("v", "<leader>mf", function()
      ollama_query(
        "Find and fix bugs in this code. Look for logic errors and edge cases.",
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
        "Add comprehensive error handling with proper error messages.",
        "Error Handling",
        false
      )
    end, { desc = "Error Handling" })
  end,
}
