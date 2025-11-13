vim.api.nvim_create_autocmd("CursorHold", {
  callback = function()
    vim.diagnostic.open_float(nil, {
      focusable = false,
      close_events = { "BufLeave", "CursorMoved", "InsertEnter", "FocusLost" },
      border = "rounded",
      source = "always",
      prefix = " ",
    })
  end,
})
vim.api.nvim_create_autocmd("VimEnter", {
  callback = function()
    if vim.env.NVIM_NO_TITLE then
      vim.opt.title = false
      vim.opt.titlestring = ""
      vim.opt.icon = false
      vim.opt.iconstring = ""
    end
  end,
})
