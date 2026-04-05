# Cross-Project Context Management

## Mem0 as Shared Memory
- Each project has its own Mem0 namespace
- Cross-project queries search all namespaces
- Oracle maintains the mapping: project → directory → Mem0 namespace

## Context Sharing Patterns
- **Skill reuse**: skills are project-agnostic, shared across all projects
- **Pattern transfer**: architectural decisions from project A inform project B
- **Dependency awareness**: changes in shared libs affect downstream projects

## Rules
1. Never store project-specific paths in skills (use environment variables)
2. Cross-project memories are read-only references, not mandates
3. Each project's context is authoritative for that project
