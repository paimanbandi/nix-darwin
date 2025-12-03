-- ~/.config/nvim/lua/plugins/ollama.lua
return {
  "nomnivore/ollama.nvim",
  dependencies = {
    "nvim-lua/plenary.nvim",
  },
  cmd = { "Ollama", "OllamaModel", "OllamaServe", "OllamaServeStop" },
  keys = {
    -- Sample keybind for prompt menu
    { "<leader>ng", ":<c-u>lua require('ollama').prompt()<cr>",                 desc = "Ollama Prompt",  mode = { "n", "v" } },

    -- Direct actions
    { "<leader>nd", ":<c-u>lua require('ollama').prompt('Generate_Docs')<cr>",  desc = "Generate Docs",  mode = "v" },
    { "<leader>ns", ":<c-u>lua require('ollama').prompt('Generate_Tests')<cr>", desc = "Generate Tests", mode = "v" },
    { "<leader>ne", ":<c-u>lua require('ollama').prompt('Explain_Code')<cr>",   desc = "Explain",        mode = "v" },
    { "<leader>nr", ":<c-u>lua require('ollama').prompt('Refactor_Code')<cr>",  desc = "Refactor",       mode = "v" },
    { "<leader>nf", ":<c-u>lua require('ollama').prompt('Fix_Code')<cr>",       desc = "Fix Code",       mode = "v" },
  },
  opts = {
    model = "qwen2.5-coder:7b",
    url = "http://127.0.0.1:11434",
    serve = {
      on_start = false,
      command = "ollama",
      args = { "serve" },
      stop_command = "pkill",
      stop_args = { "-SIGTERM", "ollama" },
    },
    prompts = {
      Generate_Docs = {
        prompt =
        "Generate comprehensive documentation with JSDoc/docstring format for this code. Include function description, parameters with types, return values, and usage examples:\n\n$sel",
        input_label = "> ",
        model = "qwen2.5-coder:7b",
        action = "display",
      },
      Generate_Tests = {
        prompt =
        "Generate complete unit tests with edge cases, error handling, and happy path scenarios for this code:\n\n$sel",
        input_label = "> ",
        model = "qwen2.5-coder:7b",
        action = "display",
      },
      Explain_Code = {
        prompt = "Explain this code in detail, covering the logic, purpose, and any complex parts:\n\n$sel",
        input_label = "> ",
        model = "qwen2.5-coder:7b",
        action = "display",
      },
      Refactor_Code = {
        prompt = "Refactor this code following best practices, improving readability and maintainability:\n\n$sel",
        input_label = "> ",
        model = "qwen2.5-coder:7b",
        action = "replace",
      },
      Fix_Code = {
        prompt = "Fix bugs and issues in this code:\n\n$sel",
        input_label = "> ",
        model = "qwen2.5-coder:7b",
        action = "replace",
      },
      Add_Comments = {
        prompt = "Add clear inline comments explaining the logic:\n\n$sel",
        input_label = "> ",
        model = "qwen2.5-coder:7b",
        action = "replace",
      },
      Optimize_Code = {
        prompt = "Optimize this code for better performance:\n\n$sel",
        input_label = "> ",
        model = "qwen2.5-coder:7b",
        action = "replace",
      },
    },
  },
}
