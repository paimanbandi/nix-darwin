-- lsp.lua
-- Migrasi ke vim.lsp.config API (Neovim 0.11+)

return {
  "neovim/nvim-lspconfig",
  event = { "BufReadPre", "BufNewFile" },
  dependencies = {
    "williamboman/mason.nvim",
    "williamboman/mason-lspconfig.nvim",
  },
  config = function()
    require("mason").setup()

    -- ✅ capabilities global
    local capabilities = vim.tbl_deep_extend(
      "force",
      vim.lsp.protocol.make_client_capabilities(),
      require("cmp_nvim_lsp").default_capabilities()
    )

    -- ✅ on_attach via LspAttach autocmd
    vim.api.nvim_create_autocmd("LspAttach", {
      callback = function(args)
        local bufnr = args.buf
        local client = vim.lsp.get_client_by_id(args.data.client_id)
        if not client then return end

        vim.notify("LSP attached to buffer " .. bufnr)

        local opts = { buffer = bufnr, noremap = true, silent = true }
        vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
        vim.keymap.set("n", "<leader>of", vim.diagnostic.open_float, opts)

        if client:supports_method("textDocument/formatting") then
          vim.api.nvim_create_autocmd("BufWritePre", {
            buffer = bufnr,
            callback = function()
              vim.lsp.buf.format({ timeout_ms = 3000 })
            end,
          })
        end
      end,
    })

    -- ✅ set capabilities global untuk semua server
    vim.lsp.config("*", {
      capabilities = capabilities,
    })

    require("mason-lspconfig").setup({
      ensure_installed = {
        "rust_analyzer", "lua_ls", "ts_ls",
        "tailwindcss", "html", "cssls", "emmet_ls", "dockerls", "yamlls", "gopls",
      },
      handlers = {
        -- default handler
        function(server_name)
          vim.lsp.enable(server_name)
        end,

        ["rust_analyzer"] = function()
          vim.lsp.config("rust_analyzer", {
            settings = {
              ["rust-analyzer"] = {
                files = {
                  sysrootSrc = "/nix/store/j83m2n8kf6rasivjh0rw0y53rq04ypcv-rust-complete-1.88.0/lib/rustlib/src/rust"
                },
                cargo = { allFeatures = true },
                procMacro = { enable = true },
                checkOnSave = { command = "clippy" },
              },
            },
          })
          vim.lsp.enable("rust_analyzer")
        end,

        ["lua_ls"] = function()
          vim.lsp.config("lua_ls", {
            settings = {
              Lua = {
                runtime = { version = "LuaJIT" },
                diagnostics = { globals = { "vim" } },
                workspace = {
                  library = vim.api.nvim_get_runtime_file("", true),
                  checkThirdParty = false,
                },
                telemetry = { enable = false },
              },
            },
          })
          vim.lsp.enable("lua_ls")
        end,

        ["ts_ls"] = function()
          vim.lsp.config("ts_ls", {
            init_options = {
              preferences = {
                importModuleSpecifierPreference = "relative",
              }
            },
          })
          vim.lsp.enable("ts_ls")
        end,

        ["emmet_ls"] = function()
          vim.lsp.config("emmet_ls", {
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
          vim.lsp.enable("emmet_ls")
        end,

        ["tailwindcss"] = function()
          vim.lsp.config("tailwindcss", {
            filetypes = {
              "html", "css", "scss", "javascript", "javascriptreact",
              "typescript", "typescriptreact", "svelte", "vue"
            },
          })
          vim.lsp.enable("tailwindcss")
        end,

        ["gopls"] = function()
          vim.lsp.config("gopls", {
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
          vim.lsp.enable("gopls")
        end,
      }
    })

    -- ✅ PERUBAHAN: omnisharp pakai vim.lsp.config, bukan lspconfig.setup
    -- Hapus require("lspconfig") sepenuhnya agar tidak trigger deprecated warning
    vim.lsp.config("omnisharp", {
      cmd = { "omnisharp", "--languageserver", "--hostPID", tostring(vim.fn.getpid()) },
      filetypes = { "cs" },
      root_markers = { "*.sln", "*.csproj", ".git" },
      enable_roslyn_analyzers = true,
      organize_imports_on_format = true,
      enable_import_completion = true,
    })
    vim.lsp.enable("omnisharp")

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
