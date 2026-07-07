-- ~/.config/nvim/lua/plugins/mcp.lua
-- MCP client untuk Neovim. Di Nix, JANGAN pakai `npm install -g` (prefix global
-- read-only → EROFS). Pakai bundled binary: mcp-hub di-install LOKAL di folder
-- plugin (writable), butuh `node`/`npm` yang sudah ada dari home.packages (nodejs).
return {
  {
    "ravitemer/mcphub.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    build = "bundled_build.lua", -- BUKAN "npm install -g mcp-hub@latest"
    cmd = "MCPHub",
    config = function()
      require("mcphub").setup({
        use_bundled_binary = true,

        -- Jembatan ke plugin chat-mu. Aktifkan yang kamu pakai saja
        -- (Resources → #variables, Prompts → /slash_commands di chat).
        extensions = {
          -- codecompanion = {
          --   show_result_in_chat = true,
          --   make_vars = true,
          --   make_slash_commands = true,
          -- },
          -- avante = {
          --   make_slash_commands = true,
          -- },
        },
      })
    end,
  },
}
