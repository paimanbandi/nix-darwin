return {
  'nvim-telescope/telescope.nvim',
  tag = '0.1.8',
  lazy = false,
  dependencies = { 'nvim-lua/plenary.nvim' },
  config = function()
    require('telescope').setup({
      defaults = {
        -- Disable semua fancy layout
        sorting_strategy = "ascending",
        layout_strategy = "center",
        layout_config = {
          anchor = "N",
          height = 0.5,
          width = 0.7,
        },
        borderchars = {
          prompt = { "─", " ", " ", " ", "─", "─", " ", " " },
          results = { " " },
          preview = { " " },
        },
      },
    })
  end,
  keys = {
    {
      '<leader>ff',
      function() require('telescope.builtin').find_files() end,
      desc = 'Telescope: Find files',
      mode = 'n',
    },
    {
      '<leader>lg',
      function() require('telescope.builtin').live_grep() end,
      desc = 'Telescope: Live grep',
      mode = 'n',
    },
  },
}
