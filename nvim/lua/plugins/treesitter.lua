return {
  "nvim-treesitter/nvim-treesitter",
  branch = "main",
  lazy = false,
  build = ":TSUpdate",
  init = function()
    local parsers = {
      "dart", "rust", "lua", "mermaid",
      "markdown", "markdown_inline",
      "elixir", "eex", "heex",
    }

    local ts = require("nvim-treesitter")

    local ok, config = pcall(require, "nvim-treesitter.config")
    if ok then
      local installed = config.get_installed() or {}

      local to_install = vim.iter(parsers)
          :filter(function(p)
            return not vim.tbl_contains(installed, p)
          end)
          :totable()

      if #to_install > 0 then
        ts.install(to_install)
      end
    end

    vim.api.nvim_create_autocmd("FileType", {
      pattern = {
        "dart", "rust", "lua", "mermaid",
        "markdown", "elixir", "eex", "heex",
      },
      callback = function(args)
        pcall(vim.treesitter.start, args.buf)

        local ok_indent = pcall(function()
          vim.bo[args.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
        end)
      end,
    })
  end,
}
