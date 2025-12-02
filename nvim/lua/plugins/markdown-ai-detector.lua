-- markdown-ai-detector.lua
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
    has_database = false,
    has_git_operations = false,
    has_timeline_events = false,
    has_requirements = false,
    has_journey_steps = false,
    has_gantt_tasks = false,
    has_pie_data = false,
    has_quadrant_data = false,
    has_architecture = false,
    has_packets = false,
    has_kanban_tasks = false,
    has_mindmap_structure = false,
    has_sankey_flow = false,
    has_xy_data = false,
    has_block_structure = false,
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

  -- Detect use case patterns
  if code_content:match("User") or
      code_content:match("Admin") or
      code_content:match("Actor") or
      code_content:match("System") then
    analysis.has_use_cases = true
  end

  -- Detect database patterns
  if code_content:match("CREATE TABLE") or
      code_content:match("entity") or
      code_content:match("@Entity") or
      code_content:match("Schema") or
      code_content:match("model") then
    analysis.has_database = true
  end

  -- Detect Git operations
  if code_content:match("git") or
      code_content:match("commit") or
      code_content:match("branch") or
      code_content:match("merge") then
    analysis.has_git_operations = true
  end

  -- Detect timeline/dates
  if code_content:match("%d%d%d%d%-%d%d%-%d%d") or
      code_content:match("date") or
      code_content:match("timeline") then
    analysis.has_timeline_events = true
  end

  -- Detect requirements
  if code_content:match("requirement") or
      code_content:match("shall") or
      code_content:match("must") then
    analysis.has_requirements = true
  end

  -- Detect journey steps
  if code_content:match("step") or
      code_content:match("journey") or
      code_content:match("experience") then
    analysis.has_journey_steps = true
  end

  -- Detect gantt/project tasks
  if code_content:match("task") or
      code_content:match("milestone") or
      code_content:match("project") or
      code_content:match("schedule") then
    analysis.has_gantt_tasks = true
  end

  -- Detect pie chart data
  if code_content:match("percentage") or
      code_content:match("%%") or
      code_content:match("share") then
    analysis.has_pie_data = true
  end

  -- Detect quadrant data
  if code_content:match("priority") or
      code_content:match("urgency") or
      code_content:match("importance") then
    analysis.has_quadrant_data = true
  end

  -- Detect architecture patterns
  if code_content:match("service") or
      code_content:match("microservice") or
      code_content:match("component") or
      code_content:match("layer") then
    analysis.has_architecture = true
  end

  -- Detect packet/network
  if code_content:match("packet") or
      code_content:match("protocol") or
      code_content:match("network") then
    analysis.has_packets = true
  end

  -- Detect kanban
  if code_content:match("todo") or
      code_content:match("doing") or
      code_content:match("done") or
      code_content:match("backlog") then
    analysis.has_kanban_tasks = true
  end

  -- Detect mindmap
  if code_content:match("idea") or
      code_content:match("concept") or
      code_content:match("brainstorm") then
    analysis.has_mindmap_structure = true
  end

  -- Detect sankey/flow
  if code_content:match("flow") or
      code_content:match("transfer") or
      code_content:match("conversion") then
    analysis.has_sankey_flow = true
  end

  -- Detect XY data
  if code_content:match("x:") or
      code_content:match("y:") or
      code_content:match("coordinate") then
    analysis.has_xy_data = true
  end

  -- Detect block structure
  if code_content:match("block") or
      code_content:match("container") or
      code_content:match("group") then
    analysis.has_block_structure = true
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
    er_diagram = 0,
    user_journey = 0,
    gantt = 0,
    pie = 0,
    quadrant = 0,
    requirement = 0,
    gitgraph = 0,
    mindmap = 0,
    timeline = 0,
    zenuml = 0,
    sankey = 0,
    xy_chart = 0,
    block_diagram = 0,
    packet = 0,
    kanban = 0,
    architecture = 0,
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
  if analysis.has_state_machine then scores.state_diagram = scores.state_diagram + 3 end

  -- ER diagram scoring
  if analysis.has_database then scores.er_diagram = scores.er_diagram + 4 end

  -- User Journey scoring
  if analysis.has_journey_steps then scores.user_journey = scores.user_journey + 3 end
  if analysis.has_user_flow then scores.user_journey = scores.user_journey + 2 end

  -- Gantt scoring
  if analysis.has_gantt_tasks then scores.gantt = scores.gantt + 4 end

  -- Pie chart scoring
  if analysis.has_pie_data then scores.pie = scores.pie + 3 end

  -- Quadrant scoring
  if analysis.has_quadrant_data then scores.quadrant = scores.quadrant + 3 end

  -- Requirement scoring
  if analysis.has_requirements then scores.requirement = scores.requirement + 4 end

  -- GitGraph scoring
  if analysis.has_git_operations then scores.gitgraph = scores.gitgraph + 4 end

  -- Mindmap scoring
  if analysis.has_mindmap_structure then scores.mindmap = scores.mindmap + 3 end

  -- Timeline scoring
  if analysis.has_timeline_events then scores.timeline = scores.timeline + 3 end

  -- Sankey scoring
  if analysis.has_sankey_flow then scores.sankey = scores.sankey + 3 end

  -- XY Chart scoring
  if analysis.has_xy_data then scores.xy_chart = scores.xy_chart + 3 end

  -- Block diagram scoring
  if analysis.has_block_structure then scores.block_diagram = scores.block_diagram + 3 end

  -- Packet scoring
  if analysis.has_packets then scores.packet = scores.packet + 4 end

  -- Kanban scoring
  if analysis.has_kanban_tasks then scores.kanban = scores.kanban + 4 end

  -- Architecture scoring
  if analysis.has_architecture then scores.architecture = scores.architecture + 3 end

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
    user_journey = "User experience and satisfaction journey",
    gantt = "Project timeline and task scheduling",
    pie = "Proportional data distribution",
    quadrant = "Priority and classification matrix",
    requirement = "System requirements and relationships",
    gitgraph = "Git branching and commits visualization",
    c4_diagram = "C4 model architecture diagrams",
    mindmap = "Hierarchical ideas and concepts",
    timeline = "Chronological events visualization",
    zenuml = "UML sequence diagrams",
    sankey = "Flow and transfer visualization",
    xy_chart = "Data points on X-Y axes",
    block_diagram = "Block-based system architecture",
    packet = "Network packet structure",
    kanban = "Workflow board visualization",
    treemap = "Hierarchical data as nested rectangles",
    architecture = "System architecture components",
    radar = "Multi-variable comparison",
  }
  return descriptions[diagram_type] or "Unknown diagram type"
end

return M
