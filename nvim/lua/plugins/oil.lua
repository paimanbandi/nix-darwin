return {
  "stevearc/oil.nvim",
  opts = {
    default_file_explorer = true,
    skip_confirm_for_simple_edits = true,
    view_options = {
      show_hidden = false,
      is_hidden_file = function(name, _)
        return vim.startswith(name, ".")
      end,
      is_always_hidden = function(_, _)
        return false
      end,
      highlight_filename = function(entry, _, _, _)
        if entry.name:match("%.(jpg|jpeg|png|gif|webp|bmp|pdf)$") then
          return "DiagnosticWarn"
        end
      end,
    },
  },
  config = function(_, opts)
    local oil = require("oil")

    local binary_exts = {
      "jpg", "jpeg", "png", "gif", "bmp", "svg",
      "webp", "pdf", "mp4", "mp3", "avi", "mkv",
      "zip", "tar", "gz", "rar",
    }

    local function is_binary_file(name)
      local ext = name:match("^.+%.(.+)$")
      if not ext then return false end
      ext = ext:lower()
      for _, e in ipairs(binary_exts) do
        if e == ext then return true end
      end
      return false
    end

    local function open_external(filepath)
      local cmd
      if vim.fn.has("mac") == 1 then
        cmd = { "open", filepath }
      elseif vim.fn.has("unix") == 1 then
        cmd = { "xdg-open", filepath }
      elseif vim.fn.has("win32") == 1 then
        cmd = { "start", filepath }
      else
        vim.notify("OS not supported for external open", vim.log.levels.ERROR)
        return
      end
      vim.fn.jobstart(cmd, { detach = true })
    end

    oil.setup(opts)

    vim.keymap.set("n", "-", "<CMD>Oil<CR>", { desc = "Open parent dir" })
    vim.keymap.set("n", "<leader>.", "<CMD>lua require('oil').toggle_hidden()<CR>", { desc = "Toggle hidden" })

    vim.api.nvim_create_autocmd("FileType", {
      pattern = "oil",
      callback = function()
        vim.keymap.set("n", "<CR>", function()
          local entry = oil.get_cursor_entry()
          if not entry then return end

          if entry.type == "directory" then
            oil.select()
          elseif is_binary_file(entry.name) then
            open_external(oil.get_current_dir() .. entry.name)
          else
            oil.select()
          end
        end, { buffer = true, desc = "Smart open" })

        vim.keymap.set("n", "p", function()
          local entry = oil.get_cursor_entry()
          if entry and not is_binary_file(entry.name) then
            oil.open_preview()
          else
            print("Cannot preview binary file - use <leader>o to open externally")
          end
        end, { buffer = true, desc = "Preview text files" })

        vim.keymap.set("n", "<leader>o", function()
          local entry = oil.get_cursor_entry()
          if entry then
            open_external(oil.get_current_dir() .. entry.name)
          end
        end, { buffer = true, desc = "Open externally" })
      end,
    })
  end,
}
