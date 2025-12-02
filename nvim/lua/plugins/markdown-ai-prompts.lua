-- markdown-ai-prompts.lua
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

DIAGRAM TYPE: Flowchart (Process Flow)
Use flowchart when showing: decision logic, user flows, state changes, conditional paths

SYNTAX RULES:
1. Start with: ```mermaid
2. Use directive: flowchart TD or flowchart LR
3. Node types:
   - Start/End: Start([Begin Process]):::startEnd
   - Process: Process[Do Something]:::process
   - Decision: Decision{Condition?}:::decision
   - API: API[API Call]:::api
   - Success: Success[Success State]:::success
   - Error: Error[Error State]:::error
4. Arrows:
   - Normal flow: -->
   - Thick flow: ==>
   - Conditional: -->|Yes| or -->|No|
5. Apply class styles to ALL nodes
6. End with: ```

STRUCTURE (max %d nodes):
- Initialization
- Decision points with clear Yes/No paths
- Process steps
- Error handling
- Success/completion paths

COLOR CODING:
%s

CLARITY RULES:
- Use THICK arrows (==>) for main happy path
- Use thin arrows (-->) for alternative/error paths
- Label ALL conditional branches clearly
- Avoid crossing arrows
- Group related nodes vertically
- Apply :::className to every node

EXAMPLE:
```mermaid
flowchart TD
    Start([User Request]):::startEnd ==> Validate[Validate Input]:::process
    Validate --> CheckAuth{Authenticated?}:::decision

    CheckAuth -->|Yes| Process[Process Request]:::process
    CheckAuth -->|No| Error[Return 401 Error]:::error

    Process ==> CallAPI[Call External API]:::api
    CallAPI --> CheckResponse{Response OK?}:::decision

    CheckResponse -->|Yes| Success[Return Success]:::success
    CheckResponse -->|No| Retry{Retry Count < 3?}:::decision

    Retry -->|Yes| CallAPI
    Retry -->|No| Error

    Success ==> End([Complete]):::startEnd
    Error --> End

%s
```

Code to analyze:
```%s
%s
```

Create a clear flowchart showing the process flow with proper arrow emphasis and color coding.]],
    filetype, max_nodes, M.get_flowchart_styles(), M.get_flowchart_styles(), filetype, code_content)
end

-- SEQUENCE DIAGRAM PROMPT
M.build_sequence_prompt = function(filetype, code_content)
  return string.format([[Analyze this %s code and create a Mermaid SEQUENCE diagram.

DIAGRAM TYPE: Sequence Diagram (Time-based Interactions)
Use sequence when showing: API calls, method invocations, async operations, service communication

SYNTAX RULES:
1. Start with: ```mermaid
2. Use directive: sequenceDiagram
3. Participants: participant Name as Display Name
4. Interactions:
   - Sync call: A->>B: Message
   - Async call: A->>+B: Message (activate)
   - Return: B-->>-A: Response (deactivate)
   - Note: Note over A,B: Description
5. Control:
   - Loop: loop Every 5 seconds
   - Alt: alt Success / else Failure
   - Opt: opt Optional flow
6. Styling: rect rgb(red, green, blue) for background

STRUCTURE:
1. Define all participants first
2. Show initialization
3. Main interaction flow
4. Error/alternative paths
5. Cleanup/completion

CLARITY RULES:
- Use meaningful participant names
- Add notes for complex logic
- Show activation boxes for processing
- Use alt/opt for conditional flows
- Group related interactions

EXAMPLE:
```mermaid
sequenceDiagram
    participant User
    participant Client
    participant API
    participant DB

    User->>+Client: Click Submit
    Client->>Client: Validate Input

    rect rgb(220, 240, 255)
    Note over Client,API: Authentication Flow
    Client->>+API: POST /api/data
    Note over Client,API: Request with auth token
    end

    API->>+DB: Query Data
    DB-->>-API: Return Results

    alt Success
        API-->>Client: 200 OK with data
        Client-->>User: Show Success
    else Error
        API-->>Client: 400 Bad Request
        Client-->>-User: Show Error
    end

    User->>Client: Close Dialog
```

Code to analyze:
```%s
%s
```

Create a sequence diagram showing time-based interactions between components.]],
    filetype, filetype, code_content)
end

-- CLASS DIAGRAM PROMPT
M.build_class_diagram_prompt = function(filetype, code_content)
  return string.format([[Analyze this %s code and create a Mermaid CLASS diagram.

DIAGRAM TYPE: Class Diagram (Object Structure)
Use class diagram when showing: classes, interfaces, inheritance, composition, aggregation

SYNTAX RULES:
1. Start with: ```mermaid
2. Use directive: classDiagram
3. Class definition:
   class ClassName {
       +publicProperty type
       -privateProperty type
       #protectedProperty type
       +publicMethod() returnType
       -privateMethod() returnType
   }
4. Relationships:
   - Inheritance: Parent <|-- Child
   - Implementation: Interface <|.. Class
   - Composition: Whole *-- Part
   - Aggregation: Container o-- Item
   - Association: ClassA --> ClassB
   - Dependency: ClassA ..> ClassB
5. Apply styles: class ClassName:::styleName

STRUCTURE:
1. Define all classes/interfaces
2. Show properties and methods
3. Define relationships
4. Apply styling

CLARITY RULES:
- Show only relevant properties/methods
- Use clear relationship types
- Group related classes
- Add notes for complex relationships

STYLING:
%s

EXAMPLE:
```mermaid
classDiagram
    class User {
        +String id
        +String name
        +String email
        -String password
        +login() boolean
        +logout() void
        +updateProfile() void
    }

    class Admin {
        +String[] permissions
        +String role
        +manageUsers() void
        +viewLogs() void
    }

    class Session {
        +String token
        +Date expiresAt
        +String userId
        +isValid() boolean
        +refresh() void
    }

    User <|-- Admin : inherits
    User "1" --> "0..*" Session : has

    class User:::primary
    class Admin:::secondary
    class Session:::interface
```

Code to analyze:
```%s
%s
```

Create a class diagram showing object structure and relationships.]],
    filetype, M.get_class_diagram_styles(), filetype, code_content)
