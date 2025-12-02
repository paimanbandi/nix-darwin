local M = {}

M.setup = function()
  -- Load modules
  local markdown_ai = require("plugins.markdown-ai")
  local providers = require("plugins.markdown-ai-providers")

  -- Setup keymaps
  local keys = {
    {
      "<leader>ma",
      function()
        markdown_ai.generate_auto("moderate")
      end,
      desc = "Generate Diagram (Auto-detect type)"
    },
    {
      "<leader>mA",
      function()
        markdown_ai.generate_auto("simple")
      end,
      desc = "Generate Simple Diagram (Auto)"
    },
    {
      "<leader>md",
      function()
        markdown_ai.generate_manual()
      end,
      desc = "Generate Diagram (Manual type selection)"
    },
    {
      "<leader>mG",
      function()
        markdown_ai.generate_from_selection()
      end,
      desc = "Generate from Visual Selection",
      mode = "v"
    },
    {
      "<leader>mw",
      function()
        markdown_ai.generate_with_provider()
      end,
      desc = "Generate with Provider Selection"
    },
    {
      "<leader>mr",
      function()
        markdown_ai.regenerate_current()
      end,
      desc = "Regenerate Current Diagram"
    },
    {
      "<leader>mS",
      function()
        markdown_ai.set_provider()
      end,
      desc = "Set Default AI Provider"
    },
    {
      "<leader>mi",
      function()
        providers.show_status()
      end,
      desc = "Show AI Provider Status"
    },
    {
      "<leader>mp",
      function()
        markdown_ai.preview()
      end,
      desc = "Preview Diagram"
    },
  }

  -- Apply keymaps
  for _, keymap in ipairs(keys) do
    vim.keymap.set(keymap.mode or "n", keymap[1], keymap[2], { desc = keymap.desc })
  end

  -- Initialize default provider
  vim.g.mermaid_ai_provider = vim.g.mermaid_ai_provider or "opencode"

  vim.notify("Markdown AI plugin loaded", vim.log.levels.INFO)
end

return M
