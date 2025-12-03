return {
      "MeanderingProgrammer/render-markdown.nvim",
      dependencies = {
        "nvim-treesitter/nvim-treesitter",
        "nvim-tree/nvim-web-devicons"
      },
      opts = {
        code = {
          sign = false,
          width = 'block',
          right_pad = 1,
          disable_background = { "mermaid" },
          highlight = "",
        },
        heading = {
          sign = false,
          icons = {}
        },
        file_types = { "markdown" },
        exclude = {
          buftypes = { "nofile", "terminal" },
        },
      },
      ft = { "markdown", "mermaid" },
      config = function(_, opts)
        require("render-markdown").setup(opts)

        vim.api.nvim_create_autocmd("BufEnter", {
          pattern = "*_generate_docs_*.md,*_generate_tests_*.md,*_full_docs_*.md",
          callback = function()
            vim.cmd("RenderMarkdown disable")
            vim.wo.conceallevel = 0
          end,
        })

        vim.api.nvim_set_hl(0, "RenderMarkdownCode", {
          fg = "#7aa2f7",
          bg = "NONE"
        })
        vim.api.nvim_set_hl(0, "RenderMarkdownCodeInline", {
          fg = "#7aa2f7",
          bg = "NONE"
        })
        vim.api.nvim_set_hl(0, "ColorColumn", {
          bg = "#1a1b26"
        })
        vim.api.nvim_create_autocmd("ColorScheme", {
          callback = function()
            vim.schedule(function()
              vim.api.nvim_set_hl(0, "RenderMarkdownCode", {
                fg = "#7aa2f7",
                bg = "NONE"
              })
              vim.api.nvim_set_hl(0, "RenderMarkdownCodeInline", {
                fg = "#7aa2f7",
                bg = "NONE"
              })
            end)
          end,
        })
      end,
    },

    -- UPDATE markview config:
    {
      "OXY2DEV/markview.nvim",
      lazy = false,
      dependencies = {
        "nvim-treesitter/nvim-treesitter",
        "nvim-tree/nvim-web-devicons"
      },
      config = function()
        require("markview").setup({
          modes = { "n", "no", "c" },
          hybrid_modes = { "n" },
          callbacks = {
            on_enable = function(_, win)
              vim.wo[win].conceallevel = 2
              vim.wo[win].concealcursor = "c"
            end
          },
          buf_ignore = { "*_generate_docs_*.md", "*_generate_tests_*.md", "*_full_docs_*.md" },
        })

        vim.api.nvim_create_autocmd("BufEnter", {
          pattern = "*_generate_docs_*.md,*_generate_tests_*.md,*_full_docs_*.md",
          callback = function()
            vim.cmd("Markview disableAll")
            vim.wo.conceallevel = 0
          end,
        })
      end
    }