end

-- STATE DIAGRAM PROMPT
M.build_state_diagram_prompt = function(filetype, code_content)
  return string.format([[Analyze this %s code and create a Mermaid STATE diagram.

DIAGRAM TYPE: State Diagram (State Transitions)
Use state diagram when showing: state machines, lifecycle, status changes, workflow states

SYNTAX RULES:
1. Start with: ```mermaid
2. Use directive: stateDiagram-v2
3. States: state "Display Name" as StateId
4. Transitions: StateA --> StateB : Event/Action
5. Special:
   - Start: [*] --> FirstState
   - End: LastState --> [*]
   - Choice: state choice <<choice>>
   - Fork: state fork <<fork>>
   - Join: state join <<join>>
6. Nested states allowed

STRUCTURE:
1. Define all states
2. Show initial state
3. Define transitions with events
4. Show final states
5. Add nested states if needed

EXAMPLE:
```mermaid
stateDiagram-v2
    [*] --> Idle

    Idle --> Loading : User Submit
    Loading --> Success : Data Loaded
    Loading --> Error : Load Failed

    Success --> Idle : Reset
    Error --> Idle : Retry
    Error --> [*] : Cancel

    Success --> Processing : User Confirm
    Processing --> Complete : Process Done
    Complete --> [*]

    state Loading {
        [*] --> FetchingData
        FetchingData --> ValidatingData
        ValidatingData --> TransformingData
        TransformingData --> [*]
    }

    state Processing {
        [*] --> Calculating
        Calculating --> Validating
        Validating --> Saving
        Saving --> [*]
    }
```

Code to analyze:
```%s
%s
```

Create a state diagram showing state transitions and events.]],
    filetype, filetype, code_content)
end

-- ER DIAGRAM PROMPT
M.build_er_diagram_prompt = function(filetype, code_content)
  return string.format([[Analyze this %s code and create a Mermaid ER diagram.

DIAGRAM TYPE: Entity Relationship Diagram (Database Schema)
Use ER diagram when showing: database tables, relationships, foreign keys

SYNTAX RULES:
1. Start with: ```mermaid
2. Use directive: erDiagram
3. Entities: EntityName { type attribute PK/FK }
4. Relationships:
   - One to One: Entity1 ||--|| Entity2 : relationship
   - One to Many: Entity1 ||--o{ Entity2 : relationship
   - Many to Many: Entity1 }o--o{ Entity2 : relationship
   - Zero or One: Entity1 ||--o| Entity2 : relationship
   - Zero or Many: Entity1 }o--o{ Entity2 : relationship

CARDINALITY:
- || exactly one
- |o zero or one
- }o zero or more
- }| one or more

EXAMPLE:
```mermaid
erDiagram
    USER ||--o{ ORDER : places
    ORDER ||--|{ LINE_ITEM : contains
    PRODUCT ||--o{ LINE_ITEM : "ordered in"
    USER ||--o| PROFILE : has
    CATEGORY ||--o{ PRODUCT : contains

    USER {
        int id PK
        string email UK
        string name
        string password
        datetime created_at
        datetime updated_at
    }

    PROFILE {
        int id PK
        int user_id FK
        string bio
        string avatar_url
        datetime created_at
    }

    ORDER {
        int id PK
        int user_id FK
        decimal total
        string status
        datetime created_at
        datetime updated_at
    }

    PRODUCT {
        int id PK
        int category_id FK
        string name
        decimal price
        int stock
        datetime created_at
    }

    CATEGORY {
        int id PK
        string name
        string slug UK
        datetime created_at
    }

    LINE_ITEM {
        int id PK
        int order_id FK
        int product_id FK
        int quantity
        decimal price
    }
```

Code to analyze:
```%s
%s
```

Create an ER diagram showing database structure with proper relationships.]],
    filetype, filetype, code_content)
