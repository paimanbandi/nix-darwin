-- Auto-detect best diagram type based on code content
local M = {}

-- Analyze code to determine best diagram type
M.detect_diagram_type = function(code_content, filetype)
  local analysis = {
    has_classes = false,
    has_interfaces = false,
    has_async = false,
    has_api_calls = false,
    has_user_flow = false,
    has_state_machine = false,
    has_inheritance = false,
    has_sequence_flow = false,
    has_use_cases = false,
  }

  -- Detect classes and interfaces
  if code_content:match("class%s+%w+") or
      code_content:match("interface%s+%w+") or
      code_content:match("struct%s+%w+") then
    analysis.has_classes = true
  end

  -- Detect inheritance/extends
  if code_content:match("extends%s+%w+") or
      code_content:match("implements%s+%w+") or
      code_content:match(":%s*%w+") then
    analysis.has_inheritance = true
  end

  -- Detect async operations
  if code_content:match("async%s+") or
      code_content:match("await%s+") or
      code_content:match("Promise") or
      code_content:match("%.then%(") or
      code_content:match("callback") then
    analysis.has_async = true
  end

  -- Detect API calls
  if code_content:match("fetch%(") or
      code_content:match("axios") or
      code_content:match("api%.") or
      code_content:match("http%.") or
      code_content:match("request%(") then
    analysis.has_api_calls = true
  end

  -- Detect user interactions
  if code_content:match("onClick") or
      code_content:match("onSubmit") or
      code_content:match("handleClick") or
      code_content:match("handle%w+") or
      code_content:match("button") or
      code_content:match("form") then
    analysis.has_user_flow = true
  end

  -- Detect state machine patterns
  if code_content:match("useState") or
      code_content:match("state%s*=") or
      code_content:match("setState") or
      code_content:match("reducer") then
    analysis.has_state_machine = true
  end

  -- Detect sequence/method calls
  if code_content:match("%.%w+%(") then
    local method_calls = 0
    for _ in code_content:gmatch("%.%w+%(") do
      method_calls = method_calls + 1
    end
    if method_calls > 10 then
      analysis.has_sequence_flow = true
    end
  end

  -- Detect use case patterns (actor-system interactions)
  if code_content:match("User") or
      code_content:match("Admin") or
      code_content:match("Actor") or
      code_content:match("System") then
    analysis.has_use_cases = true
  end

  return analysis
end

-- Recommend diagram type based on analysis
M.recommend_diagram_type = function(analysis)
  local scores = {
    flowchart = 0,
    sequence = 0,
    class_diagram = 0,
    state_diagram = 0,
  }

  -- Flowchart scoring
  if analysis.has_user_flow then scores.flowchart = scores.flowchart + 3 end
  if analysis.has_state_machine then scores.flowchart = scores.flowchart + 2 end
  if analysis.has_async then scores.flowchart = scores.flowchart + 1 end

  -- Sequence diagram scoring
  if analysis.has_api_calls then scores.sequence = scores.sequence + 3 end
  if analysis.has_async then scores.sequence = scores.sequence + 2 end
  if analysis.has_sequence_flow then scores.sequence = scores.sequence + 2 end

  -- Class diagram scoring
  if analysis.has_classes then scores.class_diagram = scores.class_diagram + 3 end
  if analysis.has_inheritance then scores.class_diagram = scores.class_diagram + 3 end
  if analysis.has_interfaces then scores.class_diagram = scores.class_diagram + 2 end

  -- State diagram scoring
  if analysis.has_state_machine then scores.state_diagram = scores.state_diagram + 2 end

  -- Find highest score
  local max_score = 0
  local recommended = "flowchart"

  for diagram_type, score in pairs(scores) do
    if score > max_score then
      max_score = score
      recommended = diagram_type
    end
  end

  -- Default to flowchart if no clear winner
  if max_score == 0 then
    recommended = "flowchart"
  end

  return recommended, scores
end

-- Get user-friendly description
M.get_diagram_description = function(diagram_type)
  local descriptions = {
    flowchart = "Process flow with decisions and actions",
    sequence = "Time-based interactions between components",
    class_diagram = "Object-oriented structure and relationships",
    state_diagram = "State transitions and events",
    er_diagram = "Database entity relationships",
  }
  return descriptions[diagram_type] or "Unknown diagram type"
end

return M
