require("bootstrap.lazy")

local config = vim.fn.stdpath("config")
package.path = config .. "/lua/?.lua;" .. package.path
package.path = config .. "/lua/?/init.lua;" .. package.path

require("plugins")
require("autocmd")
require("settings")
require("keymaps")
