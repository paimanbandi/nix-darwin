return {
  "akinsho/flutter-tools.nvim",
  dependencies = "nvim-lua/plenary.nvim",
  config = function()
    require("flutter-tools").setup({
      lsp = {
        on_attach = function(_, bufnr)
          local opts = { buffer = bufnr }
          vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
          vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
        end,
      },
    })
  end,
}
