-- markdown-ai-wrapper.lua
-- Clean wrapper untuk lazy.nvim

return {
  dir = vim.fn.stdpath("config") .. "/lua/plugins/markdown-ai",
  name = "markdown-ai",
  event = { "BufRead", "BufNewFile" },
  dependencies = {
    "iamcco/markdown-preview.nvim",
  },
  keys = {
    { "<leader>ma", function() require("plugins.markdown-ai").generate_auto() end, desc = "📊 Generate Diagram (Auto)" },
    { "<leader>mA", function() require("plugins.markdown-ai").generate_auto("simple") end, desc = "📊 Generate Simple Diagram" },
    { "<leader>md", function() require("plugins.markdown-ai").generate_manual() end, desc = "📝 Generate Diagram (Choose)" },
    { "<leader>mp", function() require("plugins.markdown-ai").generate_with_provider_choice() end, desc = "🤖 Generate with Provider" },
    { "<leader>mv", function() require("plugins.markdown-ai").preview_diagram() end, desc = "👁️ Preview Diagram" },
    { "<leader>ms", function() require("plugins.markdown-ai-config").show_provider_status() end, desc = "🔧 Show Provider Status" },
    { "<leader>mh", function() require("plugins.markdown-ai").show_help() end, desc = "❓ Show Help" },
    { "<leader>mc", function() require("plugins.markdown-ai").configure_provider() end, desc = "⚙️ Configure Provider" },
  },
  opts = {
    provider = "claude",
    save_path = "./diagrams",
    auto_detect = true,
    providers = {
      deepseek = {
        enabled = true,
        api_key_env = "DEEPSEEK_API_KEY",
      },
      claude = {
        enabled = true,
      }
    }
  },
  config = function(_, opts)
    require("plugins.markdown-ai").setup(opts)
  end,
}
