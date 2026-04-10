# Pair and Mob Programming

## Pair Programming Styles

### Driver-Navigator (Classic)

```
Driver:    Writes code, handles the tactical
Navigator: Watches, thinks strategically, catches issues
           ↕ Switch every 15-25 minutes
```

**Best for:** General development, code review alternative.

### Ping-Pong (TDD-native)

```
Developer A: Writes a failing test
Developer B: Makes it pass, then writes the next failing test
Developer A: Makes it pass, then writes the next failing test
             ↕ Natural switching on each RED-GREEN cycle
```

**Best for:** TDD practice, learning, balanced contribution.

### Strong-Style

```
Navigator: Dictates exactly what to type
Driver:    Types only what is dictated, asks questions
           "For an idea to go from your head into the computer,
            it MUST go through someone else's hands"
```

**Best for:** Teaching, onboarding, knowledge transfer.

## When to Pair

| Situation | Pair? | Why |
|-----------|-------|-----|
| Onboarding | Yes | Knowledge transfer |
| Complex logic | Yes | Two brains, fewer bugs |
| Stuck > 30 min | Yes | Fresh perspective |
| Routine CRUD | No | Not enough complexity |
| Spikes | Maybe | Depends on familiarity |
| Debugging | Yes | Rubber duck + expertise |

## Mob Programming

### Setup
- One screen, one keyboard
- Whole team present
- Rotate driver every 10-15 minutes
- Timer visible to everyone

### Roles
- **Driver:** Types ONLY what the mob says
- **Navigator(s):** Direct the driver, discuss approach
- **Facilitator:** Manages rotation, keeps focus, ensures participation

### Rules
1. Treat everyone's ideas with respect
2. "Yes, and..." over "No, but..."
3. If stuck, take a 5-minute break
4. Breaks every 50 minutes
5. Everyone participates (no spectators)
6. Trust the process — it feels slow but produces quality

### When to Mob
- Architectural decisions the whole team needs to understand
- Complex integrations touching multiple subsystems
- Team alignment on new patterns or conventions
- Spikes where collective knowledge is valuable
- Code review of critical changes (live review)
