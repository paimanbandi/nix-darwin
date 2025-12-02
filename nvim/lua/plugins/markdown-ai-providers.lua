-- AI Provider management with automatic fallback
local M = {}

-- Provider configuration - FIXED COMMANDS
M.providers = {
  claude = {
    name = "Claude",
    type = "cli",
    command = "claude",
    check_cmd = "which claude > /dev/null 2>&1 && echo 'found' || echo ''",
    install_cmd = "npm install -g @anthropic-ai/claude-code",
    auth_cmd = "claude auth login",
    priority = 1,
  },
  opencode = {
    name = "OpenCode",
    type = "local",
    command = "opencode",
    check_cmd =
    "which opencode > /dev/null 2>&1 && echo 'found' || which opencode-cli > /dev/null 2>&1 && echo 'found' || echo ''",
    install_cmd = "pip install opencode-ai",
    model = "codellama",
    setup_info = "Fully open source, runs locally. No API key needed.",
    priority = 2,
  },
  ollama = {
    name = "Ollama",
    type = "local",
    command = "ollama",
    check_cmd = "which ollama > /dev/null 2>&1 && echo 'found' || echo ''",
    model = "codellama:7b",
    install_cmd = "curl -fsSL https://ollama.com/install.sh | sh",
    setup_info = "Local LLM. After install: ollama pull codellama:7b",
    priority = 3,
  },
  openai = {
    name = "OpenAI",
    type = "api",
    command = "curl",
    check_cmd = "which curl > /dev/null 2>&1 && echo 'found' || echo ''",
    api_key_env = "OPENAI_API_KEY",
    api_url = "https://api.openai.com/v1/chat/completions",
    model = "gpt-3.5-turbo",
    install_cmd = "curl is already installed. Get API key from: https://platform.openai.com/api-keys",
    priority = 4,
  },
}

-- Check if provider is available - FIXED VERSION
M.is_provider_available = function(provider_name)
  local provider = M.providers[provider_name]
  if not provider then
    return false, "Unknown provider: " .. provider_name
  end

  -- Check if command exists
  local result = vim.fn.system(provider.check_cmd)
  if not result or result:match("^%s*$") or not result:match("found") then
    return false, provider.command .. " not found. Install: " .. provider.install_cmd
  end

  -- Check API key for API-based providers
  if provider.type == "api" and provider.api_key_env then
    local api_key = os.getenv(provider.api_key_env)
    if not api_key or api_key == "" then
      return false, "API key not set: export " .. provider.api_key_env .. "='your-key'"
    end
  end

  -- Additional checks for local providers
  if provider_name == "ollama" then
    -- Check if model is available
    local model_check = vim.fn.system("ollama list | grep " .. provider.model)
    if not model_check or model_check == "" then
      return false, "Model not found. Run: ollama pull " .. provider.model
    end
  end

  return true, nil
end

-- Get provider preference
M.get_preferred_provider = function()
  return vim.g.mermaid_ai_provider or "opencode"
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

-- Get available providers
M.get_available_providers = function()
  local available = {}

  -- Check all providers
  for name, config in pairs(M.providers) do
    local is_available, _ = M.is_provider_available(name)
    if is_available then
      table.insert(available, name)
    end
  end

  -- Sort by priority
  table.sort(available, function(a, b)
    return M.providers[a].priority < M.providers[b].priority
  end)

  return available
end

