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
    vim.api.nvim_create_user_command("D2Watch", function(opts)
      local input, output = get_d2_paths()
      local is_sketch = opts.args == "sketch"
      local final_output = output
      local cmd = "d2 --watch"
      if is_sketch then
        final_output = output:gsub("%.svg$", "-sketch.svg")
        cmd = "d2 --sketch --watch"
      end
      vim.cmd("split")
      vim.cmd("resize 12")
      vim.cmd("terminal " .. cmd .. " " .. vim.fn.shellescape(input) .. " " .. vim.fn.shellescape(final_output))
      vim.cmd("startinsert")
      vim.defer_fn(function()
        vim.cmd("wincmd p")
      end, 1000)
      local mode_text = is_sketch and "sketch watch" or "watch"
      vim.notify("D2 " .. mode_text .. " mode started", vim.log.levels.INFO)
    end, {
      nargs = "?",
      complete = function()
        return { "sketch" }
      end,
    })

    -- D2 Theme
    vim.api.nvim_create_user_command("D2Theme", function(opts)
      local input, output = get_d2_paths()
      local theme = opts.args
      vim.notify("Compiling with theme " .. theme .. "...", vim.log.levels.INFO)
      vim.fn.jobstart({ "d2", "--theme", theme, input, output }, {
        on_exit = function(_, code)
          if code == 0 then
            vim.notify("✓ Theme " .. theme .. " applied", vim.log.levels.INFO)
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

    -- D2 Layout
    vim.api.nvim_create_user_command("D2Layout", function(opts)
      local input, output = get_d2_paths()
      local layout = opts.args
      vim.notify("Compiling with " .. layout .. " layout...", vim.log.levels.INFO)
      vim.fn.jobstart({ "d2", "--layout", layout, input, output }, {
        on_exit = function(_, code)
          if code == 0 then
            vim.notify("✓ Layout " .. layout .. " applied", vim.log.levels.INFO)
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

    -- D2 ASCII preview
    vim.api.nvim_create_user_command("D2Ascii", function()
      local input = vim.fn.expand("%:p")
      vim.cmd("vsplit")
      vim.cmd("enew")
      vim.cmd("setlocal buftype=nofile bufhidden=wipe nobuflisted noswapfile")
      vim.cmd("setlocal filetype=d2ascii")
      vim.api.nvim_buf_set_name(0, "[D2 ASCII Preview]")
      vim.fn.jobstart({ "d2", "--layout", "elk", "--output-format", "ascii", input }, {
        stdout_buffered = true,
        on_stdout = function(_, data)
          if data then
            vim.api.nvim_buf_set_lines(0, 0, -1, false, data)
          end
        end,
        on_exit = function(_, code)
          if code == 0 then
            vim.notify("✓ ASCII diagram rendered", vim.log.levels.INFO)
          else
            vim.notify("✗ ASCII render failed", vim.log.levels.ERROR)
          end
        end,
      })
    end, {})

    -- D2 Sketch
    vim.api.nvim_create_user_command("D2Sketch", function()
      local input, output = get_d2_paths()
      local sketch_output = output:gsub("%.svg$", "-sketch.svg")
      vim.notify("Rendering sketch...", vim.log.levels.INFO)
      vim.fn.jobstart({ "d2", "--sketch", input, sketch_output }, {
        on_exit = function(_, code)
          if code == 0 then
            vim.notify("✓ Sketch rendered: " .. vim.fn.fnamemodify(sketch_output, ":t"), vim.log.levels.INFO)
            local open_cmd
            if vim.fn.has("mac") == 1 then
              open_cmd = "open"
            elseif vim.fn.has("unix") == 1 then
              open_cmd = "xdg-open"
            elseif vim.fn.has("win32") == 1 then
              open_cmd = "start"
            end
            if open_cmd then
              vim.fn.jobstart({ open_cmd, sketch_output }, { detach = true })
            end
          else
            vim.notify("✗ Sketch render failed", vim.log.levels.ERROR)
          end
        end,
      })
    end, {})

    -- D2 GIF Export
    vim.api.nvim_create_user_command("D2Gif", function(opts)
      local input, output = get_d2_paths()
      local png_output = output:gsub("%.svg$", ".png")
      local gif_output = output:gsub("%.svg$", ".gif")
      local args = vim.split(opts.args or "", "%s+")
      local cmd_args = { "d2" }

      if vim.tbl_contains(args, "animate") then
        table.insert(cmd_args, "--animate-interval")
        table.insert(cmd_args, "100")
      end
      if vim.tbl_contains(args, "sketch") then
        table.insert(cmd_args, "--sketch")
        png_output = png_output:gsub("%.png$", "-sketch.png")
        gif_output = gif_output:gsub("%.gif$", "-sketch.gif")
      end
      for _, arg in ipairs(args) do
        local theme = arg:match("^theme=(%d+)$")
        if theme then
          table.insert(cmd_args, "--theme")
          table.insert(cmd_args, theme)
        end
      end
      for _, arg in ipairs(args) do
        local layout = arg:match("^layout=(%w+)$")
        if layout then
          table.insert(cmd_args, "--layout")
          table.insert(cmd_args, layout)
        end
      end
      table.insert(cmd_args, input)
      table.insert(cmd_args, png_output)

      vim.notify("Rendering PNG...", vim.log.levels.INFO)
      vim.fn.jobstart(cmd_args, {
        on_exit = function(_, code)
          if code == 0 then
            vim.notify("✓ PNG rendered, converting to GIF...", vim.log.levels.INFO)
            vim.fn.jobstart({ "/run/current-system/sw/bin/magick", png_output, gif_output }, {
              on_exit = function(_, convert_code)
                if convert_code == 0 then
                  vim.notify("✓ GIF created: " .. vim.fn.fnamemodify(gif_output, ":t"), vim.log.levels.INFO)
                  local open_cmd
                  if vim.fn.has("mac") == 1 then
                    open_cmd = "open"
                  elseif vim.fn.has("unix") == 1 then
                    open_cmd = "xdg-open"
                  elseif vim.fn.has("win32") == 1 then
                    open_cmd = "start"
                  end
                  if open_cmd then
                    vim.fn.jobstart({ open_cmd, gif_output }, { detach = true })
                  end
                else
                  if vim.fn.executable("/run/current-system/sw/bin/magick") == 0 then
                    vim.notify("Install ImageMagick!", vim.log.levels.ERROR)
                    return
                  end
                end
              end,
            })
          else
            vim.notify("✗ PNG render failed", vim.log.levels.ERROR)
          end
        end,
      })
    end, {
      nargs = "?",
      complete = function()
        return { "animate", "sketch", "theme=0", "theme=1", "theme=3", "theme=4", "layout=elk", "layout=dagre",
          "layout=tala" }
      end,
    })

    -- Auto-compile on save
    vim.api.nvim_create_autocmd("BufWritePost", {
      pattern = "*.d2",
      callback = function()
        vim.cmd("D2Render")
      end,
    })

    -- Keybindings
    vim.api.nvim_create_autocmd("FileType", {
      pattern = "d2",
      callback = function()
        local opts = { buffer = true, silent = true }
        vim.keymap.set("n", "<leader>dp", ":D2Preview<CR>", vim.tbl_extend("force", opts, { desc = "D2: Preview" }))
        vim.keymap.set("n", "<leader>dw", ":D2Watch<CR>", vim.tbl_extend("force", opts, { desc = "D2: Watch" }))
        vim.keymap.set("n", "<leader>dW", ":D2Watch sketch<CR>",
          vim.tbl_extend("force", opts, { desc = "D2: Watch Sketch" }))
        vim.keymap.set("n", "<leader>dc", ":D2Render<CR>", vim.tbl_extend("force", opts, { desc = "D2: Compile" }))
        vim.keymap.set("n", "<leader>da", ":D2Ascii<CR>", vim.tbl_extend("force", opts, { desc = "D2: ASCII" }))
        vim.keymap.set("n", "<leader>ds", ":D2Sketch<CR>", vim.tbl_extend("force", opts, { desc = "D2: Sketch" }))
        vim.keymap.set("n", "<leader>dg", ":D2Gif<CR>", vim.tbl_extend("force", opts, { desc = "D2: GIF" }))
        vim.keymap.set("n", "<leader>dG", ":D2Gif animate sketch<CR>",
          vim.tbl_extend("force", opts, { desc = "D2: GIF Animated" }))

        for _, theme in ipairs({ "0", "1", "3", "4", "5", "6", "7", "8" }) do
          vim.keymap.set("n", "<leader>d" .. theme, ":D2Theme " .. theme .. "<CR>",
            vim.tbl_extend("force", opts, { desc = "D2: Theme " .. theme }))
        end

        vim.keymap.set("n", "<leader>dld", ":D2Layout dagre<CR>", vim.tbl_extend("force", opts, { desc = "D2: Dagre" }))
        vim.keymap.set("n", "<leader>dle", ":D2Layout elk<CR>", vim.tbl_extend("force", opts, { desc = "D2: ELK" }))
        vim.keymap.set("n", "<leader>dlt", ":D2Layout tala<CR>", vim.tbl_extend("force", opts, { desc = "D2: TALA" }))
      end,
    })
  end,
}
