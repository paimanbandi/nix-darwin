-- Plugin untuk export mermaid ke PNG/SVG
local M = {}

M.find_chrome = function()
  local chrome_paths = {
    "/Applications/Google Chrome.app/Contents/MacOS/Google Chrome",
    "/Applications/Arc.app/Contents/MacOS/Arc",
    "/Applications/Brave Browser.app/Contents/MacOS/Brave Browser",
    vim.fn.expand(
      "~/.cache/puppeteer/chrome/mac_arm-*/chrome-mac-arm64/Google Chrome for Testing.app/Contents/MacOS/Google Chrome for Testing"),
  }

  for _, path in ipairs(chrome_paths) do
    local expanded = vim.fn.glob(path)
    if expanded ~= "" and vim.fn.filereadable(expanded) == 1 then
      return expanded
    end
  end

  return nil
end

M.check_dependencies = function()
  local mmdc_check = vim.fn.system("which mmdc"):gsub("\n", "")

  if mmdc_check == "" then
    vim.notify("❌ mermaid-cli not found!", vim.log.levels.ERROR)
    vim.notify("npm install -g @mermaid-js/mermaid-cli", vim.log.levels.INFO)
    return false
  end

  local chrome_path = M.find_chrome()
  if not chrome_path then
    vim.notify("❌ Chrome not found!", vim.log.levels.ERROR)
    return false
  end

  return true
end

M.extract_mermaid_content = function(lines)
  local mermaid_lines = {}
  local in_mermaid = false

  for _, line in ipairs(lines) do
    if line:match("^```mermaid") then
      in_mermaid = true
    elseif line:match("^```$") and in_mermaid then
      in_mermaid = false
    elseif in_mermaid then
      table.insert(mermaid_lines, line)
    end
  end

  return mermaid_lines
end

M.export_mermaid_block = function(format)
  if not M.check_dependencies() then
    return
  end

  local start_line = vim.fn.search("```mermaid", "bnW")
  local end_line = vim.fn.search("```", "nW")

  if start_line == 0 or end_line == 0 then
    vim.notify("⚠️  No mermaid block found at cursor", vim.log.levels.WARN)
    return
  end

  local lines = vim.api.nvim_buf_get_lines(0, start_line - 1, end_line, false)
  local mermaid_content = M.extract_mermaid_content(lines)

  if #mermaid_content == 0 then
    vim.notify("❌ No valid mermaid content", vim.log.levels.ERROR)
    return
  end

  local temp_file = vim.fn.tempname() .. ".mmd"
  vim.fn.writefile(mermaid_content, temp_file)

  -- Puppeteer config with increased timeout
  local config_file = vim.fn.tempname() .. ".json"
  local config = [[{
  "puppeteerConfig": {
    "timeout": 120000,
    "args": ["--no-sandbox", "--disable-setuid-sandbox", "--disable-dev-shm-usage"]
  }
}]]
  vim.fn.writefile(vim.split(config, "\n"), config_file)

  local base_name = vim.fn.expand("%:t:r")
  local output_file = vim.fn.expand("%:p:h") .. "/" .. base_name .. "." .. format
  local chrome_path = M.find_chrome()

  vim.notify("🖼️  Exporting... (may take 30-60 sec for large diagrams)", vim.log.levels.INFO)

  local cmd
  if format == "png" then
    cmd = string.format(
      "PUPPETEER_EXECUTABLE_PATH=%s mmdc -i %s -o %s -c %s -t dark -b white",
      vim.fn.shellescape(chrome_path),
      vim.fn.shellescape(temp_file),
      vim.fn.shellescape(output_file),
      vim.fn.shellescape(config_file)
    )
  else
    cmd = string.format(
      "PUPPETEER_EXECUTABLE_PATH=%s mmdc -i %s -o %s -c %s -t dark -b transparent",
      vim.fn.shellescape(chrome_path),
      vim.fn.shellescape(temp_file),
      vim.fn.shellescape(output_file),
      vim.fn.shellescape(config_file)
    )
  end

  vim.fn.jobstart(cmd, {
    on_exit = function(_, exit_code)
      pcall(os.remove, temp_file)
      pcall(os.remove, config_file)

      if exit_code == 0 then
        vim.notify("✅ Exported: " .. output_file, vim.log.levels.INFO)
        vim.fn.system("open " .. vim.fn.shellescape(output_file))
      else
        vim.notify("❌ Export failed. Try <leader>ml for browser export", vim.log.levels.ERROR)
      end
    end
  })
end

