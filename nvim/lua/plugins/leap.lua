return {
  "ggandor/leap.nvim",
  lazy = false,
  config = function()
    local leap = require('leap')
    vim.keymap.set({ 'n', 'x', 'o' }, '<leader>s', '<Plug>(leap-forward)')
    vim.keymap.set({ 'n', 'x', 'o' }, '<leader>S', '<Plug>(leap-backward)')

    leap.setup({
      case_sensitive = true,
    })
  end,
}