end

-- USER JOURNEY PROMPT
M.build_user_journey_prompt = function(filetype, code_content)
  return string.format([[Analyze this %s code and create a Mermaid USER JOURNEY diagram.

DIAGRAM TYPE: User Journey (Experience Flow)
Use user journey when showing: user experience, satisfaction levels, touchpoints

SYNTAX RULES:
1. Start with: ```mermaid
2. Use directive: journey
3. Title: title User Journey Title
4. Sections with tasks and scores (1-5)
   section Section Name
     Task Name: score: Actor1, Actor2

STRUCTURE:
- Multiple sections representing phases
- Tasks with satisfaction scores (1-5)
- Multiple actors can be involved
- 5 = very satisfied, 1 = very dissatisfied

EXAMPLE:
```mermaid
journey
    title Customer Purchase Journey
    section Discovery
      Browse Products: 5: Customer
      View Product Details: 4: Customer
      Read Reviews: 3: Customer
    section Decision
      Add to Cart: 4: Customer
      Apply Coupon: 5: Customer
      Review Cart: 4: Customer
    section Checkout
      Enter Shipping Info: 3: Customer
      Select Payment: 4: Customer
      Complete Order: 5: Customer, System
    section Post-Purchase
      Receive Confirmation: 5: Customer, System
      Track Shipment: 4: Customer
      Receive Product: 5: Customer
```

Code to analyze:
```%s
%s
```

Create a user journey diagram showing experience flow with satisfaction scores.]],
    filetype, filetype, code_content)
end

-- GANTT PROMPT
M.build_gantt_prompt = function(filetype, code_content)
  return string.format([[Analyze this %s code and create a Mermaid GANTT diagram.

DIAGRAM TYPE: Gantt Chart (Project Timeline)
Use gantt when showing: project schedules, task dependencies, milestones

SYNTAX RULES:
1. Start with: ```mermaid
2. Use directive: gantt
3. Configuration:
   title Project Name
   dateFormat YYYY-MM-DD
   section Section Name
   Task Name :status, id, start-date, duration
4. Status: done, active, crit (critical), milestone
5. Dependencies: after id

STRUCTURE:
- Project title and date format
- Sections for phases
- Tasks with dates/durations
- Milestones
- Dependencies between tasks

EXAMPLE:
```mermaid
gantt
    title Software Development Project
    dateFormat YYYY-MM-DD
    section Planning
    Requirements Analysis    :done, req, 2024-01-01, 10d
    Design Specifications    :done, design, after req, 15d
    section Development
    Backend Development      :active, backend, after design, 30d
    Frontend Development     :active, frontend, after design, 25d
    Database Setup          :done, db, after design, 10d
    section Testing
    Unit Testing            :testing, after backend, 10d
    Integration Testing     :after testing, 7d
    UAT                     :crit, after testing, 5d
    section Deployment
    Staging Deployment      :milestone, after testing, 1d
    Production Deployment   :crit, milestone, after testing, 1d
```

Code to analyze:
```%s
%s
```

Create a gantt chart showing project timeline and dependencies.]],
    filetype, filetype, code_content)
end

