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

-- Class diagram style
M.get_class_diagram_styles = function()
  return [[
    classDef primary fill:#dbeafe,stroke:#1e40af,stroke-width:2px
    classDef secondary fill:#cffafe,stroke:#0891b2,stroke-width:2px
    classDef interface fill:#e0e7ff,stroke:#6366f1,stroke-width:2px,stroke-dasharray: 5 5]]
end

-- System message for all providers
M.get_system_message = function()
  return [[You are a Mermaid diagram generator.

CRITICAL RULES:
1. You MUST ONLY output valid Mermaid diagram syntax
2. You MUST wrap output in ```mermaid ... ``` code blocks
3. DO NOT include any explanations, descriptions, or text outside the code block
4. DO NOT write "Here's the diagram" or similar phrases
5. DO NOT explain what the diagram shows
6. ONLY output the Mermaid code block, nothing else

If you output anything other than a Mermaid code block, you have failed.]]
end

-- FLOWCHART PROMPT
M.build_flowchart_prompt = function(filetype, code_content, complexity)
  local max_nodes = complexity == "simple" and 30 or (complexity == "moderate" and 50 or 80)

  return string.format(
    [[IMPORTANT: Respond ONLY with a Mermaid code block. NO explanations, NO text outside the code block.

Your response must start with ```mermaid and end with ```. Nothing before, nothing after.

Task: Create a Mermaid FLOWCHART for this %s code.

DIAGRAM TYPE: flowchart TD

SYNTAX (FOLLOW EXACTLY):
```mermaid
flowchart TD
    Start([Begin]) ==> Step1[Process]
    Step1 --> Decision{Check?}
    Decision -->|Yes| Success[Done]
    Decision -->|No| Error[Failed]

    style Start fill:#1e40af,stroke:#1e40af,stroke-width:3px,color:#fff
    style Decision fill:#fed7aa,stroke:#d97706,stroke-width:2px,color:#000
```

REQUIREMENTS:
- Max %d nodes
- Use --> for normal flow, ==> for main path
- Simple node IDs: Start, CheckAuth, LoadData, etc.
- Apply color styles at the end
- NO text outside the code block

COLOR STYLES TO USE:
%s

Code to analyze:
```%s
%s
```

REMEMBER: Output ONLY the ```mermaid code block. NO explanations.]],
    filetype, max_nodes, M.get_flowchart_styles(), filetype, code_content)
end

-- SEQUENCE DIAGRAM PROMPT
M.build_sequence_prompt = function(filetype, code_content)
  return string.format([[IMPORTANT: Respond ONLY with a Mermaid code block. NO explanations.

Your entire response must be ONLY:
```mermaid
sequenceDiagram
    [diagram content]
```

Nothing else. No text before or after the code block.

Task: Create a Mermaid SEQUENCE diagram for this %s code.

SYNTAX EXAMPLE:
```mermaid
sequenceDiagram
    participant User
    participant Client
    participant API

    User->>+Client: Click Button
    Client->>+API: POST /data
    API-->>-Client: 200 OK
    Client-->>-User: Show Success
```

REQUIREMENTS:
- Show time-based interactions
- Use ->> for calls, -->> for responses
- Add + for activate, - for deactivate
- Use alt/opt for conditional flows

Code to analyze:
```%s
%s
```

OUTPUT: Only the ```mermaid code block, nothing else.]],
    filetype, filetype, code_content)
end

-- CLASS DIAGRAM PROMPT
M.build_class_diagram_prompt = function(filetype, code_content)
  return string.format([[IMPORTANT: Output ONLY the Mermaid code block. NO explanations.

Format:
```mermaid
classDiagram
    [diagram content]
```

Task: Create a Mermaid CLASS diagram for this %s code.

SYNTAX EXAMPLE:
```mermaid
classDiagram
    class User {
        +String id
        +String name
        +login() boolean
    }

    class Admin {
        +String[] permissions
    }

    User <|-- Admin

    class User:::primary
```

STYLING:
%s

Code to analyze:
```%s
%s
```

OUTPUT: Only ```mermaid block.]],
    filetype, M.get_class_diagram_styles(), filetype, code_content)
end

-- STATE DIAGRAM PROMPT
M.build_state_diagram_prompt = function(filetype, code_content)
  return string.format([[IMPORTANT: Output ONLY Mermaid code. NO explanations.

Task: Create a STATE diagram for this %s code.

SYNTAX:
```mermaid
stateDiagram-v2
    [*] --> Idle
    Idle --> Loading : Start
    Loading --> Success : Done
    Loading --> Error : Failed
    Success --> [*]
    Error --> [*]
```

Code:
```%s
%s
```

OUTPUT: Only ```mermaid block.]],
    filetype, filetype, code_content)
end

-- ER DIAGRAM PROMPT
M.build_er_diagram_prompt = function(filetype, code_content)
  return string.format([[IMPORTANT: Output ONLY Mermaid code.

Task: Create ER diagram for this %s code.

SYNTAX:
```mermaid
erDiagram
    USER ||--o{ ORDER : places
    ORDER ||--|{ LINE_ITEM : contains

    USER {
        int id PK
        string email
    }
```

Code:
```%s
%s
```

OUTPUT: Only ```mermaid block.]],
    filetype, filetype, code_content)
end

return M
