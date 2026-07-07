-- ~/.config/nvim/lua/plugins/mcp.lua
-- MCP client untuk Neovim. Di Nix, JANGAN pakai `npm install -g` (prefix global
-- read-only → EROFS). Pakai bundled binary: mcp-hub di-install LOKAL di folder
-- plugin (writable), butuh `node`/`npm` yang sudah ada dari home.packages (nodejs).
return {
  {
    "ravitemer/mcphub.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    -- tanpa build; mcp-hub dijalankan on-demand via npx
    config = function()
      require("mcphub").setup({
        cmd = "npx",
        cmdArgs = { "-y", "mcp-hub@latest" },
      })
    end,
  }
}
