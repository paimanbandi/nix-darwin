return {
  "hrsh7th/nvim-cmp",
  dependencies = {
    "hrsh7th/cmp-nvim-lsp",
    "L3MON4D3/LuaSnip",
  },
  config = function()
    local cmp_autopairs = require("nvim-autopairs.completion.cmp")
    local cmp = require("cmp")

    cmp.event:on("confirm_done", cmp_autopairs.on_confirm_done())

    cmp.setup({
      snippet = {
        expand = function(args)
          require("luasnip").lsp_expand(args.body)
        end,
      },

      window = {
        completion = {
          border = "rounded",
          scrollbar = false,
          winhighlight = "Normal:Normal,FloatBorder:FloatBorder",
        },
        documentation = {
          border = "rounded",
        },
      },

      formatting = {
        fields = { "abbr", "kind", "menu" },
        format = function(entry, vim_item)
          local max_width = 100
          if #vim_item.abbr > max_width then
            vim_item.abbr = vim_item.abbr:sub(1, max_width - 3) .. "..."
          end
          return vim_item
        end,
      },

      view = {
        entries = {
          name = "custom",
          selection_order = "near_cursor",
        },
      },

      mapping = cmp.mapping.preset.insert({
        ["<C-Space>"] = cmp.mapping.complete(),
        ["<CR>"] = cmp.mapping.confirm({ select = true }),
      }),

      sources = cmp.config.sources({
        { name = "nvim_lsp" },
      }),
    })
  end,
}
