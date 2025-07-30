return {
  "neovim/nvim-lspconfig",
  event = { "BufReadPre", "BufNewFile" },
  dependencies = {
    "williamboman/mason.nvim",
    "williamboman/mason-lspconfig.nvim",
  },
  config = function()
    require("mason").setup()
    require("mason-lspconfig").setup({
      ensure_installed = { "rust_analyzer", "lua_ls", "ts_ls", "tailwindcss", "html", "cssls" },
    })

    local lspconfig = require("lspconfig")

    local function on_attach(_, bufnr)
      print("LSP attached to buffer " .. bufnr)
      vim.notify("LSP attached to buffer " .. bufnr)

      local opts = { buffer = bufnr, noremap = true, silent = true }
      vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
      vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
      vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, opts)
      vim.keymap.set("n", "<leader>of", vim.diagnostic.open_float, opts)
    end

    local capabilities = vim.lsp.protocol.make_client_capabilities()
    capabilities.textDocument.completion.completionItem.snippetSupport = true

    local servers = {
      rust_analyzer = {
        settings = {
          ["rust-analyzer"] = {
            files = {
              sysrootSrc = "/nix/store/j83m2n8kf6rasivjh0rw0y53rq04ypcv-rust-complete-1.88.0/lib/rustlib/src/rust"
            },
            cargo = {
              allFeatures = true,
            },
            procMacro = {
              enable = true,
            },
          }
        }
      },
      lua_ls = {}, -- default
      ts_ls = {},
      tailwindcss = {
        filetypes = { "html", "css", "scss", "javascript", "javascriptreact", "typescript", "typescriptreact" },
      },
      html = {},
      cssls = {},
      emmet_ls = {
        capabilities = capabilities,
        filetypes = { "css", "eruby", "html", "javascript", "javascriptreact", "less", "sass", "scss", "svelte", "pug", "typescriptreact", "vue" },
        init_options = {
          html = {
            options = {
              ["bem.enabled"] = true,
            },
          },
        }
      }
    }

    for server_name, server_config in pairs(servers) do
      lspconfig[server_name].setup(vim.tbl_extend("force", {
        on_attach = on_attach,
      }, server_config))
    end

    vim.diagnostic.config({
      virtual_text = false,
      signs = true,
      underline = true,
      update_in_insert = false,
      severity_sort = true,
    })
  end,
}
