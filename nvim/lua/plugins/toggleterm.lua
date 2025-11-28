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

    -- Keymaps untuk navigasi keyboard di terminal
    function _G.set_terminal_keymaps()
      local opts = { buffer = 0 }

      -- ESC untuk keluar insert mode
      vim.keymap.set("t", "<Esc>", [[<C-\><C-n>]], opts)

      -- Ctrl+a = jump ke awal baris
      vim.keymap.set("t", "<C-a>", [[<C-\><C-n>I]], opts)

      -- Ctrl+e = jump ke akhir baris
      vim.keymap.set("t", "<C-e>", [[<C-\><C-n>A]], opts)

      -- Alt+b = mundur satu kata
      vim.keymap.set("t", "<M-b>", [[<C-\><C-n>bi]], opts)

      -- Alt+f = maju satu kata
      vim.keymap.set("t", "<M-f>", [[<C-\><C-n>ea]], opts)

      -- FIXED: Mouse left click tetap insert mode
      vim.keymap.set("n", "<LeftMouse>", function()
        local mouse = vim.fn.getmousepos()
        vim.api.nvim_win_set_cursor(0, { mouse.line, mouse.column - 1 })
        vim.cmd("startinsert")
      end, opts)

      -- Mouse release juga ke insert mode
      vim.keymap.set("n", "<LeftRelease>", function()
        local mouse = vim.fn.getmousepos()
        vim.api.nvim_win_set_cursor(0, { mouse.line, mouse.column - 1 })
        vim.cmd("startinsert")
      end, opts)

      -- Navigasi antar window
      vim.keymap.set("t", "<C-h>", [[<C-\><C-n><C-W>h]], opts)
      vim.keymap.set("t", "<C-j>", [[<C-\><C-n><C-W>j]], opts)
      vim.keymap.set("t", "<C-k>", [[<C-\><C-n><C-W>k]], opts)
      vim.keymap.set("t", "<C-l>", [[<C-\><C-n><C-W>l]], opts)
    end

    -- Auto apply keymaps untuk semua terminal toggleterm
    vim.cmd("autocmd! TermOpen term://*toggleterm#* lua set_terminal_keymaps()")

    -- Pastikan tetap insert mode saat masuk buffer terminal
    vim.api.nvim_create_autocmd("BufEnter", {
      pattern = "term://*toggleterm#*",
      callback = function()
        vim.cmd("startinsert")
      end,
    })
  end,
}
