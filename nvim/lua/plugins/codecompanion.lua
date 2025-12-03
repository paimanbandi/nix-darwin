return {
  "olimorris/codecompanion.nvim",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "nvim-treesitter/nvim-treesitter",
    "nvim-telescope/telescope.nvim",
  },
  config = function()
    require("codecompanion").setup({
      adapters = {
        ollama = function()
          return require("codecompanion.adapters").extend("ollama", {
            schema = {
              model = {
                default = "qwen2.5-coder:7b",
              },
              num_ctx = {
                default = 16384,
              },
              temperature = {
                default = 0.3,
              },
            },
          })
        end,
      },
      strategies = {
        chat = { adapter = "ollama" },
        inline = { adapter = "ollama" },
      },
      -- Custom prompts untuk berbagai use case
      prompts = {
        ["Documentation"] = {
          strategy = "inline",
          description = "Generate documentation",
          opts = {
            index = 1,
            is_default = true,
            is_slash_cmd = false,
            user_prompt = true,
          },
          prompts = {
            {
              role = "system",
              content = [[You are an expert at writing clear, comprehensive documentation.
Generate complete documentation for the provided code including:
- Function/class description
- Parameters with types
- Return values
- Usage examples
- Edge cases

Use the appropriate documentation format for the language (JSDoc, docstring, etc.)]],
            },
            {
              role = "user",
              content = function(context)
                return "Generate documentation for:\n\n" .. context.selection
              end,
            },
          },
        },
        ["Tests"] = {
          strategy = "inline",
          description = "Generate unit tests",
          prompts = {
            {
              role = "system",
              content = [[You are an expert at writing comprehensive unit tests.
Generate complete unit tests covering:
- Happy path scenarios
- Edge cases
- Error handling
- Mock dependencies if needed

Use the appropriate testing framework for the language.]],
            },
            {
              role = "user",
              content = function(context)
                return "Generate unit tests for:\n\n" .. context.selection
              end,
            },
          },
        },
        ["Refactor"] = {
          strategy = "inline",
          description = "Refactor code",
          prompts = {
            {
              role = "system",
              content = [[You are an expert at refactoring code.
Improve the code by:
- Following best practices and design patterns
- Improving readability and maintainability
- Optimizing performance
- Adding proper error handling
- Maintaining the same functionality]],
            },
            {
              role = "user",
              content = function(context)
                return "Refactor this code:\n\n" .. context.selection
              end,
            },
          },
        },
        ["Explain"] = {
          strategy = "chat",
          description = "Explain code",
          prompts = {
            {
              role = "system",
              content = "Explain the code in detail, covering logic, purpose, and any complex parts.",
            },
            {
              role = "user",
              content = function(context)
                return "Explain this code:\n\n" .. context.selection
              end,
            },
          },
        },
        ["Fix Bugs"] = {
          strategy = "inline",
          description = "Fix bugs in code",
          prompts = {
            {
              role = "system",
              content = [[Analyze the code for bugs and issues, then provide a fixed version.
Look for:
- Logic errors
- Memory leaks
- Race conditions
- Edge cases not handled
- Security vulnerabilities]],
            },
            {
              role = "user",
              content = function(context)
                return "Find and fix bugs in:\n\n" .. context.selection
              end,
            },
          },
        },
        ["Optimize"] = {
          strategy = "inline",
          description = "Optimize code performance",
          prompts = {
            {
              role = "system",
              content = [[Optimize the code for better performance.
Focus on:
- Time complexity
- Space complexity
- Unnecessary operations
- Better algorithms/data structures
- Caching opportunities]],
            },
            {
              role = "user",
              content = function(context)
                return "Optimize this code:\n\n" .. context.selection
              end,
            },
          },
        },
        ["Convert Language"] = {
          strategy = "inline",
          description = "Convert to another language",
          prompts = {
            {
              role = "system",
              content = "Convert the code to the target language, maintaining the same logic and structure.",
            },
            {
              role = "user",
              content = function(context)
                return "Convert this code to [TARGET_LANGUAGE]:\n\n" .. context.selection
              end,
              opts = {
                contains_code = true,
              },
            },
          },
        },
        ["Add Error Handling"] = {
          strategy = "inline",
          description = "Add comprehensive error handling",
          prompts = {
            {
              role = "system",
              content = [[Add robust error handling to the code:
- Try-catch blocks
- Input validation
- Proper error messages
- Graceful degradation
- Logging where appropriate]],
            },
            {
              role = "user",
              content = function(context)
                return "Add error handling to:\n\n" .. context.selection
              end,
            },
          },
        },
        ["Security Review"] = {
          strategy = "chat",
          description = "Review code for security issues",
          prompts = {
            {
              role = "system",
              content = [[Review the code for security vulnerabilities:
- SQL injection
- XSS vulnerabilities
- Authentication issues
- Data validation
- Sensitive data exposure
Provide specific recommendations.]],
            },
            {
              role = "user",
              content = function(context)
                return "Security review for:\n\n" .. context.selection
              end,
            },
          },
        },
        ["Generate Types"] = {
          strategy = "inline",
          description = "Generate TypeScript types/interfaces",
          prompts = {
            {
              role = "system",
              content =
              "Generate complete TypeScript types/interfaces for the code, including all properties and methods.",
            },
            {
              role = "user",
              content = function(context)
                return "Generate TypeScript types for:\n\n" .. context.selection
              end,
            },
          },
        },
      },
    })
  end,
  keys = {
    { "<leader>aa", "<cmd>CodeCompanionActions<cr>",     mode = { "n", "v" }, desc = "AI Actions" },
    { "<leader>ac", "<cmd>CodeCompanionChat Toggle<cr>", mode = { "n", "v" }, desc = "AI Chat" },
    { "<leader>ai", "<cmd>CodeCompanion<cr>",            mode = { "n", "v" }, desc = "AI Inline" },
    { "ga",         "<cmd>CodeCompanionChat Add<cr>",    mode = "v",          desc = "Add to AI Chat" },

    -- Quick access shortcuts
    { "<leader>ad", ":CodeCompanion Documentation<cr>",  mode = "v",          desc = "AI Documentation" },
    { "<leader>at", ":CodeCompanion Tests<cr>",          mode = "v",          desc = "AI Tests" },
    { "<leader>ar", ":CodeCompanion Refactor<cr>",       mode = "v",          desc = "AI Refactor" },
    { "<leader>ae", ":CodeCompanion Explain<cr>",        mode = "v",          desc = "AI Explain" },
    { "<leader>af", ":CodeCompanion Fix Bugs<cr>",       mode = "v",          desc = "AI Fix Bugs" },
    { "<leader>ao", ":CodeCompanion Optimize<cr>",       mode = "v",          desc = "AI Optimize" },
  },
}