-- PIE CHART PROMPT
M.build_pie_prompt = function(filetype, code_content)
  return string.format([[Analyze this %s code and create a Mermaid PIE chart.

DIAGRAM TYPE: Pie Chart (Proportional Data)
Use pie chart when showing: percentages, distribution, market share

SYNTAX RULES:
1. Start with: ```mermaid
2. Use directive: pie title Chart Title
3. Format: "Label" : value
4. Values are automatically converted to percentages

EXAMPLE:
```mermaid
pie title Technology Stack Distribution
    "React" : 35
    "Vue.js" : 25
    "Angular" : 20
    "Svelte" : 12
    "Others" : 8
```

Code to analyze:
```%s
%s
```

Create a pie chart showing proportional data distribution.]],
    filetype, filetype, code_content)
end

-- QUADRANT CHART PROMPT
M.build_quadrant_prompt = function(filetype, code_content)
  return string.format([[Analyze this %s code and create a Mermaid QUADRANT chart.

DIAGRAM TYPE: Quadrant Chart (Priority Matrix)
Use quadrant when showing: priorities, classifications, decision matrices

SYNTAX RULES:
1. Start with: ```mermaid
2. Use directive: quadrantChart
3. Configuration:
   title Chart Title
   x-axis Label Low --> High
   y-axis Label Low --> High
   quadrant-1 Name
   quadrant-2 Name
   quadrant-3 Name
   quadrant-4 Name
4. Points: Item: [x, y]

EXAMPLE:
```mermaid
quadrantChart
    title Project Priority Matrix
    x-axis Low Effort --> High Effort
    y-axis Low Impact --> High Impact
    quadrant-1 Quick Wins
    quadrant-2 Major Projects
    quadrant-3 Fill Ins
    quadrant-4 Thankless Tasks
    Bug Fix: [0.2, 0.8]
    New Feature: [0.7, 0.9]
    Code Refactor: [0.6, 0.4]
    Documentation: [0.3, 0.3]
    Performance Opt: [0.8, 0.7]
```

Code to analyze:
```%s
%s
```

Create a quadrant chart showing priority classifications.]],
    filetype, filetype, code_content)
end

-- REQUIREMENT DIAGRAM PROMPT
M.build_requirement_prompt = function(filetype, code_content)
  return string.format([[Analyze this %s code and create a Mermaid REQUIREMENT diagram.

DIAGRAM TYPE: Requirement Diagram (System Requirements)
Use requirement when showing: system requirements, relationships, traceability

SYNTAX RULES:
1. Start with: ```mermaid
2. Use directive: requirementDiagram
3. Requirements:
   requirement ReqName {
     id: ID
     text: Description
     risk: High/Medium/Low
     verifymethod: Test/Inspection/Analysis/Demonstration
   }
4. Elements: element ElementName { type: Type, docref: Doc }
5. Relationships: ReqName - satisfies -> ElementName

EXAMPLE:
```mermaid
requirementDiagram
    requirement AuthRequirement {
        id: REQ-001
        text: System shall authenticate users
        risk: High
        verifymethod: Test
    }

    requirement DataRequirement {
        id: REQ-002
        text: System shall encrypt data at rest
        risk: High
        verifymethod: Inspection
    }

    element LoginModule {
        type: Module
        docref: DOC-001
    }

    element Database {
        type: Component
        docref: DOC-002
    }

    AuthRequirement - satisfies -> LoginModule
    DataRequirement - satisfies -> Database
    AuthRequirement - derives -> DataRequirement
```

Code to analyze:
```%s
%s
```

Create a requirement diagram showing system requirements and relationships.]],
    filetype, filetype, code_content)
end

-- GITGRAPH PROMPT
M.build_gitgraph_prompt = function(filetype, code_content)
  return string.format([[Analyze this %s code and create a Mermaid GITGRAPH diagram.

DIAGRAM TYPE: GitGraph (Git Branching)
Use gitgraph when showing: git workflow, branching strategy, commit history

SYNTAX RULES:
1. Start with: ```mermaid
2. Use directive: gitGraph
3. Commands:
   - commit id: "message"
   - branch name
   - checkout name
   - merge name
   - cherry-pick id: "commitId"

EXAMPLE:
```mermaid
gitGraph
    commit id: "Initial commit"
    commit id: "Add base structure"
    branch develop
    checkout develop
    commit id: "Add features"
    branch feature/login
    checkout feature/login
    commit id: "Implement login"
    commit id: "Add tests"
    checkout develop
    merge feature/login
    checkout main
    merge develop tag: "v1.0.0"
    checkout develop
    commit id: "Continue development"
```

Code to analyze:
```%s
%s
```

Create a gitgraph showing branching and merging workflow.]],
    filetype, filetype, code_content)
end

