-- ~/.config/nvim/lua/plugins/gen.lua
return {
  "David-Kunz/gen.nvim",
  opts = {
    model = "qwen2.5-coder:7b",
    host = "localhost",
    port = "11434",
    quit_map = "q",
    retry_map = "<c-r>",
    init = function(options)
      pcall(io.popen, "ollama serve > /dev/null 2>&1 &")
    end,
    command = function(options)
      local body = {
        model = options.model,
        stream = true,
      }
      return "curl --silent --no-buffer -X POST http://"
          .. options.host
          .. ":"
          .. options.port
          .. "/api/chat -d $body"
    end,
    display_mode = "split",
    show_prompt = true,
    show_model = true,
    no_auto_close = false,
  },
  keys = {
    { "<leader>og", ":Gen<CR>",      mode = { "n", "v" }, desc = "Ollama Gen Menu" },
    { "<leader>oc", ":Gen Chat<CR>", mode = { "n", "v" }, desc = "Ollama Chat" },
  },
  config = function(_, opts)
    require("gen").setup(opts)

    -- Custom prompts
    require("gen").prompts["Generate_Docs"] = {
      prompt = "Generate comprehensive documentation with JSDoc/docstring format for:\n$text",
      replace = false,
    }
    require("gen").prompts["Generate_Tests"] = {
      prompt = "Generate complete unit tests with edge cases for:\n$text",
      replace = false,
    }
    require("gen").prompts["Explain_Code"] = {
      prompt = "Explain this code in detail:\n$text",
      replace = false,
    }
    require("gen").prompts["Refactor_Code"] = {
      prompt = "Refactor this code following best practices:\n$text",
      replace = true,
    }
    require("gen").prompts["Fix_Bugs"] = {
      prompt = "Find and fix bugs in:\n$text",
      replace = true,
    }
    require("gen").prompts["Add_Comments"] = {
      prompt = "Add clear inline comments explaining the logic:\n$text",
      replace = true,
    }
    require("gen").prompts["Optimize_Code"] = {
      prompt = "Optimize this code for better performance:\n$text",
      replace = true,
    }
    require("gen").prompts["Add_Error_Handling"] = {
      prompt = "Add comprehensive error handling to:\n$text",
      replace = true,
    }
  end,
}
