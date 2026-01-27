-- markdown-ai-prompts.lua
-- Mermaid diagram prompts for all 19 diagram types
-- Optimized for Ollama code analysis models
local M = {}

-- ========================================
-- 🎨 COLOR PALETTE
-- ========================================
M.colors = {
  primary = "#1e40af",
  secondary = "#0891b2",
  success = "#059669",
  warning = "#d97706",
  danger = "#dc2626",
  info = "#6366f1",
  neutral = "#64748b",
  primary_light = "#dbeafe",
  secondary_light = "#cffafe",
  success_light = "#d1fae5",
  warning_light = "#fed7aa",
  danger_light = "#fee2e2",
  info_light = "#e0e7ff",
  neutral_light = "#f1f5f9",
}

-- ========================================
-- 🎯 STYLE DEFINITIONS
-- ========================================

M.get_flowchart_styles = function()
  return string.format([[
    classDef startEnd fill:%s,stroke:%s,stroke-width:3px,color:#fff
    classDef process fill:%s,stroke:%s,stroke-width:2px,color:#000
    classDef decision fill:%s,stroke:%s,stroke-width:2px,color:#000
    classDef api fill:%s,stroke:%s,stroke-width:2px,color:#000
    classDef success fill:%s,stroke:%s,stroke-width:2px,color:#000
    classDef error fill:%s,stroke:%s,stroke-width:2px,color:#fff
    classDef userAction fill:%s,stroke:%s,stroke-width:2px,color:#000]],
    M.colors.primary, M.colors.primary,
    M.colors.primary_light, M.colors.primary,
    M.colors.warning_light, M.colors.warning,
    M.colors.secondary_light, M.colors.secondary,
    M.colors.success_light, M.colors.success,
    M.colors.danger, M.colors.danger,
    M.colors.info_light, M.colors.info
  )
end

M.get_class_diagram_styles = function()
  return [[
    classDef primary fill:#dbeafe,stroke:#1e40af,stroke-width:2px
    classDef secondary fill:#cffafe,stroke:#0891b2,stroke-width:2px
    classDef interface fill:#e0e7ff,stroke:#6366f1,stroke-width:2px,stroke-dasharray: 5 5]]
end

-- ========================================
-- 🚀 CORE DIAGRAMS (Top 5 most used)
-- ========================================

-- 1️⃣ FLOWCHART
M.build_flowchart_prompt = function(filetype, code_content, complexity)
  local max_nodes = complexity == "simple" and 30 or (complexity == "moderate" and 50 or 80)

  return string.format([[🔍 Analyze this %s code and create a Mermaid flowchart.

📋 OUTPUT RULES:
1. ✅ Start with: ```mermaid
2. ✅ Second line: flowchart TD
3. ✅ Format: NodeID[Label]:::class --> NextID[Label]:::class
4. ⚠️ CRITICAL: NO EMOJI in node labels (ASCII only)
5. ✅ Apply styles at END
6. ✅ End with: ```

💡 EXAMPLE (correct format):
```mermaid
flowchart TD
    Start([Begin]):::startEnd
    Process[Action]:::process
    Decision{Check?}:::decision

    Start --> Process
    Process --> Decision
    Decision -->|Yes| Success[Done]:::success
    Decision -->|No| Error[Failed]:::error

%s
```

⚙️ CONSTRAINTS:
- Max nodes: %d
- Keep labels SHORT (max 25 chars)
- NO quotes in labels
- NO special characters (emoji, unicode)
- Use ASCII only

📝 Code (%s):
%s

🎯 OUTPUT ONLY mermaid code:]], filetype, M.get_flowchart_styles(), max_nodes, filetype, code_content:sub(1, 2500))
end

-- 2️⃣ SEQUENCE DIAGRAM
M.build_sequence_prompt = function(filetype, code_content)
  return string.format([[🔍 Analyze this %s code and create a Mermaid sequence diagram.

🚨 CRITICAL: Generate COMPLETE diagram with ALL interactions!

⚡ ARROW RULES (CRITICAL):
- ✅ Use ->> for calls (single dash)
- ✅ Use -->> for returns (double dash)
- ❌ NEVER use 3+ dashes (--->> is INVALID)

📋 OUTPUT RULES:
1. ✅ Start with: ```mermaid
2. ✅ Second line: sequenceDiagram
3. ✅ Define participants
4. ✅ Show ALL interactions
5. ✅ Use alt/else for conditionals
6. ⚠️ NO EMOJI in participant names or messages
7. ✅ End with: ```

💡 EXAMPLE:
```mermaid
sequenceDiagram
    autonumber
    participant User
    participant System
    participant DB

    User->>System: Submit Request
    System->>DB: Query Data
    DB-->>System: Return Data

    alt Success
        System-->>User: Show Result
    else Error
        System-->>User: Show Error
    end
```

✅ MUST INCLUDE:
- Participant definitions
- Clear message flow
- Proper arrow syntax (->> and -->>)
- Alt/else blocks for conditionals
- NO special characters

📝 Code (%s):
%s

🎯 OUTPUT ONLY mermaid code with CORRECT arrows:]], filetype, filetype, code_content:sub(1, 2500))
end

-- 3️⃣ CLASS DIAGRAM
M.build_class_diagram_prompt = function(filetype, code_content)
  return string.format([[🔍 Analyze this %s code and create a Mermaid class diagram.

📋 OUTPUT RULES:
1. ✅ Start with: ```mermaid
2. ✅ Second line: classDiagram
3. ✅ Class format:
   class Name {
       +type attribute
       +method()
   }
4. ✅ Relationships on separate lines
5. ⚠️ NO EMOJI in class names or methods
6. ✅ Apply styles at END
7. ✅ End with: ```

🔗 RELATIONSHIPS:
- Inheritance: Parent <|-- Child
- Implementation: Interface <|.. Class
- Association: ClassA --> ClassB
- Composition: Whole *-- Part

💡 EXAMPLE:
```mermaid
classDiagram
    class User {
        +String id
        +String name
        +login() boolean
    }

    class Admin {
        +String role
        +manage() void
    }

    User <|-- Admin

    class User:::primary
    class Admin:::secondary

%s
```

📝 Code (%s):
%s

🎯 OUTPUT ONLY mermaid code:]], filetype, M.get_class_diagram_styles(), filetype, code_content:sub(1, 2500))
end

-- 4️⃣ STATE DIAGRAM
M.build_state_diagram_prompt = function(filetype, code_content)
  return string.format([[🔍 Analyze this %s code and create a Mermaid state diagram.

📋 OUTPUT RULES:
1. ✅ Start with: ```mermaid
2. ✅ Second line: stateDiagram-v2
3. ✅ Format: StateA --> StateB : Event
4. ✅ Use [*] for start/end
5. ⚠️ NO EMOJI in state names or transitions
6. ✅ End with: ```

💡 EXAMPLE:
```mermaid
stateDiagram-v2
    [*] --> Idle
    Idle --> Loading : Submit
    Loading --> Success : Loaded
    Loading --> Error : Failed
    Success --> [*]
    Error --> Idle : Retry
```

📝 Code (%s):
%s

🎯 OUTPUT ONLY mermaid code:]], filetype, filetype, code_content:sub(1, 2500))
end

-- 5️⃣ ER DIAGRAM
M.build_er_diagram_prompt = function(filetype, code_content)
  return string.format([[🔍 Analyze this %s code and create a Mermaid ER diagram.

📋 OUTPUT RULES:
1. ✅ Start with: ```mermaid
2. ✅ Second line: erDiagram
3. ✅ Relationships first
4. ✅ Entity definitions after
5. ⚠️ NO EMOJI in entity names or attributes
6. ✅ End with: ```

🔗 CARDINALITY:
- || : exactly one
- |o : zero or one
- }o : zero or many
- }| : one or many

💡 EXAMPLE:
```mermaid
erDiagram
    USER ||--o{ ORDER : places
    ORDER ||--|{ ITEM : contains

    USER {
        int id PK
        string email UK
        string name
    }

    ORDER {
        int id PK
        int user_id FK
        decimal total
    }
```

📝 Code (%s):
%s

🎯 OUTPUT ONLY mermaid code:]], filetype, filetype, code_content:sub(1, 2500))
end

-- ========================================
-- 🎨 UX & PROJECT DIAGRAMS
-- ========================================

-- 6️⃣ USER JOURNEY
M.build_user_journey_prompt = function(filetype, code_content)
  return string.format([[🔍 Create a Mermaid user journey from this %s code.

📋 FORMAT:
```mermaid
journey
    title User Flow
    section Browse
      View Products: 5: User
    section Purchase
      Add Cart: 4: User
      Checkout: 5: User, System
```

⭐ Scores: 1-5 (1=bad, 5=excellent)
⚠️ NO EMOJI in section or task names

📝 Code: %s

🎯 OUTPUT ONLY mermaid code:]], filetype, code_content:sub(1, 2000))
end

-- 7️⃣ GANTT
M.build_gantt_prompt = function(filetype, code_content)
  return string.format([[🔍 Create a Mermaid Gantt chart from this %s code.

📋 FORMAT:
```mermaid
gantt
    title Timeline
    dateFormat YYYY-MM-DD
    section Phase 1
    Task A :done, t1, 2024-01-01, 10d
    Task B :active, t2, after t1, 5d
```

⚠️ NO EMOJI in task names

📝 Code: %s

🎯 OUTPUT ONLY mermaid code:]], filetype, code_content:sub(1, 2000))
end

-- 8️⃣ TIMELINE
M.build_timeline_prompt = function(filetype, code_content)
  return string.format([[🔍 Create a Mermaid timeline from this %s code.

📋 FORMAT:
```mermaid
timeline
    title Events
    section 2024 Q1
      Planning : Requirements
    section 2024 Q2
      Development : Features
```

⚠️ NO EMOJI in event names

📝 Code: %s

🎯 OUTPUT ONLY mermaid code:]], filetype, code_content:sub(1, 2000))
end

-- 9️⃣ KANBAN
M.build_kanban_prompt = function(filetype, code_content)
  return string.format([[🔍 Create a Mermaid Kanban from this %s code.

📋 FORMAT:
```mermaid
kanban
  Todo
    [Task 1]
  In Progress
    [Task 2]
  Done
    [Task 3]
```

⚠️ NO EMOJI in task names

📝 Code: %s

🎯 OUTPUT ONLY mermaid code:]], filetype, code_content:sub(1, 2000))
end

-- ========================================
-- 📊 DATA VISUALIZATION DIAGRAMS
-- ========================================

-- 🔟 PIE CHART
M.build_pie_prompt = function(filetype, code_content)
  return string.format([[🔍 Create a Mermaid pie chart from this %s code.

📋 FORMAT:
```mermaid
pie title Distribution
    "Category A" : 45
    "Category B" : 30
    "Category C" : 25
```

⚠️ NO EMOJI in category names

📝 Code: %s

🎯 OUTPUT ONLY mermaid code:]], filetype, code_content:sub(1, 2000))
end

-- 1️⃣1️⃣ QUADRANT CHART
M.build_quadrant_prompt = function(filetype, code_content)
  return string.format([[🔍 Create a Mermaid quadrant chart from this %s code.

📋 FORMAT:
```mermaid
quadrantChart
    title Priority Matrix
    x-axis Low --> High
    y-axis Low --> High
    quadrant-1 Quick Wins
    quadrant-2 Major
    quadrant-3 Fill
    quadrant-4 Avoid
    Item A: [0.3, 0.8]
```

⚠️ NO EMOJI in item names

📝 Code: %s

🎯 OUTPUT ONLY mermaid code:]], filetype, code_content:sub(1, 2000))
end

-- 1️⃣2️⃣ XY CHART
M.build_xy_chart_prompt = function(filetype, code_content)
  return string.format([[🔍 Create a Mermaid XY chart from this %s code.

📋 FORMAT:
```mermaid
xychart-beta
    title "Metrics"
    x-axis [Q1, Q2, Q3, Q4]
    y-axis "Value" 0 --> 100
    line [20, 45, 60, 80]
```

⚠️ NO EMOJI in labels

📝 Code: %s

🎯 OUTPUT ONLY mermaid code:]], filetype, code_content:sub(1, 2000))
end

-- 1️⃣3️⃣ SANKEY
M.build_sankey_prompt = function(filetype, code_content)
  return string.format([[🔍 Create a Mermaid Sankey diagram from this %s code.

📋 FORMAT:
```mermaid
sankey-beta

Source,Target,Value
A,B,10
B,C,5
```

⚠️ NO EMOJI in node names

📝 Code: %s

🎯 OUTPUT ONLY mermaid code:]], filetype, code_content:sub(1, 2000))
end

-- ========================================
-- 💻 DEVELOPMENT DIAGRAMS
-- ========================================

-- 1️⃣4️⃣ GITGRAPH
M.build_gitgraph_prompt = function(filetype, code_content)
  return string.format([[🔍 Create a Mermaid git graph from this %s code.

📋 FORMAT:
```mermaid
gitGraph
    commit id: "Init"
    branch develop
    checkout develop
    commit id: "Feature"
    checkout main
    merge develop
```

⚠️ NO EMOJI in commit messages

📝 Code: %s

🎯 OUTPUT ONLY mermaid code:]], filetype, code_content:sub(1, 2000))
end

-- 1️⃣5️⃣ ARCHITECTURE (C4)
M.build_architecture_prompt = function(filetype, code_content)
  return string.format([[🔍 Create a Mermaid C4 diagram from this %s code.

📋 FORMAT:
```mermaid
C4Context
    title System Context
    Person(user, "User")
    System(app, "App")
    Rel(user, app, "Uses")
```

⚠️ NO EMOJI in component names

📝 Code: %s

🎯 OUTPUT ONLY mermaid code:]], filetype, code_content:sub(1, 2000))
end

-- 1️⃣6️⃣ BLOCK DIAGRAM
M.build_block_diagram_prompt = function(filetype, code_content)
  return string.format([[🔍 Create a Mermaid block diagram from this %s code.

📋 FORMAT:
```mermaid
block-beta
    columns 3
    Frontend
    Backend
    Database
```

⚠️ NO EMOJI in block names

📝 Code: %s

🎯 OUTPUT ONLY mermaid code:]], filetype, code_content:sub(1, 2000))
end

-- 1️⃣7️⃣ PACKET
M.build_packet_prompt = function(filetype, code_content)
  return string.format([[🔍 Create a Mermaid packet diagram from this %s code.

📋 FORMAT:
```mermaid
packet-beta
    title "Header"
    0-15: "Field A"
    16-31: "Field B"
```

⚠️ NO EMOJI in field names

📝 Code: %s

🎯 OUTPUT ONLY mermaid code:]], filetype, code_content:sub(1, 2000))
end

-- ========================================
-- 📝 PLANNING DIAGRAMS
-- ========================================

-- 1️⃣8️⃣ REQUIREMENT
M.build_requirement_prompt = function(filetype, code_content)
  return string.format([[🔍 Create a Mermaid requirement diagram from this %s code.

📋 FORMAT:
```mermaid
requirementDiagram
    requirement Req1 {
        id: R1
        text: Description
        risk: High
    }
    element Module {
        type: Component
    }
    Req1 - satisfies -> Module
```

⚠️ NO EMOJI in requirement text

📝 Code: %s

🎯 OUTPUT ONLY mermaid code:]], filetype, code_content:sub(1, 2000))
end

-- 1️⃣9️⃣ MINDMAP
M.build_mindmap_prompt = function(filetype, code_content)
  return string.format([[🔍 Create a Mermaid mindmap from this %s code.

📋 FORMAT:
```mermaid
mindmap
  root((Core))
    Topic A
      Sub A1
      Sub A2
    Topic B
      Sub B1
```

⚠️ NO EMOJI in topic names

📝 Code: %s

🎯 OUTPUT ONLY mermaid code:]], filetype, code_content:sub(1, 2000))
end

return M
