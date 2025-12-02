-- AI Provider management with automatic fallback
local M = {}

-- Provider configuration
M.providers = {
  claude = {
    name = "Claude",
    type = "cli",
    command = "claude",
    check_cmd = "which claude",
    install_cmd = "npm install -g @anthropic-ai/claude-code",
    auth_cmd = "claude auth login",
    priority = 1,
  },
  opencode = {
    name = "OpenCode",
    type = "local",
    command = "opencode",
    check_cmd = "which opencode",
    install_cmd = "pip install opencode-ai",
    setup_info = "Fully open source, runs locally. No API key needed.",
    priority = 2,
  },
  ollama = {
    name = "Ollama",
    type = "local",
    command = "ollama",
    check_cmd = "which ollama",
    model = "codellama",
    install_cmd = "curl -fsSL https://ollama.com/install.sh | sh",
    setup_info = "Local LLM. After install: ollama pull codellama",
    priority = 3,
  },
  openai = {
    name = "OpenAI",
    type = "api",
    command = "curl",
    check_cmd = "which curl",
    api_key_env = "OPENAI_API_KEY",
    api_url = "https://api.openai.com/v1/chat/completions",
    model = "gpt-4",
    install_cmd = "curl is already installed. Get API key from: https://platform.openai.com/api-keys",
    priority = 4,
  },
}

-- Check if provider is available
M.is_provider_available = function(provider_name)
  local provider = M.providers[provider_name]
  if not provider then
    return false, "Unknown provider: " .. provider_name
  end

  -- Check if command exists
  local path = vim.fn.system(provider.check_cmd):gsub("\n", "")
  if path == "" then
    return false, provider.command .. " not found. Install: " .. provider.install_cmd
  end

  -- Check API key for API-based providers
  if provider.type == "api" and provider.api_key_env then
    local api_key = os.getenv(provider.api_key_env)
    if not api_key or api_key == "" then
      return false, "API key not set: export " .. provider.api_key_env .. "='your-key'"
    end
  end

  return true, nil
end

-- Get provider preference
M.get_preferred_provider = function()
  local preference = vim.g.mermaid_ai_provider or "claude"
  return preference
end

-- Set provider preference
M.set_preferred_provider = function(provider_name)
  if not M.providers[provider_name] then
    vim.notify("Unknown provider: " .. provider_name, vim.log.levels.ERROR)
    return false
  end

  vim.g.mermaid_ai_provider = provider_name
  vim.notify("Default provider set to: " .. M.providers[provider_name].name, vim.log.levels.INFO)
  return true
end

-- Get available providers in priority order
M.get_available_providers = function()
  local available = {}

  -- Check preferred provider first
  local preferred = M.get_preferred_provider()
  local is_available, _ = M.is_provider_available(preferred)
  if is_available then
    table.insert(available, preferred)
  end

  -- Check other providers by priority
  local sorted_providers = {}
  for name, config in pairs(M.providers) do
    if name ~= preferred then
      table.insert(sorted_providers, { name = name, priority = config.priority })
    end
  end

  table.sort(sorted_providers, function(a, b) return a.priority < b.priority end)

  for _, item in ipairs(sorted_providers) do
    is_available, _ = M.is_provider_available(item.name)
    if is_available then
      table.insert(available, item.name)
    end
  end

  return available
end

-- Build command for different provider types
M.build_command = function(provider_name, prompt)
  local provider = M.providers[provider_name]
  local prompts_module = require("plugins.markdown-ai-prompts")

  -- Prepend system message to prompt
  local full_prompt = prompts_module.get_system_message() .. "\n\n" .. prompt

  -- Create temp prompt file
  local temp_prompt = vim.fn.tempname() .. "_prompt.txt"
  local prompt_file = io.open(temp_prompt, "w")

  if not prompt_file then
    return nil, nil, "Failed to create temp file"
  end

  prompt_file:write(full_prompt)
  prompt_file:close()

  local cmd

  if provider.type == "cli" then
    -- Claude CLI
    cmd = string.format("cat %s | claude", vim.fn.shellescape(temp_prompt))
  elseif provider.type == "local" then
    if provider_name == "opencode" then
      -- OpenCode: Use stdin instead of --prompt-file
      cmd = string.format("cat %s | opencode", vim.fn.shellescape(temp_prompt))
    elseif provider_name == "ollama" then
      -- Ollama local LLM
      local escaped = full_prompt:gsub("'", "'\\''")
      cmd = string.format("ollama run %s '%s'", provider.model, escaped)
    end
  elseif provider.type == "api" then
    -- API-based (OpenAI, etc)
    local api_key = os.getenv(provider.api_key_env)
    if not api_key then
      return nil, temp_prompt, "API key not found"
    end

    -- Escape for JSON
    local escaped_prompt = full_prompt:gsub('\\', '\\\\'):gsub('"', '\\"'):gsub('\n', '\\n')

    local json_payload = string.format([[{
  "model": "%s",
  "messages": [
    {
      "role": "system",
      "content": "You are a Mermaid diagram code generator. Output ONLY valid Mermaid syntax in code blocks. NO explanations."
    },
    {
      "role": "user",
      "content": "%s"
    }
  ],
  "temperature": 0.3,
  "max_tokens": 4096
}]], provider.model, escaped_prompt)

    local temp_json = vim.fn.tempname() .. ".json"
    local json_file = io.open(temp_json, "w")
    if json_file then
      json_file:write(json_payload)
      json_file:close()
    end

    cmd = string.format(
      "curl -s -X POST %s -H 'Content-Type: application/json' -H 'Authorization: Bearer %s' -d @%s",
      provider.api_url,
      api_key,
      temp_json
    )

    return cmd, temp_json, nil
  end

  return cmd, temp_prompt, nil
