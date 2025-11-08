return {
  "terrastruct/d2-vim",
  ft = { "d2" },
  config = function()
    -- Helper function to get paths
    local function get_d2_paths()
      local input = vim.fn.expand("%:p")
      local output = input:gsub("%.d2$", ".svg")
      return input, output
    end

    -- D2 Render (compile)
    vim.api.nvim_create_user_command("D2Render", function()
      local input, output = get_d2_paths()

      vim.notify("Compiling D2...", vim.log.levels.INFO)

      vim.fn.jobstart({ "d2", input, output }, {
        on_exit = function(_, code)
          if code == 0 then
            vim.notify("✓ Rendered: " .. vim.fn.fnamemodify(output, ":t"), vim.log.levels.INFO)
          else
            vim.notify("✗ D2 compilation failed", vim.log.levels.ERROR)
          end
        end,
      })
    end, {})

    -- D2 Preview (compile + open)
    vim.api.nvim_create_user_command("D2Preview", function()
      local input, output = get_d2_paths()

      vim.notify("Compiling D2...", vim.log.levels.INFO)

      vim.fn.jobstart({ "d2", input, output }, {
        on_exit = function(_, code)
          if code == 0 then
            vim.notify("✓ Compiled", vim.log.levels.INFO)

            -- Open with default app
            local open_cmd
            if vim.fn.has("mac") == 1 then
              open_cmd = "open"
            elseif vim.fn.has("unix") == 1 then
              open_cmd = "xdg-open"
            elseif vim.fn.has("win32") == 1 then
              open_cmd = "start"
            end

            if open_cmd then
              vim.fn.jobstart({ open_cmd, output }, { detach = true })
            end
          else
            vim.notify("✗ Compilation failed", vim.log.levels.ERROR)
          end
        end,
      })
    end, {})

    -- D2 Watch (auto-refresh)
    vim.api.nvim_create_user_command("D2Watch", function()
      local input, output = get_d2_paths()

      vim.cmd("split")
      vim.cmd("resize 12")
      vim.cmd("terminal d2 --watch " .. vim.fn.shellescape(input) .. " " .. vim.fn.shellescape(output))
      vim.cmd("startinsert")

      vim.defer_fn(function()
        vim.cmd("wincmd p")
      end, 1000)

      vim.notify("D2 watch mode started", vim.log.levels.INFO)
    end, {})

    -- D2 Theme (compile with theme)
    vim.api.nvim_create_user_command("D2Theme", function(opts)
      local input, output = get_d2_paths()
      local theme = opts.args

      vim.notify("Compiling with theme " .. theme .. "...", vim.log.levels.INFO)

      vim.fn.jobstart({ "d2", "--theme", theme, input, output }, {
        on_exit = function(_, code)
          if code == 0 then
            vim.notify("✓ Theme " .. theme .. " applied", vim.log.levels.INFO)

            -- Auto-open after compile
            local open_cmd
            if vim.fn.has("mac") == 1 then
              open_cmd = "open"
            elseif vim.fn.has("unix") == 1 then
              open_cmd = "xdg-open"
            elseif vim.fn.has("win32") == 1 then
              open_cmd = "start"
            end

            if open_cmd then
              vim.fn.jobstart({ open_cmd, output }, { detach = true })
            end
          else
            vim.notify("✗ Compilation failed", vim.log.levels.ERROR)
          end
        end,
      })
    end, {
      nargs = 1,
      complete = function()
        return { "0", "1", "3", "4", "5", "6", "7", "8" }
      end,
    })

    -- D2 Layout (compile with layout engine)
    vim.api.nvim_create_user_command("D2Layout", function(opts)
      local input, output = get_d2_paths()
      local layout = opts.args

      vim.notify("Compiling with " .. layout .. " layout...", vim.log.levels.INFO)

      vim.fn.jobstart({ "d2", "--layout", layout, input, output }, {
        on_exit = function(_, code)
          if code == 0 then
            vim.notify("✓ Layout " .. layout .. " applied", vim.log.levels.INFO)

            -- Auto-open
            local open_cmd
            if vim.fn.has("mac") == 1 then
              open_cmd = "open"
            elseif vim.fn.has("unix") == 1 then
              open_cmd = "xdg-open"
            elseif vim.fn.has("win32") == 1 then
              open_cmd = "start"
            end

            if open_cmd then
              vim.fn.jobstart({ open_cmd, output }, { detach = true })
            end
          else
            vim.notify("✗ Compilation failed", vim.log.levels.ERROR)
          end
        end,
      })
    end, {
      nargs = 1,
      complete = function()
        return { "dagre", "elk", "tala" }
      end,
    })

    -- Auto-compile on save
    vim.api.nvim_create_autocmd("BufWritePost", {
      pattern = "*.d2",
      callback = function()
        vim.cmd("D2Render")
      end,
    })

    -- D2 file-specific keybindings
    vim.api.nvim_create_autocmd("FileType", {
      pattern = "d2",
      callback = function()
        local opts = { buffer = true, silent = true }

        vim.keymap.set("n", "<leader>dp", ":D2Preview<CR>",
          vim.tbl_extend("force", opts, { desc = "D2: Preview" }))

        vim.keymap.set("n", "<leader>dw", ":D2Watch<CR>",
          vim.tbl_extend("force", opts, { desc = "D2: Watch" }))

        vim.keymap.set("n", "<leader>dc", ":D2Render<CR>",
          vim.tbl_extend("force", opts, { desc = "D2: Compile" }))

        -- Quick theme shortcuts
        for _, theme in ipairs({ "0", "1", "3", "4", "5", "6", "7", "8" }) do
          vim.keymap.set("n", "<leader>d" .. theme, ":D2Theme " .. theme .. "<CR>",
            vim.tbl_extend("force", opts, { desc = "D2: Theme " .. theme }))
        end

        -- Layout shortcuts
        vim.keymap.set("n", "<leader>dld", ":D2Layout dagre<CR>",
          vim.tbl_extend("force", opts, { desc = "D2: Layout Dagre" }))
        vim.keymap.set("n", "<leader>dle", ":D2Layout elk<CR>",
          vim.tbl_extend("force", opts, { desc = "D2: Layout ELK" }))
        vim.keymap.set("n", "<leader>dlt", ":D2Layout tala<CR>",
          vim.tbl_extend("force", opts, { desc = "D2: Layout TALA" }))
      end,
    })

    -- Diagnostic hover on cursor hold
    vim.api.nvim_create_autocmd("CursorHold", {
      pattern = "*.d2",
      callback = function()
        vim.diagnostic.open_float(nil, {
          focusable = false,
          close_events = { "BufLeave", "CursorMoved", "InsertEnter", "FocusLost" },
          border = "rounded",
          source = "always",
          prefix = " ",
        })
      end,
    })
  end,
}
