return {
  "stevearc/conform.nvim",
  event = { "BufWritePre" },
  config = function()
    require("conform").setup({
      formatters = {
        prettier = {
          command = "/run/current-system/sw/bin/prettier",
        },
        markdownlint = {
          command = "/run/current-system/sw/bin/markdownlint",
          args = { "--fix", "$FILENAME" },
          stdin = false,
        },
        yamllint = {
          command = "/run/current-system/sw/bin/yamllint",
          args = { "-f", "parsable", "$FILENAME" },
          stdin = false,
        }
      },
      formatters_by_ft = {
        lua = { "stylua" },
        javascript = { "prettier" },
        typescript = { "prettier" },
        javascriptreact = { "prettier" },
        typescriptreact = { "prettier" },
        json = { "prettier" },
        yaml = { "yamllint" },
        markdown = { "markdownlint" },
        html = { "prettier" },
        css = { "prettier" },
        rust = { "rustfmt" },
        python = { "black" },
        go = { "gofmt" },
        dockerfile = { "lsp" },
      },
      format_on_save = function(bufnr)
        local ignore_filetypes = { "sql" }
        if vim.tbl_contains(ignore_filetypes, vim.bo[bufnr].filetype) then
          return
        end
        return { timeout_ms = 500, lsp_fallback = true }
      end,
    })
  end,
}