end

-- Extract response from different provider types
M.extract_response = function(provider_name, raw_response)
  local provider = M.providers[provider_name]

  if provider.type == "api" then
    -- Parse JSON for API responses
    local ok, json = pcall(vim.fn.json_decode, raw_response)

    if not ok then
      return nil, "Failed to parse JSON response"
    end

    if json.choices and json.choices[1] and json.choices[1].message then
      return json.choices[1].message.content, nil
    end

    if json.error then
      return nil, json.error.message or "API error"
    end

    return nil, "Unexpected response format"
  end

  -- For CLI and local providers, return raw response
  return raw_response, nil
end

-- Call provider with automatic fallback
M.call_provider = function(prompt, callbacks)
  local available = M.get_available_providers()

  if #available == 0 then
    vim.notify("No AI providers available", vim.log.levels.ERROR)
    vim.notify("Install: Claude, OpenCode, or Ollama", vim.log.levels.INFO)
    if callbacks.on_error then
      callbacks.on_error("No providers available")
    end
    return
  end

  local function try_provider(provider_name, fallback_list)
    local provider = M.providers[provider_name]

    vim.notify("Using " .. provider.name .. " to generate diagram...", vim.log.levels.INFO)

    local cmd, temp_file, error_msg = M.build_command(provider_name, prompt)

    if not cmd then
      vim.notify("Failed to build command: " .. (error_msg or "unknown error"), vim.log.levels.ERROR)

      -- Try fallback
      if #fallback_list > 0 then
        local next_provider = table.remove(fallback_list, 1)
        vim.notify("Trying " .. M.providers[next_provider].name, vim.log.levels.INFO)
        try_provider(next_provider, fallback_list)
      end
      return
    end

    local response_buffer = {}
    local has_error = false
    local stderr_msg = ""

    vim.fn.jobstart(cmd, {
      stdout_buffered = true,
      on_stdout = function(_, data)
        if data then
          for _, line in ipairs(data) do
            if line ~= "" then
              table.insert(response_buffer, line)
            end
          end
        end
      end,
      on_stderr = function(_, data)
        if data and #data > 0 then
          local err = table.concat(data, "\n")
          stderr_msg = stderr_msg .. err

          -- Check for common errors
          if err:match("rate limit") or
              err:match("quota") or
              err:match("429") or
              err:match("exceeded") or
              err:match("not found") or
              err:match("connection") then
            has_error = true
            vim.notify(provider.name .. " error detected. Trying fallback...", vim.log.levels.WARN)
          end
        end
      end,
      on_exit = function(_, exit_code)
        pcall(os.remove, temp_file)

        local raw_response = table.concat(response_buffer, "\n")

        -- Extract response based on provider type
        local response, extract_err = M.extract_response(provider_name, raw_response)

        if extract_err then
          has_error = true
          stderr_msg = extract_err
        end

        -- Check if we should fallback
        if exit_code ~= 0 or has_error or not response or response == "" or response:match("^%s*$") then
          vim.notify(provider.name .. " failed: " .. stderr_msg, vim.log.levels.WARN)

          -- Try next provider
          if #fallback_list > 0 then
            local next_provider = table.remove(fallback_list, 1)
            vim.notify("Falling back to " .. M.providers[next_provider].name, vim.log.levels.INFO)
            try_provider(next_provider, fallback_list)
          else
            vim.notify("All providers failed", vim.log.levels.ERROR)
            if callbacks.on_error then
              callbacks.on_error("All providers failed")
            end
          end
          return
        end

        -- Success
        if callbacks.on_success then
          callbacks.on_success(response, provider_name)
        end
      end
    })
  end

  -- Start with first available, rest as fallback
  local primary = table.remove(available, 1)
  try_provider(primary, available)
end