-- MINDMAP PROMPT
M.build_mindmap_prompt = function(filetype, code_content)
  return string.format([[Analyze this %s code and create a Mermaid MINDMAP.

DIAGRAM TYPE: Mindmap (Hierarchical Concepts)
Use mindmap when showing: ideas, concepts, hierarchies, brainstorming

SYNTAX RULES:
1. Start with: ```mermaid
2. Use directive: mindmap
3. Root node at top
4. Indentation creates hierarchy
5. Shapes: ((rounded)), (cloud), [square], {{hexagon}}

EXAMPLE:
```mermaid
mindmap
  root((Software Architecture))
    Frontend
      React
        Components
        Hooks
        State Management
      Vue.js
        Composition API
        Directives
    Backend
      Node.js
        Express
        NestJS
      Database
        PostgreSQL
        MongoDB
        Redis
    DevOps
      CI/CD
        GitHub Actions
        Jenkins
      Cloud
        AWS
        Azure
```

Code to analyze:
```%s
%s
```

Create a mindmap showing hierarchical concepts and relationships.]],
    filetype, filetype, code_content)
end

-- TIMELINE PROMPT
M.build_timeline_prompt = function(filetype, code_content)
  return string.format([[Analyze this %s code and create a Mermaid TIMELINE.

DIAGRAM TYPE: Timeline (Chronological Events)
Use timeline when showing: historical events, project milestones, version history

SYNTAX RULES:
1. Start with: ```mermaid
2. Use directive: timeline
3. Title: title Timeline Title
4. Format:
   section Period
     Event : Description

EXAMPLE:
```mermaid
timeline
    title Product Development Timeline
    section 2023 Q1
      Planning Phase : Requirements gathering and analysis
      : Design mockups and prototypes
    section 2023 Q2
      Development : Backend API implementation
      : Frontend development
      : Database schema design
    section 2023 Q3
      Testing : Unit and integration tests
      : User acceptance testing
    section 2023 Q4
      Launch : Beta release
      : Production deployment
      : Marketing campaign
```

Code to analyze:
```%s
%s
```

Create a timeline showing chronological events.]],
    filetype, filetype, code_content)
end

-- SANKEY DIAGRAM PROMPT
M.build_sankey_prompt = function(filetype, code_content)
  return string.format([[Analyze this %s code and create a Mermaid SANKEY diagram.

DIAGRAM TYPE: Sankey (Flow Visualization)
Use sankey when showing: flows, transfers, conversions, resource allocation

SYNTAX RULES:
1. Start with: ```mermaid
2. Use directive: sankey-beta
3. Format: Source,Target,Value

EXAMPLE:
```mermaid
sankey-beta

Website,Mobile App,350
Website,Desktop App,250
Website,API,150
Mobile App,Premium,120
Mobile App,Free,230
Desktop App,Premium,180
Desktop App,Free,70
API,Premium,80
API,Free,70
```

Code to analyze:
```%s
%s
```

Create a sankey diagram showing flows and transfers.]],
    filetype, filetype, code_content)
end

-- XY CHART PROMPT
M.build_xy_chart_prompt = function(filetype, code_content)
  return string.format([[Analyze this %s code and create a Mermaid XY CHART.

DIAGRAM TYPE: XY Chart (Data Visualization)
Use XY chart when showing: trends, comparisons, correlations

SYNTAX RULES:
1. Start with: ```mermaid
2. Use directive: xychart-beta
3. Configuration:
   title "Chart Title"
   x-axis [labels]
   y-axis "Y Label" min --> max
   line [data]
   bar [data]

EXAMPLE:
```mermaid
xychart-beta
    title "Sales Performance 2024"
    x-axis [Jan, Feb, Mar, Apr, May, Jun]
    y-axis "Revenue (USD)" 0 --> 100000
    line [45000, 52000, 48000, 65000, 72000, 85000]
    bar [30000, 35000, 40000, 50000, 55000, 60000]
```

Code to analyze:
```%s
%s
```

Create an XY chart showing data trends.]],
    filetype, filetype, code_content)
end