-- Build command for different provider types - FIXED VERSION
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
      -- Try different command variations
      cmd = string.format("opencode -p %s", vim.fn.shellescape(temp_prompt))

      -- Alternative if that doesn't work
      local test = vim.fn.system("which opencode-cli 2>/dev/null")
      if test and test ~= "" then
        cmd = string.format("opencode-cli -p %s", vim.fn.shellescape(temp_prompt))
      end
    elseif provider_name == "ollama" then
      -- Ollama with explicit formatting
      local escaped = full_prompt:gsub("'", "'\"'\"'")
      cmd = string.format("ollama run %s --format json '%s'", provider.model, escaped)
    end
  elseif provider.type == "api" then
    -- API-based (OpenAI, etc)
    local api_key = os.getenv(provider.api_key_env)
    if not api_key then
      return nil, temp_prompt, "API key not found"
    end

    local temp_json = vim.fn.tempname() .. ".json"
    local json_content = string.format([[
{
  "model": "%s",
  "messages": [
    {
      "role": "system",
      "content": "%s"
    },
    {
      "role": "user",
      "content": "%s"
    }
  ],
  "temperature": 0.3,
  "max_tokens": 4096
}]],
      provider.model,
      "You are a Mermaid diagram generator. Output ONLY valid Mermaid syntax in ```mermaid code blocks.",
      full_prompt:gsub('\\', '\\\\'):gsub('"', '\\"'):gsub('\n', '\\n'))

    local json_file = io.open(temp_json, "w")
    if json_file then
      json_file:write(json_content)
      json_file:close()
    end

    cmd = string.format(
      'curl -s -X POST "%s" -H "Content-Type: application/json" -H "Authorization: Bearer %s" -d @%s',
      provider.api_url,
      api_key,
      vim.fn.shellescape(temp_json)
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
      -- Try to extract JSON from response
      local json_match = raw_response:match("({.*})")
      if json_match then
        ok, json = pcall(vim.fn.json_decode, json_match)
      end
    end

    if ok and json and json.choices and json.choices[1] and json.choices[1].message then
      return json.choices[1].message.content, nil
    end

    if ok and json and json.error then
      return nil, json.error.message or "API error"
    end

    -- If not JSON, return raw response
    return raw_response, nil
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
      stderr_buffered = true,
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
          vim.notify("Provider error: " .. err, vim.log.levels.WARN)
          has_error = true
        end
      end,
      on_exit = function(_, exit_code)
        -- Clean up temp files
        if temp_file and vim.fn.filereadable(temp_file) == 1 then
          os.remove(temp_file)
        end

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
              callbacks.on_error("All providers failed: " .. stderr_msg)
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

  -- Show in floating window
  local lines = { "=== Select AI Provider ===", "" }

  for i, name in ipairs(available) do
    local provider = M.providers[name]
    lines[#lines + 1] = string.format("[%d] %s", i, provider.name)
  end

  lines[#lines + 1] = "[0] Cancel"
  lines[#lines + 1] = ""

  local buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)

  local width = 40
  local height = #lines + 2
  local win = vim.api.nvim_open_win(buf, true, {
    relative = "editor",
    width = width,
    height = height,
    col = (vim.o.columns - width) / 2,
    row = (vim.o.lines - height) / 2,
    style = "minimal",
    border = "rounded",
    title = " Select Provider ",
    title_pos = "center",
  })

  -- Close function
  local function close_win()
    if vim.api.nvim_win_is_valid(win) then
      vim.api.nvim_win_close(win, true)
    end
    if vim.api.nvim_buf_is_valid(buf) then
      vim.api.nvim_buf_delete(buf, { force = true })
    end
  end

  -- Set keymaps for each number
  for i = 1, #available do
    vim.api.nvim_buf_set_keymap(buf, 'n', tostring(i), '', {
      noremap = true,
      callback = function()
        local selected = available[i]
        close_win()
        if callback then callback(selected) end
      end
    })
  end

  vim.api.nvim_buf_set_keymap(buf, 'n', '0', '', {
    noremap = true,
    callback = function()
      close_win()
      if callback then callback(nil) end
    end
  })

  vim.api.nvim_buf_set_keymap(buf, 'n', '<Esc>', '', {
    noremap = true,
    callback = function()
      close_win()
      if callback then callback(nil) end
    end
  })

  vim.api.nvim_buf_set_keymap(buf, 'n', 'q', '', {
    noremap = true,
    callback = function()
      close_win()
      if callback then callback(nil) end
    end
  })
end
