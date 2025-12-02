-- Plugin untuk export mermaid ke PNG/SVG
local M = {}

-- Helper function untuk find Chrome browser
M.find_chrome = function()
  local chrome_paths = {
    "/Applications/Google Chrome.app/Contents/MacOS/Google Chrome",
    "/Applications/Arc.app/Contents/MacOS/Arc",
    "/Applications/Brave Browser.app/Contents/MacOS/Brave Browser",
    vim.fn.expand(
      "~/.cache/puppeteer/chrome/mac_arm-*/chrome-mac-arm64/Google Chrome for Testing.app/Contents/MacOS/Google Chrome for Testing"
    ),
  }

  for _, path in ipairs(chrome_paths) do
    local expanded = vim.fn.glob(path)
    if expanded ~= "" and vim.fn.filereadable(expanded) == 1 then
      return expanded
    end
  end

  return nil
end

-- Helper function untuk export mermaid block
M.export_mermaid_block = function(format)
  local start_line = vim.fn.search("```mermaid", "bnW")
  local end_line = vim.fn.search("```", "nW")

  if start_line == 0 or end_line == 0 then
    vim.notify("No mermaid block found at cursor", vim.log.levels.WARN)
    return
  end

  local lines = vim.api.nvim_buf_get_lines(0, start_line, end_line - 1, false)
  local temp_file = "/tmp/mermaid_temp.mmd"
  local base_name = vim.fn.expand("%:t:r")
  local output_file = vim.fn.expand("%:p:h") .. "/" .. base_name .. "." .. format

  vim.fn.writefile(lines, temp_file)

  local chrome_path = M.find_chrome()

  if not chrome_path then
    vim.notify("Chrome not found! Please install Chrome, Arc, or Brave browser", vim.log.levels.ERROR)
    vim.notify("Or run: npx puppeteer browsers install chrome", vim.log.levels.INFO)
    return
  end

  local cmd
  if format == "png" then
    cmd = string.format(
      "PUPPETEER_EXECUTABLE_PATH='%s' mmdc -i %s -o %s -t dark -b white --scale 5 --width 4000 --height 4000 2>&1",
      chrome_path,
      vim.fn.shellescape(temp_file),
      vim.fn.shellescape(output_file)
    )
  else
    cmd = string.format(
      "PUPPETEER_EXECUTABLE_PATH='%s' mmdc -i %s -o %s -t dark -b transparent 2>&1",
      chrome_path,
      vim.fn.shellescape(temp_file),
      vim.fn.shellescape(output_file)
    )
  end

  vim.notify("Exporting to " .. format:upper() .. " with Chrome at: " .. chrome_path, vim.log.levels.INFO)
  local output = vim.fn.system(cmd)

  if vim.v.shell_error == 0 then
    vim.notify("Exported to: " .. output_file, vim.log.levels.INFO)
    vim.fn.system("open " .. vim.fn.shellescape(output_file))
  else
    vim.notify("Export failed! Error: " .. output, vim.log.levels.ERROR)
  end
end

-- Helper function untuk export full document
M.export_full_document = function(format)
  local file = vim.fn.expand('%:p')
  local output_dir = vim.fn.expand("%:p:h") .. "/diagrams"

  vim.fn.mkdir(output_dir, "p")

  local base_name = vim.fn.expand("%:t:r")
  local output_file = output_dir .. "/" .. base_name .. "." .. format

  local chrome_path = M.find_chrome()

  local cmd
  if format == "png" then
    if chrome_path then
      cmd = string.format(
        "PUPPETEER_EXECUTABLE_PATH='%s' mmdc -i %s -o %s -t dark -b white --scale 6 --width 5000 --height 5000 2>&1",
        chrome_path,
        vim.fn.shellescape(file),
        vim.fn.shellescape(output_file)
      )
    else
      cmd = string.format(
        "mmdc -i %s -o %s -t dark -b white --scale 6 --width 5000 --height 5000",
        vim.fn.shellescape(file),
        vim.fn.shellescape(output_file)
      )
    end
  else
    if not chrome_path then
      vim.notify("Chrome not found! Please install Chrome, Arc, or Brave browser", vim.log.levels.ERROR)
      vim.notify("Or run: npx puppeteer browsers install chrome", vim.log.levels.INFO)
      return
    end

    cmd = string.format(
      "PUPPETEER_EXECUTABLE_PATH='%s' mmdc -i %s -o %s -t dark -b transparent 2>&1",
      chrome_path,
      vim.fn.shellescape(file),
      vim.fn.shellescape(output_file)
    )
  end

  vim.notify("Exporting full document to " .. format:upper() .. "...", vim.log.levels.INFO)
  local output = vim.fn.system(cmd)

  if vim.v.shell_error == 0 then
    vim.notify("Exported to: " .. output_file, vim.log.levels.INFO)
    vim.fn.system("open " .. vim.fn.shellescape(output_file))
  else
    vim.notify("Export failed! Error: " .. output, vim.log.levels.ERROR)
  end
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
      desc = "Export All Mermaid to PNG (High Quality)"
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
