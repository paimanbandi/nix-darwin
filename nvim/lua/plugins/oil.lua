return {
  "stevearc/oil.nvim",
  dependencies = {
    "folke/snacks.nvim", -- Pastikan snacks terinstall
  },
  config = function()
    require("oil").setup({
      -- Optional: Enable preview
      preview = {
        max_width = 0.8,
        border = "rounded",
      },
    })

    -- Mapping existing - JANGAN DIHAPUS
    vim.keymap.set("n", "-", "<CMD>Oil<CR>", { desc = "Open parent dir" })
    vim.keymap.set("n", "<leader>.", "<CMD>lua require('oil').toggle_hidden()<CR>", { desc = "Toggle hidden" })

    vim.api.nvim_create_autocmd("FileType", {
      pattern = "oil",
      callback = function()
        -- Smart Enter behavior dengan snacks
        vim.keymap.set("n", "<CR>", function()
          local entry = require("oil").get_cursor_entry()
          if not entry then return end

          if entry.type == "directory" then
            require("oil").select() -- Buka directory
          elseif entry.name:match("%.(jpg|png|gif|webp|bmp|pdf)$") then
            -- Gunakan snacks untuk preview image/binary
            require("snacks").open(entry.name)
          else
            require("oil").select() -- Buka file text di Neovim
          end
        end, { buffer = true, desc = "Smart open" })

        -- Quick snacks preview dengan leader p
        vim.keymap.set("n", "<leader>p", function()
          local entry = require("oil").get_cursor_entry()
          if entry then
            require("snacks").open(entry.name)
          end
        end, { buffer = true, desc = "Snacks Preview" })
      end,
    })
  end,
}
