return {
  "akinsho/flutter-tools.nvim",
  dependencies = "nvim-lua/plenary.nvim",
  config = function()
    require("flutter-tools").setup({
      lsp = {
        on_attach = function(_, bufnr)
        end,
      },
    })
  end,
}
