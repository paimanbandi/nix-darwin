return {
  "nvim-treesitter/nvim-treesitter",
  branch = "main",
  lazy = false,
  build = ":TSUpdate",
  init = function()
    local parsers = {
      "dart",
      "rust",
      "lua",
      "mermaid",
      "markdown",
      "markdown_inline",
      "elixir",
      "eex",
      "heex",
    }

    local ts_ok, ts = pcall(require, "nvim-treesitter")
    if not ts_ok then
      vim.notify("nvim-treesitter not loaded", vim.log.levels.WARN)
      return
    end

    local config_ok, config = pcall(require, "nvim-treesitter.config")
    if config_ok then
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
        "dart",
        "rust",
        "lua",
        "mermaid",
        "markdown",
        "elixir",
        "eex",
        "heex",
      },
      callback = function(args)
        pcall(vim.treesitter.start, args.buf)

        pcall(function()
          vim.bo[args.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
        end)
      end,
    })

    -- ============================================================
    -- Workaround for nvim 0.12.x bug:
    --   "attempt to call method 'range' (a nil value)"
    --   https://github.com/neovim/neovim/issues/39032
    --   https://github.com/nvim-treesitter/nvim-treesitter/issues/8618
    --
    -- The legacy nvim-treesitter markdown highlights.scm uses
    -- `(#set! conceal_lines "")` predicates that call an obsolete
    -- treesitter API. We override the query with an identical one
    -- minus those two problematic directives.
    --
    -- When upstream fixes the bug, delete this entire block.
    -- ============================================================
    pcall(vim.treesitter.query.set, "markdown", "highlights", [[
; From MDeiml/tree-sitter-markdown & Helix

(setext_heading
  (paragraph) @markup.heading.1
  (setext_h1_underline) @markup.heading.1)

(setext_heading
  (paragraph) @markup.heading.2
  (setext_h2_underline) @markup.heading.2)

(atx_heading (atx_h1_marker)) @markup.heading.1
(atx_heading (atx_h2_marker)) @markup.heading.2
(atx_heading (atx_h3_marker)) @markup.heading.3
(atx_heading (atx_h4_marker)) @markup.heading.4
(atx_heading (atx_h5_marker)) @markup.heading.5
(atx_heading (atx_h6_marker)) @markup.heading.6

(info_string) @label

(pipe_table_header (pipe_table_cell) @markup.heading)
(pipe_table_header "|" @punctuation.special)
(pipe_table_row "|" @punctuation.special)
(pipe_table_delimiter_row "|" @punctuation.special)
(pipe_table_delimiter_cell) @punctuation.special

(indented_code_block) @markup.raw.block

((fenced_code_block) @markup.raw.block
  (#set! priority 90))

(fenced_code_block
  (fenced_code_block_delimiter) @markup.raw.block
  (#set! conceal ""))

(fenced_code_block
  (info_string
    (language) @label
    (#set! conceal "")))

(link_destination) @markup.link.url

[
  (link_title)
  (link_label)
] @markup.link.label

((link_label) . ":" @punctuation.delimiter)

[
  (list_marker_plus)
  (list_marker_minus)
  (list_marker_star)
  (list_marker_dot)
  (list_marker_parenthesis)
] @markup.list

(thematic_break) @punctuation.special

(task_list_marker_unchecked) @markup.list.unchecked
(task_list_marker_checked) @markup.list.checked

((block_quote) @markup.quote
  (#set! priority 90))

([
  (plus_metadata)
  (minus_metadata)
] @keyword.directive
  (#set! priority 90))

[
  (block_continuation)
  (block_quote_marker)
] @punctuation.special

(backslash_escape) @string.escape
(inline) @spell
]])
  end,
}
