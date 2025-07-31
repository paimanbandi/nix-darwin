return {
  "neovim/nvim-lspconfig",
  event = { "BufReadPre", "BufNewFile" },
  dependencies = {
    "williamboman/mason.nvim",
    "williamboman/mason-lspconfig.nvim",
  },
  config = function()
    require("mason").setup()

    local lspconfig = require("lspconfig")

    local function on_attach(_, bufnr)
      vim.notify("LSP attached to buffer " .. bufnr)
      local opts = { buffer = bufnr, noremap = true, silent = true }
      vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
      vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
      vim.keymap.set({ "n", "v" }, "<leader>ca", function()
        vim.lsp.buf.code_action({
          filter = function(action)
            return not (action.kind == "source.fixAll")
          end,
          apply = true,
          context = {
            only = {
              "quickfix",
              "refactor",
              "source",
              "organizeImports"
            },
            diagnostics = vim.diagnostic.get(bufnr)
          }
        })
      end, opts)
      vim.keymap.set("n", "<leader>of", vim.diagnostic.open_float, opts)
    end

    local capabilities = vim.lsp.protocol.make_client_capabilities()
    capabilities.textDocument.completion.completionItem.snippetSupport = true
    capabilities.textDocument.codeAction = {
      dynamicRegistration = true,
      codeActionLiteralSupport = {
        codeActionKind = {
          valueSet = {
            "",
            "quickfix",
            "refactor",
            "refactor.extract",
            "refactor.inline",
            "refactor.rewrite",
            "source",
            "source.organizeImports",
          },
        },
      },
    }

    require("mason-lspconfig").setup({
      ensure_installed = {
        "rust_analyzer", "lua_ls", "ts_ls",
        "tailwindcss", "html", "cssls", "emmet_ls"
      },
      handlers = {
        function(server_name)
          lspconfig[server_name].setup({
            on_attach = on_attach,
            capabilities = capabilities,
          })
        end,

        ["rust_analyzer"] = function()
          lspconfig.rust_analyzer.setup({
            on_attach = on_attach,
            capabilities = capabilities,
            settings = {
              ["rust-analyzer"] = {
                files = {
                  sysrootSrc = "/nix/store/j83m2n8kf6rasivjh0rw0y53rq04ypcv-rust-complete-1.88.0/lib/rustlib/src/rust"
                },
                cargo = { allFeatures = true },
                procMacro = { enable = true },
                checkOnSave = {
                  command = "clippy"
                },
              },
            },
          })
        end,

        ["lua_ls"] = function()
          lspconfig.lua_ls.setup({
            on_attach = on_attach,
            capabilities = capabilities,
            settings = {
              Lua = {
                diagnostics = {
                  globals = { "vim" },
                },
                workspace = {
                  checkThirdParty = false,
                },
              },
            },
          })
        end,

        ["ts_ls"] = function()
          lspconfig.ts_ls.setup({
            on_attach = on_attach,
            capabilities = capabilities,
            init_options = {
              preferences = {
                importModuleSpecifierPreference = "relative",
              }
            }
          })
        end,

        ["emmet_ls"] = function()
          lspconfig.emmet_ls.setup({
            on_attach = on_attach,
            capabilities = capabilities,
            filetypes = {
              "css", "eruby", "html", "javascript", "javascriptreact",
              "less", "sass", "scss", "svelte", "pug", "typescriptreact", "vue"
            },
            init_options = {
              html = {
                options = {
                  ["bem.enabled"] = true,
                },
              },
            },
          })
        end,

        ["tailwindcss"] = function()
          lspconfig.tailwindcss.setup({
            on_attach = on_attach,
            capabilities = capabilities,
            filetypes = {
              "html", "css", "scss", "javascript", "javascriptreact",
              "typescript", "typescriptreact", "svelte", "vue"
            },
          })
        end,
      }
    })

    vim.diagnostic.config({
      virtual_text = false,
      signs = true,
      underline = true,
      update_in_insert = false,
      severity_sort = true,
    })
  end,
}
