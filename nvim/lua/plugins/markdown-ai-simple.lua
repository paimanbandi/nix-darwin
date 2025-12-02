return {
  "local/markdown-ai",
  dir = "~/nvim/plugins/markdown-ai", -- Sesuaikan path
  dependencies = {
    "iamcco/markdown-preview.nvim",
  },
  init = function()
    -- Initialize default provider
    vim.g.mermaid_ai_provider = vim.g.mermaid_ai_provider or "opencode"
  end,
  config = function()
    -- Load modules
    local markdown_ai = require("plugins.markdown-ai")
    local providers = require("plugins.markdown-ai-providers")

    -- Setup keymaps
    local keymaps = {
      { "<leader>ma", function() markdown_ai.generate_auto("moderate") end, "Generate Diagram (Auto)" },
      { "<leader>mA", function() markdown_ai.generate_auto("simple") end,   "Generate Simple Diagram" },
      { "<leader>md", function() markdown_ai.generate_manual() end,         "Generate Diagram (Manual)" },
      { "<leader>mG", function() markdown_ai.generate_from_selection() end, "Generate from Selection",         mode = "v" },
      { "<leader>mw", function() markdown_ai.generate_with_provider() end,  "Generate with Provider Selection" },
      { "<leader>mr", function() markdown_ai.regenerate_current() end,      "Regenerate Current" },
      { "<leader>mS", function() markdown_ai.set_provider() end,            "Set Default Provider" },
      { "<leader>mi", function() providers.show_status() end,               "Show Provider Status" },
      { "<leader>mp", function() markdown_ai.preview() end,                 "Preview Diagram" },
    }

    for _, km in ipairs(keymaps) do
      vim.keymap.set(km.mode or "n", km[1], km[2], { desc = km[3] })
    end

    vim.notify("Markdown AI plugin loaded", vim.log.levels.INFO)
  end,
  keys = {
    { "<leader>ma", desc = "Generate Diagram (Auto)" },
    { "<leader>mA", desc = "Generate Simple Diagram" },
    { "<leader>md", desc = "Generate Diagram (Manual)" },
    { "<leader>mG", mode = "v",                               desc = "Generate from Selection" },
    { "<leader>mw", desc = "Generate with Provider Selection" },
    { "<leader>mr", desc = "Regenerate Current" },
    { "<leader>mS", desc = "Set Default Provider" },
    { "<leader>mi", desc = "Show Provider Status" },
    { "<leader>mp", desc = "Preview Diagram" },
  },
}
