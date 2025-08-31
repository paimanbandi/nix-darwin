return {
  {
    "mfussenegger/nvim-dap",
    dependencies = {
      "rcarriga/nvim-dap-ui",
      "nvim-neotest/nvim-nio",
      "theHamsta/nvim-dap-virtual-text",
      "mxsdev/nvim-dap-vscode-js",
    },
    config = function()
      local dap = require("dap")
      local dapui = require("dapui")

      -- Setup UI
      dapui.setup()
      require("nvim-dap-virtual-text").setup()

      dap.listeners.after.event_initialized["dapui_config"] = function()
        dapui.open()
      end
      dap.listeners.before.event_terminated["dapui_config"] = function()
        dapui.close()
      end
      dap.listeners.before.event_exited["dapui_config"] = function()
        dapui.close()
      end

      -- Setup vscode-js-debug
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
  {
    "microsoft/vscode-js-debug",
    build = "npm install --legacy-peer-deps && npm run compile",
    version = "1.*",
  },
  {
    "leoluz/nvim-dap-go",
    config = function()
      require("dap-go").setup()
      -- optional keymaps
      vim.keymap.set("n", "<leader>dt", function()
        require("dap-go").debug_test()
      end, { desc = "Debug Go test" })

      vim.keymap.set("n", "<leader>dl", function()
        require("dap-go").debug_last_test()
      end, { desc = "Debug last Go test" })
    end,
  },
}
