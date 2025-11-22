return {
  "norcalli/nvim-colorizer.lua",
  event = { "BufReadPost", "BufNewFile" },
  config = function()
    require("colorizer").setup({
      "*", -- Highlight all files
      css = { rgb_fn = true }, -- Enable parsing rgb(...) functions in css
      html = { names = false }, -- Disable parsing "names" like Blue or Gray
    })
  end,
}
