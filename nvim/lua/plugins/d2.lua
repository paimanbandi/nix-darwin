return {
  "terrastruct/d2-vim",
  ft = { "d2" }, -- lazy load hanya untuk file .d2
  config = function()
    -- Command untuk render D2 ke SVG
    vim.api.nvim_create_user_command('D2Render', function()
      local input = vim.fn.expand('%:p')         -- file .d2 saat ini
      local output = input:gsub('%.d2$', '.svg') -- output svg
      local result = vim.fn.system({ 'd2', input, '-o', output })
      if vim.v.shell_error == 0 then
        print('Rendered: ' .. output)
      else
        print('Error: ' .. result)
      end
    end, {})

    -- Optional: auto-compile saat save
    vim.api.nvim_create_autocmd("BufWritePost", {
      pattern = "*.d2",
      callback = function()
        vim.cmd("D2Render")
      end,
    })
  end,
}
