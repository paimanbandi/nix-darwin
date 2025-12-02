-- Plugin untuk export mermaid ke PNG/SVG
local M = {}

-- Helper function untuk find Chrome browser
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

-- Helper function untuk check dependencies
M.check_dependencies = function()
  local mmdc_check = vim.fn.system("which mmdc"):gsub("\n", "")

  if mmdc_check == "" then
    vim.notify("❌ mermaid-cli not found! Install it first:", vim.log.levels.ERROR)
    vim.notify("npm install -g @mermaid-js/mermaid-cli", vim.log.levels.INFO)
    return false
  end

  local chrome_path = M.find_chrome()
  if not chrome_path then
    vim.notify("❌ Chrome not found! Install Chrome, Arc, or Brave browser", vim.log.levels.ERROR)
    vim.notify("Or run: npx puppeteer browsers install chrome", vim.log.levels.INFO)
    return false
  end

  return true
end

-- Helper function untuk extract pure mermaid content
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

-- Helper function untuk export mermaid block
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

  -- Get ALL lines from start to end (including the mermaid block)
  local lines = vim.api.nvim_buf_get_lines(0, start_line - 1, end_line, false)
  local mermaid_content = M.extract_mermaid_content(lines)

  if #mermaid_content == 0 then
    vim.notify("❌ No valid mermaid content found in block", vim.log.levels.ERROR)
    return
  end

  -- Create temp file with PURE mermaid content (no markdown wrapper)
  local temp_file = vim.fn.tempname() .. ".mmd"
  vim.fn.writefile(mermaid_content, temp_file)

  local base_name = vim.fn.expand("%:t:r")
  local output_file = vim.fn.expand("%:p:h") .. "/" .. base_name .. "." .. format

  local chrome_path = M.find_chrome()

  vim.notify("🖼️  Exporting mermaid block to " .. format:upper() .. "...", vim.log.levels.INFO)

  local cmd
  if format == "png" then
    cmd = string.format(
      "PUPPETEER_EXECUTABLE_PATH=%s mmdc -i %s -o %s -t dark -b white --scale 5 --width 4000 --height 4000",
      vim.fn.shellescape(chrome_path),
      vim.fn.shellescape(temp_file),
      vim.fn.shellescape(output_file)
    )
  else -- svg
    cmd = string.format(
      "PUPPETEER_EXECUTABLE_PATH=%s mmdc -i %s -o %s -t dark -b transparent",
      vim.fn.shellescape(chrome_path),
      vim.fn.shellescape(temp_file),
      vim.fn.shellescape(output_file)
    )
  end

  vim.fn.jobstart(cmd, {
    on_exit = function(_, exit_code)
      pcall(os.remove, temp_file)

      if exit_code == 0 then
        vim.notify("✅ Exported to: " .. output_file, vim.log.levels.INFO)
        vim.fn.system("open " .. vim.fn.shellescape(output_file))
      else
        vim.notify("❌ Export failed! Check if mermaid-cli is installed correctly", vim.log.levels.ERROR)
        vim.notify("💡 Try: npm install -g @mermaid-js/mermaid-cli", vim.log.levels.INFO)
      end
    end,
    on_stderr = function(_, data)
      if data and #data > 0 then
        local error_msg = table.concat(data, "\n")
        if error_msg ~= "" and not error_msg:match("^%s*$") then
          print("Export stderr:", error_msg)
        end
      end
    end
  })
end

-- Helper function untuk export full document
M.export_full_document = function(format)
  if not M.check_dependencies() then
    return
  end

  local file = vim.fn.expand('%:p')

  -- Read file and extract all mermaid blocks
  local all_lines = vim.fn.readfile(file)
  local mermaid_content = M.extract_mermaid_content(all_lines)

  if #mermaid_content == 0 then
    vim.notify("⚠️  No mermaid content found in file", vim.log.levels.WARN)
    return
  end

  -- Create output directory
  local output_dir = vim.fn.expand("%:p:h") .. "/diagrams"
  vim.fn.mkdir(output_dir, "p")

  local base_name = vim.fn.expand("%:t:r")
  local output_file = output_dir .. "/" .. base_name .. "." .. format

  -- Create temp file with pure mermaid content
  local temp_file = vim.fn.tempname() .. ".mmd"
  vim.fn.writefile(mermaid_content, temp_file)

  local chrome_path = M.find_chrome()

  vim.notify("🖼️  Exporting full document to " .. format:upper() .. "...", vim.log.levels.INFO)

  local cmd
  if format == "png" then
    cmd = string.format(
      "PUPPETEER_EXECUTABLE_PATH=%s mmdc -i %s -o %s -t dark -b white --scale 6 --width 5000 --height 5000",
      vim.fn.shellescape(chrome_path),
      vim.fn.shellescape(temp_file),
      vim.fn.shellescape(output_file)
    )
  else -- svg
    cmd = string.format(
      "PUPPETEER_EXECUTABLE_PATH=%s mmdc -i %s -o %s -t dark -b transparent",
      vim.fn.shellescape(chrome_path),
      vim.fn.shellescape(temp_file),
      vim.fn.shellescape(output_file)
    )
  end

  vim.fn.jobstart(cmd, {
    on_exit = function(_, exit_code)
      pcall(os.remove, temp_file)

      if exit_code == 0 then
        vim.notify("✅ Exported to: " .. output_file, vim.log.levels.INFO)
        vim.fn.system("open " .. vim.fn.shellescape(output_file))
      else
        vim.notify("❌ Export failed! Check if mermaid-cli is installed correctly", vim.log.levels.ERROR)
        vim.notify("💡 Try: npm install -g @mermaid-js/mermaid-cli", vim.log.levels.INFO)
      end
    end,
    on_stderr = function(_, data)
      if data and #data > 0 then
        local error_msg = table.concat(data, "\n")
        if error_msg ~= "" and not error_msg:match("^%s*$") then
          print("Export stderr:", error_msg)
        end
      end
    end
  })
end

return {
  "iamcco/markdown-preview.nvim",
  keys = {
    {
      "<leader>me",
      function()
        M.export_mermaid_block("png")
      end,
      desc = "Export Mermaid Block to PNG"
    },
    {
      "<leader>mE",
      function()
        M.export_full_document("png")
      end,
      desc = "Export All Mermaid to PNG"
    },
    {
      "<leader>mv",
      function()
        M.export_mermaid_block("svg")
      end,
      desc = "Export Mermaid Block to SVG"
    },
    {
      "<leader>mV",
      function()
        M.export_full_document("svg")
      end,
      desc = "Export All Mermaid to SVG"
    },
  },
}