-- BLOCK DIAGRAM PROMPT
M.build_block_diagram_prompt = function(filetype, code_content)
  return string.format([[Analyze this %s code and create a Mermaid BLOCK diagram.

DIAGRAM TYPE: Block Diagram (System Architecture)
Use block diagram when showing: system architecture, component layout, infrastructure

SYNTAX RULES:
1. Start with: ```mermaid
2. Use directive: block-beta
3. Blocks can be nested
4. Format:
   columns 3
   block:name
     component1
     component2
   end

EXAMPLE:
```mermaid
block-beta
    columns 3
    Frontend["Frontend Layer"]:3
    block:api["API Gateway"]:3
        Auth["Authentication"]
        Rate["Rate Limiting"]
        Log["Logging"]
    end
    block:services["Microservices"]:3
        User["User Service"]
        Order["Order Service"]
        Payment["Payment Service"]
    end
    Database["Database Layer"]:3

    Frontend --> api
    api --> services
    services --> Database
```

Code to analyze:
```%s
%s
```

Create a block diagram showing system architecture.]],
    filetype, filetype, code_content)
end

-- PACKET DIAGRAM PROMPT
M.build_packet_prompt = function(filetype, code_content)
  return string.format([[Analyze this %s code and create a Mermaid PACKET diagram.

DIAGRAM TYPE: Packet Diagram (Network Protocol)
Use packet when showing: network packets, protocol structure, data frames

SYNTAX RULES:
1. Start with: ```mermaid
2. Use directive: packet-beta
3. Format:
   title "Packet Title"
   0-15: "Field Name"
   16-31: "Another Field"

EXAMPLE:
```mermaid
packet-beta
    title "TCP Header Structure"
    0-15: "Source Port"
    16-31: "Destination Port"
    32-63: "Sequence Number"
    64-95: "Acknowledgment Number"
    96-99: "Data Offset"
    100-105: "Reserved"
    106: "URG"
    107: "ACK"
    108: "PSH"
    109: "RST"
    110: "SYN"
    111: "FIN"
    112-127: "Window Size"
    128-143: "Checksum"
    144-159: "Urgent Pointer"
```

Code to analyze:
```%s
%s
```

Create a packet diagram showing protocol structure.]],
    filetype, filetype, code_content)
end

-- KANBAN PROMPT
M.build_kanban_prompt = function(filetype, code_content)
  return string.format([[Analyze this %s code and create a Mermaid KANBAN diagram.

DIAGRAM TYPE: Kanban (Workflow Board)
Use kanban when showing: task workflow, project status, agile board

SYNTAX RULES:
1. Start with: ```mermaid
2. Use directive: kanban
3. Format:
   Todo
     Task1
     Task2
   Doing
     Task3
   Done
     Task4

EXAMPLE:
```mermaid
kanban
  Todo
    [Design Database Schema]
    [Create API Endpoints]
    [Setup CI/CD Pipeline]
  In Progress
    [Implement Authentication]@{assigned: 'John'}
    [Build User Dashboard]@{assigned: 'Jane', priority: 'high'}
  In Review
    [Add Payment Integration]@{assigned: 'Bob', priority: 'high'}
  Done
    [Setup Development Environment]
    [Configure Deployment]
    [Initial Project Setup]
```

Code to analyze:
```%s
%s
```

Create a kanban board showing workflow and tasks.]],
    filetype, filetype, code_content)
end

-- ARCHITECTURE DIAGRAM PROMPT (C4)
M.build_architecture_prompt = function(filetype, code_content)
  return string.format([[Analyze this %s code and create a Mermaid ARCHITECTURE (C4) diagram.

DIAGRAM TYPE: C4 Architecture (System Context)
Use C4 when showing: system architecture, boundaries, relationships

SYNTAX RULES:
1. Start with: ```mermaid
2. Use directive: C4Context or C4Container or C4Component
3. Elements:
   - Person(id, "Name", "Description")
   - System(id, "Name", "Description")
   - Container(id, "Name", "Tech", "Description")
4. Relationships: Rel(from, to, "Description")

EXAMPLE:
```mermaid
C4Context
    title System Context Diagram for E-commerce Platform

    Person(customer, "Customer", "A user of the e-commerce platform")
    Person(admin, "Administrator", "Manages the platform")

    System(ecommerce, "E-commerce System", "Allows customers to browse and purchase products")
    System_Ext(payment, "Payment Gateway", "Handles payment processing")
    System_Ext(email, "Email System", "Sends emails to customers")

    Rel(customer, ecommerce, "Browses products and makes purchases")
    Rel(admin, ecommerce, "Manages products and orders")
    Rel(ecommerce, payment, "Processes payments")
    Rel(ecommerce, email, "Sends order confirmations")
```

Code to analyze:
```%s
%s
```

Create a C4 architecture diagram showing system context.]],
    filetype, filetype, code_content)
end

return M
