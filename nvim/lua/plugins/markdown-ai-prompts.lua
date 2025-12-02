-- Mermaid diagram prompts for different diagram types
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
    style Start fill:%s,stroke:%s,stroke-width:3px,color:#fff
    style End fill:%s,stroke:%s,stroke-width:3px,color:#fff
    style Process fill:%s,stroke:%s,stroke-width:2px,color:#000
    style Decision fill:%s,stroke:%s,stroke-width:2px,color:#000
    style API fill:%s,stroke:%s,stroke-width:2px,color:#000
    style Success fill:%s,stroke:%s,stroke-width:2px,color:#000
    style Error fill:%s,stroke:%s,stroke-width:2px,color:#000
    style UserAction fill:%s,stroke:%s,stroke-width:2px,color:#000]],
    M.colors.primary, M.colors.primary,
    M.colors.primary, M.colors.primary,
    M.colors.primary_light, M.colors.primary,
    M.colors.warning_light, M.colors.warning,
    M.colors.secondary_light, M.colors.secondary,
    M.colors.success_light, M.colors.success,
    M.colors.danger_light, M.colors.danger,
    M.colors.info_light, M.colors.info
  )
end

-- Class diagram style (uses default Mermaid styling)
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
   - Start/End: Start([Begin Process])
   - Process: Process[Do Something]
   - Decision: Decision{Condition?}
   - Parallel: Parallel[/Parallel Process/]
4. Arrows:
   - Normal flow: -->
   - Thick flow: ==>
   - Conditional: -->|Yes| or -->|No|
5. End with: ```

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

EXAMPLE:
```mermaid
flowchart TD
    Start([User Request]) ==> Validate[Validate Input]
    Validate --> CheckAuth{Authenticated?}

    CheckAuth -->|Yes| Process[Process Request]
    CheckAuth -->|No| Error[Return 401 Error]

    Process ==> CallAPI[Call External API]
    CallAPI --> CheckResponse{Response OK?}

    CheckResponse -->|Yes| Success[Return Success]
    CheckResponse -->|No| Retry{Retry Count < 3?}

    Retry -->|Yes| CallAPI
    Retry -->|No| Error

    Success ==> End([Complete])
    Error --> End

%s
```

Code to analyze:
```%s
%s
```

Create a clear flowchart showing the process flow with proper arrow emphasis.]],
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

    Client->>+API: POST /api/data
    Note over Client,API: Request with auth token

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
    }

    class Admin {
        +String[] permissions
        +manageUsers() void
    }

    class Session {
        +String token
        +Date expiresAt
        +isValid() boolean
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
        ValidatingData --> [*]
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
3. Entities: EntityName { type attribute }
4. Relationships:
   - One to One: Entity1 ||--|| Entity2 : relationship
   - One to Many: Entity1 ||--o{ Entity2 : relationship
   - Many to Many: Entity1 }o--o{ Entity2 : relationship

EXAMPLE:
```mermaid
erDiagram
    USER ||--o{ ORDER : places
    ORDER ||--|{ LINE_ITEM : contains
    PRODUCT ||--o{ LINE_ITEM : "ordered in"

    USER {
        int id PK
        string email
        string name
        datetime created_at
    }

    ORDER {
        int id PK
        int user_id FK
        decimal total
        datetime created_at
    }

    PRODUCT {
        int id PK
        string name
        decimal price
    }

    LINE_ITEM {
        int id PK
        int order_id FK
        int product_id FK
        int quantity
    }
```

Code to analyze:
```%s
%s
```

Create an ER diagram showing database structure.]],
    filetype, filetype, code_content)
end

return M
