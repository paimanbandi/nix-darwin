-- markdown-ai-providers.lua
-- Provider-specific implementations

local M = {}
local config = require("plugins.markdown-ai-config")
local core = require("plugins.markdown-ai-core")

-- ✅ PERUBAHAN: call_claude pakai REST API langsung (curl), bukan Claude CLI
M.call_claude = function(prompt, output_file, title, on_complete)
  local api_key = vim.fn.getenv("ANTHROPIC_API_KEY")

  if not api_key or api_key == "" then
    vim.notify("❌ ANTHROPIC_API_KEY not set", vim.log.levels.ERROR)
    if on_complete then on_complete(false) end
    return
  end

  vim.notify("🤖 Generating with Claude API...", vim.log.levels.INFO)

  -- Tulis prompt ke temp file untuk hindari shell escaping issues
  local temp_body = vim.fn.tempname() .. "_body.json"
  local response_file = vim.fn.tempname() .. "_response.json"

  -- Build JSON body via Lua (lebih aman dari string format)
  local body = vim.json.encode({
    model = "claude-opus-4-5",
    max_tokens = 4000,
    system =
    "You are an expert Mermaid diagram generator. Always respond with complete, valid Mermaid code in a ```mermaid code block. Include proper syntax and styling. Don't add explanations outside the code block.",
    messages = {
      { role = "user", content = prompt }
    }
  })

  local f = io.open(temp_body, "w")
  if not f then
    vim.notify("❌ Failed to create temp file", vim.log.levels.ERROR)
    if on_complete then on_complete(false) end
    return
  end
  f:write(body)
  f:close()

  local cmd = {
    "curl", "-s", "-X", "POST",
    "https://api.anthropic.com/v1/messages",
    "-H", "x-api-key: " .. api_key,
    "-H", "anthropic-version: 2023-06-01",
    "-H", "content-type: application/json",
    "-d", "@" .. temp_body,
    "-o", response_file,
  }

  vim.fn.jobstart(cmd, {
    on_exit = function(_, exit_code)
      pcall(os.remove, temp_body)

      if exit_code ~= 0 then
        vim.notify("❌ Claude API request failed (curl error)", vim.log.levels.ERROR)
        if on_complete then on_complete(false) end
        return
      end

      local rf = io.open(response_file, "r")
      if not rf then
        vim.notify("❌ Failed to read Claude response file", vim.log.levels.ERROR)
        if on_complete then on_complete(false) end
        return
      end

      local raw = rf:read("*a")
      rf:close()
      pcall(os.remove, response_file)

      -- Parse response
      local ok, parsed = pcall(vim.json.decode, raw)
      if not ok or not parsed then
        vim.notify("❌ Failed to parse Claude response JSON", vim.log.levels.ERROR)
        if on_complete then on_complete(false) end
        return
      end

      -- Cek error dari API
      if parsed.error then
        vim.notify("❌ Claude API error: " .. (parsed.error.message or "unknown"), vim.log.levels.ERROR)
        if on_complete then on_complete(false) end
        return
      end

      -- Ambil text dari response
      local text = parsed.content
          and parsed.content[1]
          and parsed.content[1].text

      if not text then
        vim.notify("❌ No text in Claude response", vim.log.levels.ERROR)
        if on_complete then on_complete(false) end
        return
      end

      local mermaid_code = core.extract_mermaid_code(text)
      if not mermaid_code then
        vim.notify("❌ No valid Mermaid code in Claude response", vim.log.levels.ERROR)
        if on_complete then on_complete(false) end
        return
      end

      if on_complete then
        on_complete(true, mermaid_code, "Claude")
      end
    end
  })
end

