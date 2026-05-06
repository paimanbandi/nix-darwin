return {
  "elixir-tools/elixir-tools.nvim",
  version = "*",
  event = { "BufReadPre", "BufNewFile" },
  ft = { "elixir", "eelixir", "heex", "surface" },
  config = function()
    local elixir = require("elixir")
    local elixirls = require("elixir.elixirls")

    elixir.setup({
      nextls = { enable = false }, -- pake elixirls aja, jangan dobel
      credo = { enable = true },   -- linter Credo
      elixirls = {
        enable = true,
        settings = elixirls.settings({
          dialyzerEnabled = true,
          enableTestLenses = false,
        }),
        on_attach = function(client, bufnr)
          vim.keymap.set("n", "<leader>fp", ":ElixirFromPipe<cr>", { buffer = true, noremap = true })
          vim.keymap.set("n", "<leader>tp", ":ElixirToPipe<cr>", { buffer = true, noremap = true })
          vim.keymap.set("v", "<leader>em", ":ElixirExpandMacro<cr>", { buffer = true, noremap = true })
        end,
      },
    })
  end,
  dependencies = {
    "nvim-lua/plenary.nvim",
  },
}