M.export_full_document = function(format)
  if not M.check_dependencies() then
    return
  end

  local file = vim.fn.expand('%:p')
  local all_lines = vim.fn.readfile(file)
  local mermaid_content = M.extract_mermaid_content(all_lines)

  if #mermaid_content == 0 then
    vim.notify("⚠️  No mermaid content found", vim.log.levels.WARN)
    return
  end

  local output_dir = vim.fn.expand("%:p:h") .. "/diagrams"
  vim.fn.mkdir(output_dir, "p")

  local base_name = vim.fn.expand("%:t:r")
  local output_file = output_dir .. "/" .. base_name .. "." .. format

  local temp_file = vim.fn.tempname() .. ".mmd"
  vim.fn.writefile(mermaid_content, temp_file)

  local config_file = vim.fn.tempname() .. ".json"
  local config = [[{
  "puppeteerConfig": {
    "timeout": 120000,
    "args": ["--no-sandbox", "--disable-setuid-sandbox", "--disable-dev-shm-usage"]
  }
}]]
  vim.fn.writefile(vim.split(config, "\n"), config_file)

  local chrome_path = M.find_chrome()
  vim.notify("🖼️  Exporting full document...", vim.log.levels.INFO)

  local cmd
  if format == "png" then
    cmd = string.format(
      "PUPPETEER_EXECUTABLE_PATH=%s mmdc -i %s -o %s -c %s -t dark -b white",
      vim.fn.shellescape(chrome_path),
      vim.fn.shellescape(temp_file),
      vim.fn.shellescape(output_file),
      vim.fn.shellescape(config_file)
    )
  else
    cmd = string.format(
      "PUPPETEER_EXECUTABLE_PATH=%s mmdc -i %s -o %s -c %s -t dark -b transparent",
      vim.fn.shellescape(chrome_path),
      vim.fn.shellescape(temp_file),
      vim.fn.shellescape(output_file),
      vim.fn.shellescape(config_file)
    )
  end

  vim.fn.jobstart(cmd, {
    on_exit = function(_, exit_code)
      pcall(os.remove, temp_file)
      pcall(os.remove, config_file)

      if exit_code == 0 then
        vim.notify("✅ Exported: " .. output_file, vim.log.levels.INFO)
        vim.fn.system("open " .. vim.fn.shellescape(output_file))
      else
        vim.notify("❌ Export failed", vim.log.levels.ERROR)
      end
    end
  })
end

M.open_in_mermaid_live = function()
  local start_line = vim.fn.search("```mermaid", "bnW")
  local end_line = vim.fn.search("```", "nW")

  if start_line == 0 or end_line == 0 then
    vim.notify("⚠️  No mermaid block found", vim.log.levels.WARN)
    return
  end

  local lines = vim.api.nvim_buf_get_lines(0, start_line - 1, end_line, false)
  local mermaid_content = M.extract_mermaid_content(lines)

  if #mermaid_content == 0 then
    vim.notify("❌ No valid mermaid content", vim.log.levels.ERROR)
    return
  end

  local content = table.concat(mermaid_content, "\n")
  local encoded = vim.fn.system('printf "%s" ' .. vim.fn.shellescape(content) .. ' | base64')
  encoded = encoded:gsub("\n", "")

  local url = "https://mermaid.live/edit#pako:" .. encoded
  vim.fn.system("open " .. vim.fn.shellescape(url))

  vim.notify("🌐 Opened in Mermaid Live. Click 'Actions' → 'Download PNG'", vim.log.levels.INFO)
end

return {
  "iamcco/markdown-preview.nvim",
  build = function()
    vim.fn["mkdp#util#install"]()
  end,
  ft = { "markdown", "mermaid" },
  config = function()
    vim.g.mkdp_theme = 'dark'
    vim.g.mkdp_auto_start = 0
    vim.g.mkdp_auto_close = 1
    vim.g.mkdp_refresh_slow = 0
    vim.g.mkdp_command_for_global = 0
    vim.g.mkdp_open_to_the_world = 0
    vim.g.mkdp_browser = ''
    vim.g.mkdp_echo_preview_url = 1

    -- ✅ FIX: Use latest mermaid version
    vim.g.mkdp_preview_options = {
      mkit = {},
      katex = {},
      uml = {},
      maid = {
        theme = 'dark',
        -- ✅ Add mermaid config
        startOnLoad = true,
        securityLevel = 'loose', -- Allow HTML in labels
        flowchart = {
          htmlLabels = true,     -- Enable HTML labels
          curve = 'basis'
        }
      },
      disable_sync_scroll = 0,
      sync_scroll_type = 'middle',
      hide_yaml_meta = 1,
      sequence_diagrams = {},
      flowchart_diagrams = {},
      content_editable = false,
    }
  end,
  keys = {
    {
      "<leader>me",
      function()
        M.export_mermaid_block("png")
      end,
      desc = "Export Mermaid to PNG"
    },
    {
      "<leader>mE",
      function()
        M.export_full_document("png")
      end,
      desc = "Export All to PNG"
    },
    {
      "<leader>mv",
      function()
        M.export_mermaid_block("svg")
      end,
      desc = "Export Mermaid to SVG"
    },
    {
      "<leader>mV",
      function()
        M.export_full_document("svg")
      end,
      desc = "Export All to SVG"
    },
    {
      "<leader>ml",
      function()
        M.open_in_mermaid_live()
      end,
      desc = "Open in Mermaid Live (Browser)"
    },
  },
}