-- Call DeepSeek API
M.call_deepseek = function(prompt, output_file, title, on_complete)
  local openai_client = core.init_openai_client("deepseek")
  if not openai_client then
    vim.notify("❌ DeepSeek client not available", vim.log.levels.ERROR)
    if on_complete then on_complete(false) end
    return
  end

  vim.notify("🤖 Generating with DeepSeek...", vim.log.levels.INFO)

  local messages = {
    {
      role = "system",
      content =
      "You are an expert Mermaid diagram generator. Always respond with complete, valid Mermaid code in a ```mermaid code block. Include proper syntax and styling. Don't add explanations outside the code block."
    },
    {
      role = "user",
      content = prompt
    }
  }

  local provider_config = config.get_provider_config("deepseek")

  vim.schedule(function()
    local co = coroutine.create(function()
      local success, response = pcall(function()
        return openai_client.chat.completions.create({
          model = provider_config.model or "deepseek-chat",
          messages = messages,
          temperature = 0.3,
          max_tokens = 4000,
        })
      end)

      if not success then
        vim.notify("❌ DeepSeek API Error: " .. tostring(response), vim.log.levels.ERROR)
        if on_complete then on_complete(false) end
        return
      end

      if response and response.choices and #response.choices > 0 then
        local response_text = response.choices[1].message.content
        local mermaid_code = core.extract_mermaid_code(response_text)

        if not mermaid_code then
          vim.notify("❌ No valid Mermaid code in DeepSeek response", vim.log.levels.ERROR)
          if on_complete then on_complete(false) end
          return
        end

        if on_complete then
          on_complete(true, mermaid_code, "DeepSeek")
        end
      else
        vim.notify("❌ Invalid response from DeepSeek", vim.log.levels.ERROR)
        if on_complete then on_complete(false) end
      end
    end)

    coroutine.resume(co)
  end)
end

-- Call OpenAI
M.call_openai = function(prompt, output_file, title, on_complete)
  local openai_client = core.init_openai_client("openai")
  if not openai_client then
    vim.notify("❌ OpenAI client not available", vim.log.levels.ERROR)
    if on_complete then on_complete(false) end
    return
  end

  vim.notify("🤖 Generating with OpenAI...", vim.log.levels.INFO)

  local messages = {
    {
      role = "system",
      content =
      "You are an expert Mermaid diagram generator. Always respond with complete, valid Mermaid code in a ```mermaid code block. Include proper syntax and styling. Don't add explanations outside the code block."
    },
    {
      role = "user",
      content = prompt
    }
  }

  local provider_config = config.get_provider_config("openai")

  vim.schedule(function()
    local co = coroutine.create(function()
      local success, response = pcall(function()
        return openai_client.chat.completions.create({
          model = provider_config.model or "gpt-4",
          messages = messages,
          temperature = 0.3,
          max_tokens = 4000,
        })
      end)

      if not success then
        vim.notify("❌ OpenAI API Error: " .. tostring(response), vim.log.levels.ERROR)
        if on_complete then on_complete(false) end
        return
      end

      if response and response.choices and #response.choices > 0 then
        local response_text = response.choices[1].message.content
        local mermaid_code = core.extract_mermaid_code(response_text)

        if not mermaid_code then
          vim.notify("❌ No valid Mermaid code in OpenAI response", vim.log.levels.ERROR)
          if on_complete then on_complete(false) end
          return
        end

        if on_complete then
          on_complete(true, mermaid_code, "OpenAI")
        end
      else
        vim.notify("❌ Invalid response from OpenAI", vim.log.levels.ERROR)
        if on_complete then on_complete(false) end
      end
    end)

    coroutine.resume(co)
  end)
end

-- Call provider based on name
M.call_provider = function(provider_name, prompt, output_file, title, on_complete)
  if provider_name == "claude" then
    M.call_claude(prompt, output_file, title, on_complete)
  elseif provider_name == "deepseek" then
    M.call_deepseek(prompt, output_file, title, on_complete)
  elseif provider_name == "openai" then
    M.call_openai(prompt, output_file, title, on_complete)
  else
    vim.notify("❌ Provider not supported: " .. provider_name, vim.log.levels.ERROR)
    if on_complete then on_complete(false) end
  end
end

-- Show provider selection menu
M.select_provider = function(callback)
  local available_providers = config.get_available_providers()

  if #available_providers == 0 then
    vim.notify("❌ No AI providers available. Please configure at least one.", vim.log.levels.ERROR)
    return nil
  end

  local menu_items = {}
  local menu_text = "Select AI Provider:\n\n"

  for i, provider in ipairs(available_providers) do
    local display_name = provider:gsub("^%l", string.upper)
    menu_text = menu_text .. string.format("&%d. %s\n", i, display_name)
    table.insert(menu_items, provider)
  end

  menu_text = menu_text .. string.format("&%d. Cancel", #available_providers + 1)

  local choice = vim.fn.confirm(menu_text, "", #available_providers + 1)

  if choice == 0 or choice > #available_providers then
    return nil
  end

  local selected_provider = menu_items[choice]

  if callback then
    callback(selected_provider)
  end

  return selected_provider
end

return M
