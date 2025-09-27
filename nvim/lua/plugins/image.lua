return {
  {
    "3rd/image.nvim",
    event = "VeryLazy",
    build = function()
      if vim.fn.executable("ueberzug") == 0 then
        vim.notify("Please install ueberzug for better image support: pip install ueberzug")
      end
    end,
    config = function()
      require("image").setup({
        backend = "ueberzug",
        max_width = 100,
        max_height = 60,

        integrations = {
          oil = {
            enabled = true,
            show_file_preview = true,
          },
          nvimtree = {
            enabled = true,
            show_file_preview = true,
          },
        },

        hijack_file_patterns = {
          "*.png", "*.jpg", "*.jpeg", "*.gif", "*.webp", "*.bmp"
        },
      })
    end,
  },
}
