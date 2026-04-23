return {
  "nvim-treesitter/nvim-treesitter",
  branch = "main",
  lazy = false,
  build = function()
    require("nvim-treesitter").update()
  end,
  init = function()
    local parsers = {
      "dart", "rust", "lua", "mermaid",
      "markdown", "markdown_inline",
      "elixir", "eex", "heex",
    }

    local ts = require("nvim-treesitter")
    local installed = require("nvim-treesitter.config").get_installed()

    local to_install = vim.iter(parsers)
        :filter(function(p) return not vim.tbl_contains(installed, p) end)
        :totable()

    if #to_install > 0 then
      ts.install(to_install)
    end

    vim.api.nvim_create_autocmd("FileType", {
      pattern = {
        "dart", "rust", "lua", "mermaid",
        "markdown", "elixir", "eex", "heex",
      },
      callback = function()
        pcall(vim.treesitter.start)
        vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
      end,
    })
  end,
}
