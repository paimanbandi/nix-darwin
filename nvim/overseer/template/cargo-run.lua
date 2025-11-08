return {
  name = "Cargo run (debug)",
  builder = function()
    return {
      cmd = { "cargo" },
      args = { "run" },
      cwd = vim.fn.getcwd(),
      components = { "default" },
    }
  end,
  condition = {
    filetype = { "rust" },
  },
}
