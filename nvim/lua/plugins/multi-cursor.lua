return {
  "mg979/vim-visual-multi",
  branch = "master",
  event = "VeryLazy",
  init = function()
    -- Set default mappings
    vim.g.VM_default_mappings = 1

    -- Custom mappings (optional)
    vim.g.VM_maps = {
      ["Find Under"] = '<C-d>',         -- Ctrl+d untuk select word under cursor (seperti VSCode)
      ["Find Subword Under"] = '<C-d>',
      ["Select All"] = '<C-S-l>',       -- Select all occurrences
      ["Skip Region"] = '<C-x>',        -- Skip current match
      ["Remove Region"] = '<C-p>',      -- Remove current cursor
      ["Add Cursor Down"] = '<C-Down>', -- Add cursor ke bawah
      ["Add Cursor Up"] = '<C-Up>',     -- Add cursor ke atas
    }

    -- Theme
    vim.g.VM_theme = 'codedark'

    -- Highlight settings
    vim.g.VM_highlight_matches = 'underline'
  end,
}
