return {
  {
    "olimorris/codecompanion.nvim",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-treesitter/nvim-treesitter",
      "ravitemer/mcphub.nvim",
    },
    config = function()
      require("codecompanion").setup({
        -- WAJIB: pilih adapter LLM-mu (anthropic/openai/ollama/copilot).
        -- Kamu punya `ollama` di packages, jadi contoh paling mudah:
        strategies = {
          chat = { adapter = "ollama" },
          inline = { adapter = "ollama" },
        },
        -- Jembatan ke mcphub → tools Figma muncul di chat:
        extensions = {
          mcphub = {
            callback = "mcphub.extensions.codecompanion",
            opts = {
              make_tools = true,
              show_server_tools_in_chat = true,
              make_vars = true,
              make_slash_commands = true,
              show_result_in_chat = true,
            },
          },
        },
      })
    end,
  },
}
