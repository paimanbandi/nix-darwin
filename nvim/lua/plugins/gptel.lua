-- ~/.config/nvim/lua/plugins/gptel.lua
return {
  "robitx/gptel.nvim",
  config = function()
    local ollama_url = "http://localhost:11434"

    require("gptel").setup({
      providers = {
        ollama = {
          name = "Ollama",
          endpoint = ollama_url .. "/v1/chat/completions",
          secret = "dummy", -- Ollama doesn't need API key
        },
      },
      default_provider = "ollama",
      default_model = "qwen2.5-coder:7b",
      chat_shortcut_respond = { modes = { "n", "i", "v", "x" }, shortcut = "<C-g><C-g>" },
      chat_shortcut_delete = { modes = { "n", "i", "v", "x" }, shortcut = "<C-g>d" },
      chat_shortcut_stop = { modes = { "n", "i", "v", "x" }, shortcut = "<C-g>s" },
      chat_shortcut_new = { modes = { "n", "i", "v", "x" }, shortcut = "<C-g>c" },
      chat_dir = vim.fn.stdpath("data") .. "/gptel/chats",
      chat_confirm_delete = true,
      chat_free_cursor = false,
      default_command_agent = "ChatGPT4o-mini",
      default_chat_agent = "ollama",
      agents = {
        {
          name = "ollama",
          provider = "ollama",
          chat = true,
          command = false,
          model = { model = "qwen2.5-coder:7b", temperature = 0.2, top_p = 0.95 },
          system_prompt = "You are a helpful AI assistant for coding.",
        },
      },
    })

    -- Custom commands untuk rewrite
    vim.api.nvim_create_user_command("GpDocsGen", function(opts)
      local prompt =
      "Generate comprehensive documentation with JSDoc/docstring format for the selected code. Include function description, parameters with types, return values, and usage examples."
      require("gptel").rewrite({ prompt = prompt, range = opts.range })
    end, { range = true })

    vim.api.nvim_create_user_command("GpTestGen", function(opts)
      local prompt =
      "Generate complete unit tests with edge cases, error handling, and happy path scenarios for the selected code."
      require("gptel").rewrite({ prompt = prompt, range = opts.range })
    end, { range = true })

    vim.api.nvim_create_user_command("GpExplain", function(opts)
      local prompt = "Explain this code in detail, covering the logic, purpose, and any complex parts."
      require("gptel").rewrite({ prompt = prompt, range = opts.range })
    end, { range = true })

    vim.api.nvim_create_user_command("GpRefactor", function(opts)
      local prompt =
      "Refactor this code following best practices, improving readability, maintainability, and performance while keeping the same functionality."
      require("gptel").rewrite({ prompt = prompt, range = opts.range })
    end, { range = true })

    vim.api.nvim_create_user_command("GpFixBugs", function(opts)
      local prompt =
      "Find and fix bugs in this code. Look for logic errors, edge cases not handled, and potential issues."
      require("gptel").rewrite({ prompt = prompt, range = opts.range })
    end, { range = true })

    vim.api.nvim_create_user_command("GpAddComments", function(opts)
      local prompt = "Add clear inline comments explaining the logic and purpose of this code."
      require("gptel").rewrite({ prompt = prompt, range = opts.range })
    end, { range = true })

    vim.api.nvim_create_user_command("GpOptimize", function(opts)
      local prompt =
      "Optimize this code for better performance. Focus on time complexity, space complexity, and unnecessary operations."
      require("gptel").rewrite({ prompt = prompt, range = opts.range })
    end, { range = true })

    vim.api.nvim_create_user_command("GpErrorHandle", function(opts)
      local prompt =
      "Add comprehensive error handling with try-catch blocks, input validation, and proper error messages."
      require("gptel").rewrite({ prompt = prompt, range = opts.range })
    end, { range = true })
  end,
  keys = {
    -- Chat
    { "<leader>ng", "<cmd>GpChatNew vsplit<cr>",    desc = "New AI Chat",      mode = { "n", "v" } },
    { "<leader>nt", "<cmd>GpChatToggle vsplit<cr>", desc = "Toggle AI Chat",   mode = { "n", "v" } },
    { "<leader>nf", "<cmd>GpChatFinder<cr>",        desc = "Find Chats",       mode = { "n", "v" } },

    -- Actions (Visual mode only)
    { "<leader>nd", ":<C-u>'<,'>GpDocsGen<cr>",     desc = "Generate Docs",    mode = "v" },
    { "<leader>ns", ":<C-u>'<,'>GpTestGen<cr>",     desc = "Generate Tests",   mode = "v" },
    { "<leader>ne", ":<C-u>'<,'>GpExplain<cr>",     desc = "Explain Code",     mode = "v" },
    { "<leader>nr", ":<C-u>'<,'>GpRefactor<cr>",    desc = "Refactor",         mode = "v" },
    { "<leader>nb", ":<C-u>'<,'>GpFixBugs<cr>",     desc = "Fix Bugs",         mode = "v" },
    { "<leader>nm", ":<C-u>'<,'>GpAddComments<cr>", desc = "Add Comments",     mode = "v" },
    { "<leader>np", ":<C-u>'<,'>GpOptimize<cr>",    desc = "Optimize",         mode = "v" },
    { "<leader>nh", ":<C-u>'<,'>GpErrorHandle<cr>", desc = "Error Handling",   mode = "v" },

    -- Quick rewrite dengan custom prompt
    { "<leader>nw", ":<C-u>'<,'>GpRewrite<cr>",     desc = "Rewrite (custom)", mode = "v" },
    { "<leader>na", ":<C-u>'<,'>GpAppend<cr>",      desc = "Append",           mode = "v" },
    { "<leader>nx", "<cmd>GpContext vsplit<cr>",    desc = "Open Context",     mode = { "n", "v" } },
  },
}
