-- markdown-ai-config.lua
-- Configuration and setup for the diagram generator

local M = {}

-- Default configuration
M.default_config = {
  provider = "claude", -- "claude", "deepseek", "openai", "ollama"
  auto_detect = true,
  save_path = "./diagrams",
  default_complexity = "moderate",

  -- Provider-specific settings
  providers = {
    claude = {
      enabled = true,
      cli_command = "claude",
      timeout = 30000, -- 30 seconds
    },
    deepseek = {
      enabled = true,
      api_key_env = "DEEPSEEK_API_KEY",
      model = "deepseek-chat",
      base_url = "https://api.deepseek.com",
      timeout = 30000,
    },
    openai = {
      enabled = false,
      api_key_env = "OPENAI_API_KEY",
      model = "gpt-4",
    }
  },

  -- Diagram settings
  diagrams = {
    flowchart = {
      max_nodes = 50,
      default_style = "rounded",
    },
    sequence = {
      show_activations = true,
      show_notes = true,
    },
    class_diagram = {
      show_methods = true,
      show_properties = true,
    }
  }
}

-- Current configuration
M.config = vim.deepcopy(M.default_config)

-- Setup function
M.setup = function(user_config)
  if user_config then
    M.config = vim.tbl_deep_extend("force", M.config, user_config)
  end

  -- Create save directory if it doesn't exist
  local dir = M.config.save_path
  if dir and dir ~= "." and dir ~= "./" then
    vim.fn.mkdir(dir, "p")
  end

  vim.notify("✅ Diagram generator configured", vim.log.levels.INFO)
end

-- Check if provider is available
M.is_provider_available = function(provider_name)
  local provider_config = M.config.providers[provider_name]
  if not provider_config or not provider_config.enabled then
    return false
  end

  if provider_name == "claude" then
    -- Check if claude CLI is installed
    local claude_path = vim.fn.system("which claude"):gsub("\n", "")
    return claude_path ~= ""
  elseif provider_name == "deepseek" then
    -- Check if API key is set
    local api_key = os.getenv(provider_config.api_key_env)
    if not api_key then
      vim.notify("⚠️  " .. provider_config.api_key_env .. " not set", vim.log.levels.WARN)
      return false
    end

    -- Check if openai module is available
    local success = pcall(require, "openai")
    return success
  elseif provider_name == "openai" then
    -- Similar checks for OpenAI
    local api_key = os.getenv(provider_config.api_key_env)
    if not api_key then return false end

    local success = pcall(require, "openai")
    return success
  end

  return false
end

-- Get available providers
M.get_available_providers = function()
  local providers = {}

  for name, config in pairs(M.config.providers) do
    if config.enabled and M.is_provider_available(name) then
      table.insert(providers, name)
    end
  end

  return providers
end

-- Get provider config
M.get_provider_config = function(provider_name)
  return M.config.providers[provider_name] or {}
end

-- Set default provider
M.set_default_provider = function(provider_name)
  if M.is_provider_available(provider_name) then
    M.config.provider = provider_name
    vim.notify("✅ Default provider set to: " .. provider_name, vim.log.levels.INFO)
    return true
  else
    vim.notify("❌ Provider not available: " .. provider_name, vim.log.levels.ERROR)
    return false
  end
end

-- Show provider status
M.show_provider_status = function()
  local status_lines = {
    "╔══════════════════════════════════════════════════════════╗",
    "║                 Provider Status                          ║",
    "╠══════════════════════════════════════════════════════════╣",
  }

  for name, config in pairs(M.config.providers) do
    local enabled = config.enabled
    local available = M.is_provider_available(name)
    local status = enabled and (available and "✅ Available" or "❌ Not Available") or "🔴 Disabled"

    local line = string.format("║ %-10s : %-30s ║", name, status)
    table.insert(status_lines, line)
  end

  table.insert(status_lines, "╠══════════════════════════════════════════════════════════╣")
  table.insert(status_lines, string.format("║ Current Default: %-30s ║", M.config.provider))
  table.insert(status_lines, "╚══════════════════════════════════════════════════════════╝")

  local status_text = table.concat(status_lines, "\n")
  vim.notify(status_text, vim.log.levels.INFO)
end

return M
