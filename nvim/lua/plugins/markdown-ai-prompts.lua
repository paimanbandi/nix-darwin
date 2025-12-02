-- markdown-ai-prompts.lua (PERBAIKAN)
-- Mermaid diagram prompts for ALL diagram types
local M = {}

-- Professional color palette
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

-- Flowchart style definitions
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

-- Class diagram style
M.get_class_diagram_styles = function()
  return [[
    classDef primary fill:#dbeafe,stroke:#1e40af,stroke-width:2px
    classDef secondary fill:#cffafe,stroke:#0891b2,stroke-width:2px
    classDef interface fill:#e0e7ff,stroke:#6366f1,stroke-width:2px,stroke-dasharray: 5 5]]
end

-- FLOWCHART PROMPT
M.build_flowchart_prompt = function(filetype, code_content, complexity)
  local max_nodes = complexity == "simple" and 30 or (complexity == "moderate" and 50 or 80)

  return string.format([[Analyze this %s code and create a Mermaid FLOWCHART diagram.

CRITICAL SYNTAX RULES - MUST FOLLOW EXACTLY:
1. Start with ONLY: ```mermaid
2. Second line MUST be: flowchart TD
3. Node format: NodeID[Label Text]:::className
4. Arrow format: NodeA --> NodeB or NodeA ==> NodeB
5. Conditional: NodeA -->|Label| NodeB
6. Apply styles at THE END after all nodes and arrows
7. End with: ```

STRUCTURE (max %d nodes):
- Start/End nodes with :::startEnd
- Process nodes with :::process
- Decision nodes with :::decision
- API calls with :::api
- Success states with :::success
- Error states with :::error

REQUIRED FORMAT:
````````````````````````mermaid
flowchart TD
    Start([Begin]):::startEnd
    Process[Do Something]:::process
    Decision{Check?}:::decision

    Start ==> Process
    Process --> Decision
    Decision -->|Yes| Success[Success]:::success
    Decision -->|No| Error[Error]:::error
    Success --> End([Complete]):::startEnd
    Error --> End

%s
````````````````````````

CRITICAL RULES:
- NO text before ```mermaid
- NO explanatory text between diagram elements
- ALL class definitions at the END
- Use ONLY standard ASCII characters in labels
- NO special characters like quotes in node labels
- Keep labels SHORT (max 30 characters)

Code to analyze:
````````````````````````%s
%s
````````````````````````

Generate ONLY the mermaid diagram code block with proper syntax.]],
    filetype, max_nodes, M.get_flowchart_styles(), filetype, code_content)
end

-- SEQUENCE DIAGRAM PROMPT (FIXED)
M.build_sequence_prompt = function(filetype, code_content)
  return string.format([[Analyze this %s code and create a Mermaid SEQUENCE diagram.

CRITICAL SYNTAX RULES - MUST FOLLOW EXACTLY:
1. Start with ONLY: ```mermaid
2. Second line MUST be: sequenceDiagram
3. Define participants first: participant ID as Display Name
4. Use simple arrows: ->> for calls, -->> for returns
5. Activation: ->>+ to activate, -->>- to deactivate
6. NO rect rgb() blocks - they cause syntax errors
7. Use box instead: box LightBlue Description
8. Notes: Note over A,B: Text or Note right of A: Text
9. End with: ```

STRUCTURE:
1. Define ALL participants
2. Show interactions with clear arrows
3. Use alt/opt/loop for control flow
4. Add notes for clarity
5. Use autonumber for step numbers

REQUIRED FORMAT:
````````````````````````mermaid
sequenceDiagram
    autonumber
    participant User
    participant Client
    participant API
    participant DB

    User->>+Client: Click Submit
    Note over Client: Validate Input

    Client->>+API: POST /api/data
    Note over Client,API: Authentication required

    API->>+DB: Query Data
    DB-->>-API: Return Results

    alt Success
        API-->>Client: 200 OK
        Client-->>User: Show Success
    else Error
        API-->>Client: 400 Error
        Client-->>-User: Show Error
    end

    deactivate Client
````````````````````````

CRITICAL RULES:
- NO text before ```mermaid
- NO rect rgb() blocks - use box or Note instead
- Use simple participant names (no special chars)
- Keep message labels SHORT
- Use alt/else for conditionals
- Use loop for iterations
- Use opt for optional flows
- End with deactivate if needed

SAFE ALTERNATIVES:
- Instead of rect rgb(), use: Note over A,B: Section Name
- Or use: box LightBlue Section Name

Code to analyze:
````````````````````````%s
%s
````````````````````````

Generate ONLY the mermaid diagram code block with proper syntax. NO rect blocks.]],
    filetype, filetype, code_content)
end

-- CLASS DIAGRAM PROMPT (FIXED)
M.build_class_diagram_prompt = function(filetype, code_content)
  return string.format([[Analyze this %s code and create a Mermaid CLASS diagram.

CRITICAL SYNTAX RULES - MUST FOLLOW EXACTLY:
1. Start with ONLY: ```mermaid
2. Second line MUST be: classDiagram
3. Class definition format:
   class ClassName {
       +type attribute
       +returnType method()
   }
4. Relationships MUST be on separate lines
5. Apply styles at THE END
6. End with: ```

RELATIONSHIP SYMBOLS:
- Inheritance: Parent <|-- Child
- Implementation: Interface <|.. Class
- Composition: Whole *-- Part
- Aggregation: Container o-- Item
- Association: ClassA --> ClassB
- Dependency: ClassA ..> ClassB

REQUIRED FORMAT:
````````````````````````mermaid
classDiagram
    class User {
        +String id
        +String name
        +String email
        +login() boolean
        +logout() void
    }

    class Admin {
        +String role
        +manageUsers() void
    }

    class Session {
        +String token
        +isValid() boolean
    }

    User <|-- Admin
    User --> Session

    class User:::primary
    class Admin:::secondary
    class Session:::interface

%s
````````````````````````

CRITICAL RULES:
- NO text before ```mermaid
- ONE class definition per block
- Methods must have parentheses ()
- Relationships on separate lines
- Visibility: + public, - private, # protected
- NO special characters in class names

Code to analyze:
````````````````````````%s
%s
````````````````````````

Generate ONLY the mermaid diagram code block with proper syntax.]],
    filetype, M.get_class_diagram_styles(), filetype, code_content)
end

-- STATE DIAGRAM PROMPT
M.build_state_diagram_prompt = function(filetype, code_content)
  return string.format([[Analyze this %s code and create a Mermaid STATE diagram.

CRITICAL SYNTAX RULES - MUST FOLLOW EXACTLY:
1. Start with ONLY: ```mermaid
2. Second line MUST be: stateDiagram-v2
3. State format: state "Display Name" as StateId
4. Transitions: StateA --> StateB : Event
5. Start: [*] --> FirstState
6. End: LastState --> [*]
7. End with: ```

REQUIRED FORMAT:
````````````````````````mermaid
stateDiagram-v2
    [*] --> Idle

    Idle --> Loading : User Submit
    Loading --> Success : Data Loaded
    Loading --> Error : Load Failed

    Success --> Idle : Reset
    Error --> Idle : Retry

    Success --> Processing : Confirm
    Processing --> Complete : Done
    Complete --> [*]

    state Loading {
        [*] --> Fetching
        Fetching --> Validating
        Validating --> [*]
    }
````````````````````````

CRITICAL RULES:
- NO text before ```mermaid
- Use state keyword for named states
- Use [*] for start/end points
- Keep transition labels SHORT
- Nested states use braces {}

Code to analyze:
````````````````````````%s
%s
````````````````````````

Generate ONLY the mermaid diagram code block with proper syntax.]],
    filetype, filetype, code_content)
end

-- ER DIAGRAM PROMPT
M.build_er_diagram_prompt = function(filetype, code_content)
  return string.format([[Analyze this %s code and create a Mermaid ER diagram.

CRITICAL SYNTAX RULES - MUST FOLLOW EXACTLY:
1. Start with ONLY: ```mermaid
2. Second line MUST be: erDiagram
3. Relationships first, then entity definitions
4. Cardinality symbols: ||, |o, }o, }|
5. Entity format: ENTITY_NAME { type attribute }
6. End with: ```

CARDINALITY:
- || exactly one
- |o zero or one
- }o zero or more
- }| one or more

REQUIRED FORMAT:
````````````````````````mermaid
erDiagram
    USER ||--o{ ORDER : places
    ORDER ||--|{ LINE_ITEM : contains
    PRODUCT ||--o{ LINE_ITEM : "ordered in"

    USER {
        int id PK
        string email UK
        string name
        string password
        datetime created_at
    }

    ORDER {
        int id PK
        int user_id FK
        decimal total
        string status
        datetime created_at
    }

    PRODUCT {
        int id PK
        string name
        decimal price
        int stock
    }

    LINE_ITEM {
        int id PK
        int order_id FK
        int product_id FK
        int quantity
        decimal price
    }
````````````````````````

CRITICAL RULES:
- NO text before ```mermaid
- Use UPPERCASE for entity names
- Relationships BEFORE entity definitions
- Use PK for primary key, FK for foreign key, UK for unique
- NO quotes in attribute names

Code to analyze:
````````````````````````%s
%s
````````````````````````

Generate ONLY the mermaid diagram code block with proper syntax.]],
    filetype, filetype, code_content)
end

-- USER JOURNEY PROMPT
M.build_user_journey_prompt = function(filetype, code_content)
  return string.format([[Analyze this %s code and create a Mermaid USER JOURNEY diagram.

CRITICAL SYNTAX RULES - MUST FOLLOW EXACTLY:
1. Start with ONLY: ```mermaid
2. Second line MUST be: journey
3. Third line: title Your Title Here
4. Section format: section Section Name
5. Task format: Task Name: score: Actor1, Actor2
6. Scores: 1-5 (1=bad, 5=excellent)
7. End with: ```

REQUIRED FORMAT:
````````````````````````mermaid
journey
    title Customer Purchase Journey
    section Discovery
      Browse Products: 5: Customer
      View Details: 4: Customer
      Read Reviews: 3: Customer
    section Decision
      Add to Cart: 4: Customer
      Apply Coupon: 5: Customer
    section Checkout
      Enter Info: 3: Customer
      Select Payment: 4: Customer
      Complete Order: 5: Customer, System
    section Post-Purchase
      Receive Confirmation: 5: Customer
      Track Shipment: 4: Customer
````````````````````````

CRITICAL RULES:
- NO text before ```mermaid
- Title on its own line
- Sections group related tasks
- Score must be 1-5
- Multiple actors separated by comma

Code to analyze:
````````````````````````%s
%s
````````````````````````

Generate ONLY the mermaid diagram code block with proper syntax.]],
    filetype, filetype, code_content)
end

-- GANTT PROMPT
M.build_gantt_prompt = function(filetype, code_content)
  return string.format([[Analyze this %s code and create a Mermaid GANTT diagram.

CRITICAL SYNTAX RULES - MUST FOLLOW EXACTLY:
1. Start with ONLY: ```mermaid
2. Second line MUST be: gantt
3. Third line: title Your Title
4. Fourth line: dateFormat YYYY-MM-DD
5. Section format: section Section Name
6. Task format: Task Name :status, id, start, duration
7. Status: done, active, crit, milestone
8. End with: ```

REQUIRED FORMAT:
````````````````````````mermaid
gantt
    title Project Timeline
    dateFormat YYYY-MM-DD
    section Planning
    Requirements :done, req, 2024-01-01, 10d
    Design :done, design, after req, 15d
    section Development
    Backend :active, backend, after design, 30d
    Frontend :active, frontend, after design, 25d
    section Testing
    Unit Testing :testing, after backend, 10d
    UAT :crit, after testing, 5d
    section Deploy
    Go Live :milestone, after testing, 1d
````````````````````````

CRITICAL RULES:
- NO text before ```mermaid
- dateFormat required
- Use 'after taskId' for dependencies
- milestone for important dates
- crit for critical path

Code to analyze:
````````````````````````%s
%s
````````````````````````

Generate ONLY the mermaid diagram code block with proper syntax.]],
    filetype, filetype, code_content)
end

-- PIE CHART PROMPT
M.build_pie_prompt = function(filetype, code_content)
  return string.format([[Analyze this %s code and create a Mermaid PIE chart.

CRITICAL SYNTAX RULES - MUST FOLLOW EXACTLY:
1. Start with ONLY: ```mermaid
2. Second line MUST be: pie title Your Title
3. Data format: "Label" : value
4. End with: ```

REQUIRED FORMAT:
````````````````````````mermaid
pie title Technology Distribution
    "React" : 35
    "Vue" : 25
    "Angular" : 20
    "Svelte" : 12
    "Others" : 8
````````````````````````

CRITICAL RULES:
- NO text before ```mermaid
- Title on same line as pie
- Use quotes for labels
- Values auto-convert to percentages

Code to analyze:
````````````````````````%s
%s
````````````````````````

Generate ONLY the mermaid diagram code block.]],
    filetype, filetype, code_content)
end

-- QUADRANT CHART PROMPT
M.build_quadrant_prompt = function(filetype, code_content)
  return string.format([[Analyze this %s code and create a Mermaid QUADRANT chart.

CRITICAL SYNTAX RULES:
1. Start with: ```mermaid
2. Second line: quadrantChart
3. Title, axes, quadrants, then points
4. Point format: Item: [x, y]
5. Values 0.0 to 1.0

REQUIRED FORMAT:
````````````````````````mermaid
quadrantChart
    title Priority Matrix
    x-axis Low Effort --> High Effort
    y-axis Low Impact --> High Impact
    quadrant-1 Quick Wins
    quadrant-2 Major Projects
    quadrant-3 Fill Ins
    quadrant-4 Thankless Tasks
    Bug Fix: [0.2, 0.8]
    New Feature: [0.7, 0.9]
    Refactor: [0.6, 0.4]
````````````````````````

Code to analyze:
````````````````````````%s
%s
```````````````````````]],
    filetype, filetype, code_content)
end

-- REQUIREMENT DIAGRAM PROMPT
M.build_requirement_prompt = function(filetype, code_content)
  return string.format([[Analyze this %s code and create a Mermaid REQUIREMENT diagram.

CRITICAL SYNTAX RULES:
1. Start with: ```mermaid
2. Second line: requirementDiagram
3. Define requirements and elements
4. Show relationships

REQUIRED FORMAT:
``````````````````````mermaid
requirementDiagram
    requirement AuthReq {
        id: REQ-001
        text: System shall authenticate users
        risk: High
        verifymethod: Test
    }

    element LoginModule {
        type: Module
        docref: DOC-001
    }

    AuthReq - satisfies -> LoginModule
``````````````````````

Code to analyze:
``````````````````````%s
%s
`````````````````````]],
    filetype, filetype, code_content)
end

-- GITGRAPH PROMPT
M.build_gitgraph_prompt = function(filetype, code_content)
  return string.format([[Analyze this %s code and create a Mermaid GITGRAPH.

CRITICAL SYNTAX RULES:
1. Start with: ```mermaid
2. Second line: gitGraph
3. Commands: commit, branch, checkout, merge
4. Commit format: commit id: "message"

REQUIRED FORMAT:
````````````````````mermaid
gitGraph
    commit id: "Initial"
    commit id: "Add base"
    branch develop
    checkout develop
    commit id: "Add feature"
    branch feature/login
    checkout feature/login
    commit id: "Implement"
    checkout develop
    merge feature/login
    checkout main
    merge develop tag: "v1.0"
````````````````````

Code to analyze:
````````````````````%s
%s
```````````````````]],
    filetype, filetype, code_content)
end

-- MINDMAP PROMPT
M.build_mindmap_prompt = function(filetype, code_content)
  return string.format([[Analyze this %s code and create a Mermaid MINDMAP.

CRITICAL SYNTAX RULES:
1. Start with: ```mermaid
2. Second line: mindmap
3. Root node at top
4. Indentation for hierarchy
5. Shapes: ((rounded)), [square], {{hexagon}}

REQUIRED FORMAT:
``````````````````mermaid
mindmap
  root((Architecture))
    Frontend
      React
        Components
        Hooks
      Vue
        Composition
    Backend
      Node.js
        Express
      Database
        PostgreSQL
        Redis
``````````````````

Code to analyze:
``````````````````%s
%s
`````````````````]],
    filetype, filetype, code_content)
end

-- TIMELINE PROMPT
M.build_timeline_prompt = function(filetype, code_content)
  return string.format([[Analyze this %s code and create a Mermaid TIMELINE.

CRITICAL SYNTAX RULES:
1. Start with: ```mermaid
2. Second line: timeline
3. Third line: title Your Title
4. Section and events

REQUIRED FORMAT:
````````````````mermaid
timeline
    title Product Timeline
    section 2023 Q1
      Planning : Requirements
      : Design
    section 2023 Q2
      Development : Backend
      : Frontend
    section 2023 Q3
      Testing : QA
    section 2023 Q4
      Launch : Production
````````````````

Code to analyze:
````````````````%s
%s
```````````````]],
    filetype, filetype, code_content)
end

-- SANKEY PROMPT
M.build_sankey_prompt = function(filetype, code_content)
  return string.format([[Analyze this %s code and create a Mermaid SANKEY diagram.

CRITICAL SYNTAX RULES:
1. Start with: ```mermaid
2. Second line: sankey-beta
3. Format: Source,Target,Value

REQUIRED FORMAT:
``````````````mermaid
sankey-beta

Website,Mobile,350
Website,Desktop,250
Mobile,Premium,120
Mobile,Free,230
Desktop,Premium,180
``````````````

Code to analyze:
``````````````%s
%s
`````````````]],
    filetype, filetype, code_content)
end

-- XY CHART PROMPT
M.build_xy_chart_prompt = function(filetype, code_content)
  return string.format([[Analyze this %s code and create a Mermaid XY CHART.

CRITICAL SYNTAX RULES:
1. Start with: ```mermaid
2. Second line: xychart-beta
3. Configure title, axes, data

REQUIRED FORMAT:
````````````mermaid
xychart-beta
    title "Sales 2024"
    x-axis [Jan, Feb, Mar, Apr, May]
    y-axis "Revenue" 0 --> 100000
    line [45000, 52000, 48000, 65000, 72000]
    bar [30000, 35000, 40000, 50000, 55000]
````````````

Code to analyze:
````````````%s
%s
```````````]],
    filetype, filetype, code_content)
end

-- BLOCK DIAGRAM PROMPT
M.build_block_diagram_prompt = function(filetype, code_content)
  return string.format([[Analyze this %s code and create a Mermaid BLOCK diagram.

CRITICAL SYNTAX RULES:
1. Start with: ```mermaid
2. Second line: block-beta
3. Define columns and blocks

REQUIRED FORMAT:
``````````mermaid
block-beta
    columns 3
    Frontend:3
    block:api:3
        Auth
        Rate
        Log
    end
    block:services:3
        User
        Order
        Payment
    end
    Database:3
``````````

Code to analyze:
``````````%s
%s
`````````]],
    filetype, filetype, code_content)
end

-- PACKET PROMPT
M.build_packet_prompt = function(filetype, code_content)
  return string.format([[Analyze this %s code and create a Mermaid PACKET diagram.

CRITICAL SYNTAX RULES:
1. Start with: ```mermaid
2. Second line: packet-beta
3. Title and bit ranges

REQUIRED FORMAT:
````````mermaid
packet-beta
    title "TCP Header"
    0-15: "Source Port"
    16-31: "Dest Port"
    32-63: "Sequence"
    64-95: "Acknowledgment"
````````

Code to analyze:
````````%s
%s
```````]],
    filetype, filetype, code_content)
end

-- KANBAN PROMPT
M.build_kanban_prompt = function(filetype, code_content)
  return string.format([[Analyze this %s code and create a Mermaid KANBAN.

CRITICAL SYNTAX RULES:
1. Start with: ```mermaid
2. Second line: kanban
3. Column names and tasks

REQUIRED FORMAT:
``````mermaid
kanban
  Todo
    [Design Schema]
    [API Endpoints]
  In Progress
    [Auth System]
  Done
    [Setup Project]
``````

Code to analyze:
``````%s
%s
`````]],
    filetype, filetype, code_content)
end

-- ARCHITECTURE PROMPT
M.build_architecture_prompt = function(filetype, code_content)
  return string.format([[Analyze this %s code and create a Mermaid C4 ARCHITECTURE.

CRITICAL SYNTAX RULES:
1. Start with: ```mermaid
2. Second line: C4Context
3. Define people, systems, relationships

REQUIRED FORMAT:
````mermaid
C4Context
    title System Context
    Person(user, "User", "Customer")
    System(app, "App", "Main system")
    System_Ext(payment, "Payment", "External")
    Rel(user, app, "Uses")
    Rel(app, payment, "Processes")
````

Code to analyze:
````%s
%s
```]],
    filetype, filetype, code_content)
end

return M
