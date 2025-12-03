-- ~/.config/nvim/lua/plugins/llm.lua
return {
  "huggingface/llm.nvim",
  lazy = false,
  config = function()
    -- Setup minimal llm (optional)
    local ok, llm = pcall(require, "llm")
    if ok then
      llm.setup({
        backend = "ollama",
        model = "qwen2.5-coder:7b",
        url = "http://127.0.0.1:11434/api/generate",
      })
    end

    -- Helper function untuk query ollama dengan curl
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

      -- Get filetype untuk context
      local filetype = vim.bo.filetype or "text"

      -- Build prompt dengan filetype context
      local full_prompt = string.format(
        "%s\n\nThis is %s code:\n\n```%s\n%s\n```",
        prompt_text,
        filetype,
        filetype,
        code
      )

      vim.notify("🤖 " .. action_name .. "...", vim.log.levels.INFO)

      -- Escape prompt untuk curl
      local escaped_prompt = full_prompt:gsub('"', '\\"'):gsub('\n', '\\n'):gsub('\r', '\\r')

      local cmd = string.format(
        [[curl -s http://127.0.0.1:11434/api/generate -d '{"model":"qwen2.5-coder:7b","prompt":"%s","stream":false}']],
        escaped_prompt
      )

      -- Tentukan output file jika save_to_file = true
      local output_file = nil
      if save_to_file then
        local current_file = vim.fn.expand("%:t:r") -- filename without extension
        local timestamp = os.date("%Y%m%d_%H%M%S")
        output_file = string.format("%s_%s_%s.md", current_file, action_name:lower():gsub(" ", "_"), timestamp)
      end

      -- Create split untuk response
      vim.cmd("vsplit")
      local response_buf = vim.api.nvim_create_buf(false, true)
      vim.api.nvim_set_current_buf(response_buf)

      if output_file then
        vim.api.nvim_buf_set_name(response_buf, output_file)
        vim.bo[response_buf].buftype = "" -- Make it a real file buffer
      else
        vim.api.nvim_buf_set_name(response_buf, "Ollama: " .. action_name)
        vim.bo[response_buf].buftype = "nofile"
      end

      vim.api.nvim_buf_set_lines(response_buf, 0, -1, false, { "Waiting for response..." })
      vim.bo[response_buf].bufhidden = "wipe"

      vim.fn.jobstart(cmd, {
        stdout_buffered = true,
        on_stdout = function(_, data)
          if data and #data > 0 then
            local json_str = table.concat(data, "")
            if json_str ~= "" then
              local ok_json, result = pcall(vim.fn.json_decode, json_str)
              if ok_json and result.response then
                vim.schedule(function()
                  local response_lines = vim.split(result.response, "\n")
                  vim.api.nvim_buf_set_lines(response_buf, 0, -1, false, response_lines)
                  vim.bo[response_buf].filetype = "markdown"
                  vim.bo[response_buf].modified = false

                  if output_file then
                    vim.cmd("write") -- Auto-save
                    vim.notify("✅ Saved to: " .. output_file, vim.log.levels.INFO)
                  else
                    vim.notify("✅ Done!", vim.log.levels.INFO)
                  end
                end)
              else
                vim.schedule(function()
                  vim.api.nvim_buf_set_lines(response_buf, 0, -1, false, { "Error parsing JSON", json_str })
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
      })
    end

    -- Keymaps - DENGAN save to file
    vim.keymap.set("v", "<leader>mc", function()
      ollama_query(
        "Add clear inline comments explaining the logic. Use the appropriate comment syntax for the language.",
        "Add Comments",
        false -- Don't save to file
      )
    end, { desc = "Add Comments" })

    vim.keymap.set("v", "<leader>md", function()
      local filetype = vim.bo.filetype
      local doc_style = "appropriate documentation format"

      if filetype == "lua" then
        doc_style = "LuaDoc/EmmyLua format"
      elseif filetype == "python" then
        doc_style = "Python docstring format"
      elseif filetype == "javascript" or filetype == "typescript" then
        doc_style = "JSDoc format"
      elseif filetype == "go" then
        doc_style = "Go doc comment format"
      elseif filetype == "rust" then
        doc_style = "Rust doc comment format"
      end

      ollama_query(
        string.format(
          "Generate comprehensive documentation using %s. Include function/class description, parameters with types, return values, and usage examples.",
          doc_style
        ),
        "Generate Docs",
        true -- SAVE TO FILE
      )
    end, { desc = "Generate Docs" })

    vim.keymap.set("v", "<leader>mt", function()
      ollama_query(
        "Generate complete unit tests using the appropriate testing framework for this language. Include edge cases, error handling, and happy path scenarios.",
        "Generate Tests",
        true -- SAVE TO FILE
      )
    end, { desc = "Generate Tests" })

    vim.keymap.set("v", "<leader>me", function()
      ollama_query(
        "Explain this code in detail. Cover the logic, purpose, and any complex parts. Be specific about the language features being used.",
        "Explain Code",
        false -- Don't save
      )
    end, { desc = "Explain Code" })

    vim.keymap.set("v", "<leader>mr", function()
      ollama_query(
        "Refactor this code following best practices for this specific language. Improve readability, maintainability, and performance while keeping the same functionality.",
        "Refactor",
        false -- Don't save
      )
    end, { desc = "Refactor" })

    vim.keymap.set("v", "<leader>mf", function()
      ollama_query(
        "Find and fix bugs in this code. Look for logic errors, edge cases not handled, language-specific issues, and potential problems.",
        "Fix Bugs",
        false -- Don't save
      )
    end, { desc = "Fix Bugs" })

    vim.keymap.set("v", "<leader>mp", function()
      ollama_query(
        "Optimize this code for better performance using language-specific optimizations. Focus on time complexity, space complexity, and unnecessary operations.",
        "Optimize",
        false -- Don't save
      )
    end, { desc = "Optimize" })

    vim.keymap.set("v", "<leader>mh", function()
      ollama_query(
        "Add comprehensive error handling using the appropriate error handling patterns for this language (try-catch, Result types, etc.). Include input validation and proper error messages.",
        "Error Handling",
        false -- Don't save
      )
    end, { desc = "Error Handling" })
  end,
}