-- Interactive provider selection with callback
M.select_provider_async = function(callback)
  local available = M.get_available_providers()

  if #available == 0 then
    vim.notify("No AI providers available", vim.log.levels.ERROR)
    if callback then callback(nil) end
    return
  end

  -- Clear and show menu
  vim.cmd("redraw")
  print("\n=== Select AI Provider ===\n")

  for i, name in ipairs(available) do
    local provider = M.providers[name]
    local type_label = ""
    if provider.type == "local" then
      type_label = " (Local, Free)"
    elseif provider.type == "api" then
      type_label = " (API, Paid)"
    elseif provider.type == "cli" then
      type_label = " (Cloud)"
    end

    print(string.format("[%d] %s%s", i, provider.name, type_label))
  end

  print("[0] Cancel\n")

  -- Get input with proper async handling
  vim.ui.input(
    { prompt = string.format("Enter number (1-%d): ", #available) },
    function(input)
      vim.cmd("redraw")

      if not input then
        vim.notify("Selection cancelled", vim.log.levels.INFO)
        if callback then callback(nil) end
        return
      end

      local choice = tonumber(input)

      if not choice or choice == 0 then
        vim.notify("Selection cancelled", vim.log.levels.INFO)
        if callback then callback(nil) end
        return
      end

      if choice < 1 or choice > #available then
        vim.notify("Invalid selection: " .. choice, vim.log.levels.ERROR)
        if callback then callback(nil) end
        return
      end

      local selected = available[choice]
      vim.notify("Selected: " .. M.providers[selected].name, vim.log.levels.INFO)

      if callback then callback(selected) end
    end
  )
end

-- Keep synchronous version for backward compatibility
M.select_provider = function()
  local available = M.get_available_providers()

  if #available == 0 then
    vim.notify("No AI providers available", vim.log.levels.ERROR)
    return nil
  end

  vim.cmd("redraw")
  print("\n=== Select AI Provider ===\n")

  for i, name in ipairs(available) do
    local provider = M.providers[name]
    local type_label = ""
    if provider.type == "local" then
      type_label = " (Local, Free)"
    elseif provider.type == "api" then
      type_label = " (API, Paid)"
    end

    print(string.format("[%d] %s%s", i, provider.name, type_label))
  end

  print("[0] Cancel\n")

  local input = vim.fn.input(string.format("Enter number (1-%d): ", #available))
  vim.cmd("redraw")

  local choice = tonumber(input)

  if not choice or choice == 0 or choice < 1 or choice > #available then
    return nil
  end

  return available[choice]
end

-- Show provider status
M.show_status = function()
  local lines = { "AI Provider Status:", "" }

  local preferred = M.get_preferred_provider()
  lines[#lines + 1] = "Preferred: " .. M.providers[preferred].name
  lines[#lines + 1] = ""

  lines[#lines + 1] = "Available Providers:"

  -- Sort by priority
  local sorted = {}
  for name, config in pairs(M.providers) do
    table.insert(sorted, { name = name, config = config })
  end
  table.sort(sorted, function(a, b) return a.config.priority < b.config.priority end)

  for _, item in ipairs(sorted) do
    local name = item.name
    local provider = item.config
    local is_available, error_msg = M.is_provider_available(name)

    local status_icon = is_available and "✓" or "✗"
    local type_label = ""
    if provider.type == "local" then
      type_label = " [Local, Free]"
    elseif provider.type == "api" then
      type_label = " [API, Paid]"
    elseif provider.type == "cli" then
      type_label = " [CLI]"
    end

    local line = string.format("%s %s%s: %s",
      status_icon,
      provider.name,
      type_label,
      is_available and "Available" or "Not installed"
    )
    lines[#lines + 1] = line

    if error_msg then
      lines[#lines + 1] = "  " .. error_msg
    end

    if provider.setup_info and not is_available then
      lines[#lines + 1] = "  " .. provider.setup_info
    end
  end

  lines[#lines + 1] = ""
  lines[#lines + 1] = "Automatic Fallback Chain:"
  local available = M.get_available_providers()
  if #available > 0 then
    for i, name in ipairs(available) do
      lines[#lines + 1] = string.format("%d. %s", i, M.providers[name].name)
    end
  else
    lines[#lines + 1] = "No providers configured!"
    lines[#lines + 1] = ""
    lines[#lines + 1] = "Quick Setup (recommended):"
    lines[#lines + 1] = "1. OpenCode: pip install opencode-ai (FREE, LOCAL)"
    lines[#lines + 1] = "2. Ollama: curl -fsSL https://ollama.com/install.sh | sh"
    lines[#lines + 1] = "3. Claude: npm install -g @anthropic-ai/claude-code"
  end

  -- Create floating window
  local buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)

  local width = 75
  local height = math.min(#lines + 2, vim.o.lines - 4)
  local win = vim.api.nvim_open_win(buf, true, {
    relative = "editor",
    width = width,
    height = height,
    col = (vim.o.columns - width) / 2,
    row = (vim.o.lines - height) / 2,
    style = "minimal",
    border = "rounded",
    title = " AI Providers ",
    title_pos = "center",
  })

  vim.api.nvim_buf_set_keymap(buf, 'n', 'q', ':q<CR>', { noremap = true, silent = true })
  vim.api.nvim_buf_set_keymap(buf, 'n', '<Esc>', ':q<CR>', { noremap = true, silent = true })

  vim.api.nvim_buf_set_option(buf, 'modifiable', false)
  vim.api.nvim_buf_set_option(buf, 'bufhidden', 'wipe')
end

return M
