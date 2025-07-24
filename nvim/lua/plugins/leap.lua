return {
  "ggandor/leap.nvim",
  lazy = false,
  config = function()
    local leap = require('leap')
    leap.add_default_mappings()
    leap.opts.case_sensitive = true
  end,
}
