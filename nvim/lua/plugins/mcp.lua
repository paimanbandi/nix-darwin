return {
  {
    "ravitemer/mcphub.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    cmd = "MCPHub",
    config = function()
      require("mcphub").setup({
        cmd = "npx",
        cmdArgs = { "-y", "mcp-hub@latest" },
      })
    end,
  },
}
