return {
  {
    "mfussenegger/nvim-dap",
    dependencies = {
      "rcarriga/nvim-dap-ui",
      "nvim-neotest/nvim-nio",
      "theHamsta/nvim-dap-virtual-text",
      "mxsdev/nvim-dap-vscode-js",
      "LiadOz/nvim-dap-repl-highlights",
    },
    config = function()
      local dap = require("dap")
      local dapui = require("dapui")

      -- === dap-ui setup ===
      dapui.setup({
        controls = {
          enabled = true,
          element = "repl",
        },
      })

      -- === virtual text setup ===
      require("nvim-dap-virtual-text").setup({
        commented = true,      -- tampilkan nilai di samping code
        virt_text_pos = "eol", -- di akhir baris
        highlight_changed_variables = true,
        all_references = false,
      })

      -- === repl highlight setup ===
      require("nvim-dap-repl-highlights").setup()

      -- buka UI otomatis saat mulai debug
      dap.listeners.after.event_initialized["dapui_config"] = function()
        dapui.open()
      end
      dap.listeners.before.event_terminated["dapui_config"] = function()
        dapui.close()
      end
      dap.listeners.before.event_exited["dapui_config"] = function()
        dapui.close()
      end

      -- === vscode-js-debug setup ===
      require("dap-vscode-js").setup({
        debugger_path = vim.fn.stdpath("data") .. "/lazy/vscode-js-debug",
        adapters = { "pwa-node", "pwa-chrome", "node-terminal", "pwa-extensionHost" },
      })

      for _, language in ipairs({ "typescript", "javascript" }) do
        dap.configurations[language] = {
          {
            type = "pwa-node",
            request = "launch",
            name = "Launch file",
            program = "${file}",
            cwd = "${workspaceFolder}",
          },
          {
            type = "pwa-node",
            request = "attach",
            name = "Attach debugger",
            processId = require("dap.utils").pick_process,
            cwd = "${workspaceFolder}",
          },
        }
      end
    end,
  },

  -- vscode-js-debug dependency
  {
    "microsoft/vscode-js-debug",
    build = "npm install --legacy-peer-deps && npm run compile",
    version = "1.*",
  },

  -- Go debugger
  {
    "leoluz/nvim-dap-go",
    config = function()
      require("dap-go").setup()
      vim.keymap.set("n", "<leader>dt", function()
        require("dap-go").debug_test()
      end, { desc = "Debug Go test" })

      vim.keymap.set("n", "<leader>dl", function()
        require("dap-go").debug_last_test()
      end, { desc = "Debug last Go test" })
    end,
  },
}
