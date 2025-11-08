return {
  name = "Cargo build (release)",
  builder = function()
    return {
      cmd = { "cargo" },
      args = { "build", "--release" },
      cwd = vim.fn.getcwd(),
      components = {
        { "on_output_quickfix", open = false }, -- kirim error ke quickfix list
        "default",                              -- komponen default (tampilkan output di bawah)
      },
    }
  end,
  condition = {
    filetype = { "rust" }, -- muncul hanya di file Rust
  },
}
