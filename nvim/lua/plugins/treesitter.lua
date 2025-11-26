return {
  "nvim-treesitter/nvim-treesitter",
  build = ":TSUpdate",
  config = function()
    require("nvim-treesitter.configs").setup({
      ensure_installed = { "dart", "rust", "lua", "mermaid", "markdown", "markdown_inline" },
      highlight = { enable = true },
    })
  end,
}
