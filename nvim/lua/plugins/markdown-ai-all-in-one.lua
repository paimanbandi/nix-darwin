-- Ini adalah plugin spec untuk lazy.nvim
return {
  "markdown-ai-all-in-one",
  lazy = false,
  dependencies = {
    "iamcco/markdown-preview.nvim",
  },
  init = function()
    -- Initialize default provider
    vim.g.mermaid_ai_provider = vim.g.mermaid_ai_provider or "opencode"
  end,
  config = function()
    -- Load semua modules dari direktori yang sama
    local function load_module(name)
      local ok, mod = pcall(require, "plugins.markdown-ai-" .. name)
      if not ok then
        vim.notify("Failed to load module: " .. name, vim.log.levels.ERROR)
        return nil
      end
      return mod
    end

    local prompts = load_module("prompts")
    local detector = load_module("detector")
    local providers = load_module("providers")
    local main = load_module("main") -- atau "index" jika nama filenya berbeda

    if not (prompts and detector and providers and main) then
      vim.notify("Failed to load markdown-ai modules", vim.log.levels.ERROR)
      return
    end

    -- Setup keymaps
    local keymaps = {
      { "<leader>ma", function() main.generate_auto("moderate") end, "Generate Diagram (Auto)" },
      { "<leader>mA", function() main.generate_auto("simple") end,   "Generate Simple Diagram" },
      { "<leader>md", function() main.generate_manual() end,         "Generate Diagram (Manual)" },
      { "<leader>mG", function() main.generate_from_selection() end, "Generate from Selection",         mode = "v" },
      { "<leader>mw", function() main.generate_with_provider() end,  "Generate with Provider Selection" },
      { "<leader>mr", function() main.regenerate_current() end,      "Regenerate Current" },
      { "<leader>mS", function() main.set_provider() end,            "Set Default Provider" },
      { "<leader>mi", function() providers.show_status() end,        "Show Provider Status" },
      { "<leader>mp", function() main.preview() end,                 "Preview Diagram" },
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
