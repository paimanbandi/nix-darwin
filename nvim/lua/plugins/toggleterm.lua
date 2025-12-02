return {
  "akinsho/toggleterm.nvim",
  config = function()
    require("toggleterm").setup({
      size = function(term)
        if term.direction == "horizontal" then
          return 20
        elseif term.direction == "vertical" then
          return vim.o.columns * 0.4
        end
      end,
      open_mapping = [[\\]],
      insert_mappings = true,
      terminal_mappings = true,
      hide_numbers = true,
      shade_filetypes = {},
      shade_terminals = true,
      shading_factor = "1",
      start_in_insert = true,
      persist_size = true,
      direction = "horizontal",
      close_on_exit = true,
      shell = vim.o.shell,
    })

    function _G.set_terminal_keymaps()
      local opts = { buffer = 0, silent = true }

      vim.keymap.set("t", "<Esc>", [[<C-\><C-n>]], opts)
      vim.keymap.set("t", "<C-a>", [[<C-\><C-n>I]], opts)
      vim.keymap.set("t", "<C-e>", [[<C-\><C-n>A]], opts)

      vim.keymap.set("t", "<C-h>", [[<C-\><C-n><C-W>h]], opts)
      vim.keymap.set("t", "<C-j>", [[<C-\><C-n><C-W>j]], opts)
      vim.keymap.set("t", "<C-k>", [[<C-\><C-n><C-W>k]], opts)
      vim.keymap.set("t", "<C-l>", [[<C-\><C-n><C-W>l]], opts)
    end

    vim.cmd("autocmd! TermOpen term://*toggleterm#* lua set_terminal_keymaps()")
  end,
}
