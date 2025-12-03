-- ~/.config/nvim/lua/plugins/llm.lua
return {
  "huggingface/llm.nvim",
  lazy = false,
  priority = 100,
  config = function()
    require("llm").setup({
      backend = "ollama",
      model = "qwen2.5-coder:7b",
      url = "http://127.0.0.1:11434/api/generate",
      tokens_to_clear = { "<|endoftext|>" },
      request_body = {
        options = {
          temperature = 0.2,
          top_p = 0.95,
        },
      },
      fim = {
        enabled = true,
        prefix = "<fim_prefix>",
        middle = "<fim_middle>",
        suffix = "<fim_suffix>",
      },
      context_window = 8192,
      enable_suggestions_on_startup = false,
      enable_suggestions_on_files = "*",
    })

    -- Helper untuk create prompt buffer
    local function create_prompt_buffer(title, content)
      vim.cmd("vsplit")
      local buf = vim.api.nvim_create_buf(false, true)
      vim.api.nvim_set_current_buf(buf)
      vim.api.nvim_buf_set_name(buf, title)
      vim.api.nvim_buf_set_lines(buf, 0, -1, false, vim.split(content, "\n"))
      vim.bo[buf].filetype = "markdown"
      vim.bo[buf].buftype = "nofile"
      return buf
    end

    -- Commands
    vim.api.nvim_create_user_command("LLMGenDocs", function()
      local start_line = vim.fn.line("'<")
      local end_line = vim.fn.line("'>")
      local lines = vim.api.nvim_buf_get_lines(0, start_line - 1, end_line, false)
      local code = table.concat(lines, "\n")

      local buf = create_prompt_buffer("Ollama: Documentation", "Generating documentation...\n\n" .. code)

      require("llm").prompt({
        replace = false,
        prompt = "Generate comprehensive documentation with JSDoc/docstring format for:\n\n" .. code,
      })
    end, { range = true })

    vim.api.nvim_create_user_command("LLMGenTests", function()
      local start_line = vim.fn.line("'<")
      local end_line = vim.fn.line("'>")
      local lines = vim.api.nvim_buf_get_lines(0, start_line - 1, end_line, false)
      local code = table.concat(lines, "\n")

      create_prompt_buffer("Ollama: Tests", "Generating tests...\n\n" .. code)

      require("llm").prompt({
        replace = false,
        prompt = "Generate complete unit tests for:\n\n" .. code,
      })
    end, { range = true })

    vim.api.nvim_create_user_command("LLMExplain", function()
      local start_line = vim.fn.line("'<")
      local end_line = vim.fn.line("'>")
      local lines = vim.api.nvim_buf_get_lines(0, start_line - 1, end_line, false)
      local code = table.concat(lines, "\n")

      create_prompt_buffer("Ollama: Explanation", "Explaining code...\n\n" .. code)

      require("llm").prompt({
        replace = false,
        prompt = "Explain this code in detail:\n\n" .. code,
      })
    end, { range = true })

    vim.api.nvim_create_user_command("LLMRefactor", function()
      local start_line = vim.fn.line("'<")
      local end_line = vim.fn.line("'>")
      local lines = vim.api.nvim_buf_get_lines(0, start_line - 1, end_line, false)
      local code = table.concat(lines, "\n")

      create_prompt_buffer("Ollama: Refactor", "Refactoring...\n\n" .. code)

      require("llm").prompt({
        replace = false,
        prompt = "Refactor this code following best practices:\n\n" .. code,
      })
    end, { range = true })

    vim.api.nvim_create_user_command("LLMFix", function()
      local start_line = vim.fn.line("'<")
      local end_line = vim.fn.line("'>")
      local lines = vim.api.nvim_buf_get_lines(0, start_line - 1, end_line, false)
      local code = table.concat(lines, "\n")

      create_prompt_buffer("Ollama: Fix", "Finding bugs...\n\n" .. code)

      require("llm").prompt({
        replace = false,
        prompt = "Find and fix bugs in:\n\n" .. code,
      })
    end, { range = true })

    -- Keymaps
    vim.keymap.set("v", "<leader>md", ":<C-u>'<,'>LLMGenDocs<CR>", { desc = "Generate Docs" })
    vim.keymap.set("v", "<leader>mt", ":<C-u>'<,'>LLMGenTests<CR>", { desc = "Generate Tests" })
    vim.keymap.set("v", "<leader>me", ":<C-u>'<,'>LLMExplain<CR>", { desc = "Explain Code" })
    vim.keymap.set("v", "<leader>mr", ":<C-u>'<,'>LLMRefactor<CR>", { desc = "Refactor" })
    vim.keymap.set("v", "<leader>mf", ":<C-u>'<,'>LLMFix<CR>", { desc = "Fix Bugs" })

    -- Toggle suggestions
    vim.keymap.set("n", "<leader>ms", function()
      require("llm").toggle_suggestions()
    end, { desc = "Toggle AI Suggestions" })
  end,
}
