# Multi-Agent Peer Coordination Protocol

## Lifecycle: Claim → Work → Report → Release

### 1. Claim
- Agent stores claim in Mem0: `{task_id, agent_id, status: "claimed", timestamp}`
- Check for existing claims before starting (prevent duplicate work)
- Claims expire after timeout (e.g., 30 minutes without update)

### 2. Work
- Agent works in isolated worktree
- Periodic heartbeat updates to Mem0
- Log progress for observability

### 3. Report
- Agent stores result in Mem0: `{task_id, status: "completed", result_summary, branch}`
- If failed: `{task_id, status: "failed", error, retry_count}`

### 4. Release
- Agent cleans up: worktree removed (if no changes) or branch pushed
- Mem0 claim updated to released

## Coordination Patterns
- **Fan-out**: Oracle spawns N agents in parallel, each on independent subtask
- **Pipeline**: Agent A output feeds Agent B input
- **Review loop**: dev agent → review agent → dev agent (if changes needed)
