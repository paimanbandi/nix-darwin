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
        -- Highlight images
        if entry.name:match("%.(jpg|jpeg|png|gif|webp|bmp|pdf)$") then
          return "DiagnosticWarn"
        end
        -- Highlight D2 files
        if entry.name:match("%.d2$") then
          return "DiagnosticInfo"
        end
        -- Highlight SVG files
        if entry.name:match("%.svg$") then
          return "DiagnosticHint"
        end
      end,
    },
  },
  config = function(_, opts)
    local oil = require("oil")

    -- Binary file extensions
    local binary_exts = {
      "jpg", "jpeg", "png", "gif", "bmp", "svg",
      "webp", "pdf", "mp4", "mp3", "avi", "mkv",
      "zip", "tar", "gz", "rar",
    }

    -- Check if file is binary
    local function is_binary_file(name)
      local ext = name:match("^.+%.(.+)$")
      if not ext then return false end
      ext = ext:lower()
      for _, e in ipairs(binary_exts) do
        if e == ext then return true end
      end
      return false
    end

    -- Check if file is D2
    local function is_d2_file(name)
      return name:match("%.d2$") ~= nil
    end

    -- Open file externally
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

    -- Compile D2 to SVG
    local function compile_d2(d2_path)
      local svg_path = d2_path:gsub("%.d2$", ".svg")

      vim.notify("Compiling D2...", vim.log.levels.INFO)

      vim.fn.jobstart({ "d2", d2_path, svg_path }, {
        on_exit = function(_, code)
          if code == 0 then
            vim.notify("✓ Compiled: " .. vim.fn.fnamemodify(svg_path, ":t"), vim.log.levels.INFO)
          else
            vim.notify("✗ D2 compilation failed", vim.log.levels.ERROR)
          end
        end,
      })

      return svg_path
    end

    -- Preview D2 file (compile then open SVG)
    local function preview_d2(d2_path)
      local svg_path = compile_d2(d2_path)

      -- Wait a bit for compilation, then open
      vim.defer_fn(function()
        if vim.fn.filereadable(svg_path) == 1 then
          open_external(svg_path)
        else
          vim.notify("SVG not found. Compilation may have failed.", vim.log.levels.WARN)
        end
      end, 500)
    end

    -- Watch D2 file (auto-refresh on changes)
    local function watch_d2(d2_path)
      local svg_path = d2_path:gsub("%.d2$", ".svg")

      -- Open terminal in split
      vim.cmd("split")
      vim.cmd("resize 12")
      vim.cmd("terminal d2 --watch " .. vim.fn.shellescape(d2_path) .. " " .. vim.fn.shellescape(svg_path))
      vim.cmd("startinsert")

      -- Return to oil after 1 second
      vim.defer_fn(function()
        vim.cmd("wincmd p")
      end, 1000)

      vim.notify("D2 watch mode started", vim.log.levels.INFO)
    end

    -- Setup oil
    oil.setup(opts)

    -- Main keybindings
    vim.keymap.set("n", "-", "<CMD>Oil<CR>", { desc = "Open parent dir" })
    vim.keymap.set("n", "<leader>.", "<CMD>lua require('oil').toggle_hidden()<CR>", { desc = "Toggle hidden" })

    -- Oil-specific keybindings
    vim.api.nvim_create_autocmd("FileType", {
      pattern = "oil",
      callback = function()
        -- Smart Enter: handles directories, D2 files, binary files, and text files
        vim.keymap.set("n", "<CR>", function()
          local entry = oil.get_cursor_entry()
          if not entry then return end

          if entry.type == "directory" then
            -- Open directory
            oil.select()
          elseif is_d2_file(entry.name) then
            -- Open D2 file in buffer (for editing)
            oil.select()
          elseif is_binary_file(entry.name) then
            -- Open binary files externally
            open_external(oil.get_current_dir() .. entry.name)
          else
            -- Open text files normally
            oil.select()
          end
        end, { buffer = true, desc = "Smart open" })

        -- Preview: different behavior for D2 vs other files
        vim.keymap.set("n", "p", function()
          local entry = oil.get_cursor_entry()
          if not entry then return end

          if is_d2_file(entry.name) then
            -- Compile and preview D2
            preview_d2(oil.get_current_dir() .. entry.name)
          elseif is_binary_file(entry.name) then
            -- Binary files cannot be previewed in buffer
            vim.notify("Use <leader>o to open binary files externally", vim.log.levels.INFO)
          else
            -- Preview text files in oil
            oil.open_preview()
          end
        end, { buffer = true, desc = "Preview (D2/text)" })

        -- Open externally
        vim.keymap.set("n", "<leader>o", function()
          local entry = oil.get_cursor_entry()
          if not entry then return end

          local filepath = oil.get_current_dir() .. entry.name

          if is_d2_file(entry.name) then
            -- For D2: compile first, then open SVG
            preview_d2(filepath)
          else
            -- For other files: just open
            open_external(filepath)
          end
        end, { buffer = true, desc = "Open externally" })

        -- D2 Watch mode (new keybinding)
        vim.keymap.set("n", "<leader>dw", function()
          local entry = oil.get_cursor_entry()
          if not entry then return end

          if is_d2_file(entry.name) then
            watch_d2(oil.get_current_dir() .. entry.name)
          else
            vim.notify("Not a D2 file", vim.log.levels.WARN)
          end
        end, { buffer = true, desc = "D2 watch mode" })

        -- Quick compile D2 without opening
        vim.keymap.set("n", "<leader>dc", function()
          local entry = oil.get_cursor_entry()
          if not entry then return end

          if is_d2_file(entry.name) then
            compile_d2(oil.get_current_dir() .. entry.name)
          else
            vim.notify("Not a D2 file", vim.log.levels.WARN)
          end
        end, { buffer = true, desc = "Compile D2" })

        -- Compile with theme
        vim.keymap.set("n", "<leader>dt", function()
          local entry = oil.get_cursor_entry()
          if not entry then return end

          if is_d2_file(entry.name) then
            local d2_path = oil.get_current_dir() .. entry.name
            local svg_path = d2_path:gsub("%.d2$", ".svg")

            -- Prompt for theme
            vim.ui.select(
              { "0 - Neutral", "1 - Grey", "3 - Cool classics", "4 - Mixed berry", "5 - Grape soda", "6 - Aubergine" },
              { prompt = "Select theme:" },
              function(choice)
                if not choice then return end
                local theme_id = choice:match("^(%d+)")

                vim.notify("Compiling with theme " .. theme_id .. "...", vim.log.levels.INFO)

                vim.fn.jobstart({ "d2", "--theme", theme_id, d2_path, svg_path }, {
                  on_exit = function(_, code)
                    if code == 0 then
                      vim.notify("✓ Compiled with theme " .. theme_id, vim.log.levels.INFO)
                      open_external(svg_path)
                    else
                      vim.notify("✗ Compilation failed", vim.log.levels.ERROR)
                    end
                  end,
                })
              end
            )
          else
            vim.notify("Not a D2 file", vim.log.levels.WARN)
          end
        end, { buffer = true, desc = "D2 compile with theme" })
      end,
    })
  end,
}
