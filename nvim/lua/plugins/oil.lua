return {
  "stevearc/oil.nvim",
  dependencies = {
    "3rd/image.nvim", -- Untuk image preview
  },
  config = function()
    -- Setup image.nvim dengan chafa backend (compatible dengan Ghostty)
    require("image").setup({
      backend = "chafa",                -- ASCII art representation
      integrations = {
        markdown = { enabled = false }, -- Disable untuk oil
      },
      processor = "magick_rock",
      tmux_show_only_in_active_window = true,
    })

    require("oil").setup({
      preview = {
        max_width = 0.8,
        min_width = { 40, 0.4 },
        width = nil,
        max_height = 0.9,
        min_height = { 5, 0.1 },
        height = nil,
        border = "rounded",
        win_options = {
          winblend = 0,
        },
        update_on_cursor_moved = true,
      },
      keymaps = {
        ["<C-p>"] = "actions.preview", -- Built-in preview toggle
        ["<C-c>"] = "actions.close",
        ["<C-r>"] = "actions.refresh",
      },
    })

    -- Mapping existing - JANGAN DIHAPUS
    vim.keymap.set("n", "-", "<CMD>Oil<CR>", { desc = "Open parent dir" })
    vim.keymap.set("n", "<leader>.", "<CMD>lua require('oil').toggle_hidden()<CR>", { desc = "Toggle hidden" })

    vim.api.nvim_create_autocmd("FileType", {
      pattern = "oil",
      callback = function()
        -- Helper function untuk buka file eksternal
        local function open_external(filepath)
          local oil_dir = require("oil").get_current_dir()
          local full_path = oil_dir .. filepath

          -- Deteksi OS dan buka dengan command yang tepat
          if vim.fn.has("mac") == 1 then
            vim.fn.system("open " .. vim.fn.shellescape(full_path))
          elseif vim.fn.has("unix") == 1 then
            vim.fn.system("xdg-open " .. vim.fn.shellescape(full_path))
          elseif vim.fn.has("win32") == 1 then
            vim.fn.system("start " .. vim.fn.shellescape(full_path))
          end
        end

        -- Smart Enter behavior
        vim.keymap.set("n", "<CR>", function()
          local entry = require("oil").get_cursor_entry()
          if not entry then return end

          if entry.type == "directory" then
            require("oil").select() -- Buka directory
          elseif entry.name:match("%.(jpg|jpeg|png|gif|webp|bmp)$") then
            -- Preview image dengan oil built-in preview
            require("oil").open_preview()
          elseif entry.name:match("%.(pdf|docx|xlsx|pptx)$") then
            -- File binary buka eksternal
            open_external(entry.name)
          else
            require("oil").select() -- Buka file text di Neovim
          end
        end, { buffer = true, desc = "Smart open" })

        -- Preview toggle
        vim.keymap.set("n", "p", function()
          require("oil").open_preview()
        end, { buffer = true, desc = "Toggle preview" })

        -- External open
        vim.keymap.set("n", "<leader>o", function()
          local entry = require("oil").get_cursor_entry()
          if entry then
            open_external(entry.name)
          end
        end, { buffer = true, desc = "Open externally" })
      end,
    })
  end,
}
