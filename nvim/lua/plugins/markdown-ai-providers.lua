-- markdown-ai-providers.lua
-- Provider-specific implementations

local M = {}
local config = require("plugins.markdown-ai-config")
local core = require("plugins.markdown-ai-core")

-- Call Claude CLI
M.call_claude = function(prompt, output_file, title, on_complete)
  local claude_path = vim.fn.system("which claude"):gsub("\n", "")

  if claude_path == "" then
    vim.notify("Claude CLI not found. Install: npm install -g @anthropic-ai/claude-cli", vim.log.levels.ERROR)
    if on_complete then on_complete(false) end
    return
  end

  local temp_prompt = vim.fn.tempname() .. "_prompt.txt"
  local prompt_file = io.open(temp_prompt, "w")

  if not prompt_file then
    vim.notify("Failed to create temp file", vim.log.levels.ERROR)
    if on_complete then on_complete(false) end
    return
  end

  prompt_file:write(prompt)
  prompt_file:close()

  vim.notify("🤖 Generating with Claude...", vim.log.levels.INFO)

  local cmd = string.format("cat %s | claude", vim.fn.shellescape(temp_prompt))
  local response_buffer = {}

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
    on_exit = function(_, exit_code)
      pcall(os.remove, temp_prompt)

      if exit_code ~= 0 then
        vim.notify("❌ Claude generation failed", vim.log.levels.ERROR)
        if on_complete then on_complete(false) end
        return
      end

      local response = table.concat(response_buffer, "\n")
      local mermaid_code = core.extract_mermaid_code(response)

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

  -- Use async call
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

  -- Build menu
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
