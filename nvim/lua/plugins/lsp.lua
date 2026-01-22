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

    local capabilities = require('cmp_nvim_lsp').default_capabilities()

    local function on_attach(client, bufnr)
      vim.notify("LSP attached to buffer " .. bufnr)
      local opts = { buffer = bufnr, noremap = true, silent = true }
      vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
      vim.keymap.set("n", "<leader>of", vim.diagnostic.open_float, opts)
      if client.supports_method("textDocument/formatting") then
        vim.api.nvim_create_autocmd("BufWritePre", {
          buffer = bufnr,
          callback = function()
            vim.lsp.buf.format({ timeout_ms = 3000 })
          end,
        })
      end
    end

    require("mason-lspconfig").setup({
      ensure_installed = {
        "rust_analyzer", "lua_ls", "ts_ls",
        "tailwindcss", "html", "cssls", "emmet_ls", "dockerls", "yamlls", "gopls",
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
                runtime = {
                  version = "LuaJIT",
                },
                diagnostics = {
                  globals = { "vim" },
                },
                workspace = {
                  library = vim.api.nvim_get_runtime_file("", true),
                  checkThirdParty = false,
                },
                telemetry = {
                  enable = false,
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
        ["gopls"] = function()
          lspconfig.gopls.setup({
            on_attach = on_attach,
            capabilities = capabilities,
            settings = {
              gopls = {
                gofumpt = true,
                analyses = {
                  unusedparams = true,
                  shadow = true,
                },
                staticcheck = true,
              },
            },
          })
        end,
      }
    })

    lspconfig.roslyn.setup({
      on_attach = on_attach,
      capabilities = capabilities,
      cmd = { "Microsoft.CodeAnalysis.LanguageServer" },
      filetypes = { "cs", "vb" },
      root_dir = lspconfig.util.root_pattern("*.sln", "*.csproj", ".git"),
      init_options = {
        ["language"] = "csharp",
      },
      settings = {
        ["csharp|code_style"] = {
          ["namespace_declarations"] = "file_scoped",
        },
      },
    })

    vim.diagnostic.config({
      virtual_text = false,
      signs = false,
      underline = true,
      update_in_insert = false,
      severity_sort = true,
    })

    -- auto save after code action
    local orig_request = vim.lsp.buf_request
    vim.lsp.buf_request = function(bufnr, method, params, handler)
      return orig_request(bufnr, method, params, function(err, result, ctx, config)
        if handler then
          handler(err, result, ctx, config)
        end
        if method == "textDocument/codeAction" or method == "workspace/executeCommand" then
          vim.schedule(function()
            if vim.bo[bufnr].modified then
              vim.cmd("silent! write")
            end
          end)
        end
      end)
    end
  end,
}
