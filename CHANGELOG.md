# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/),
and this project adheres to [Semantic Versioning](https://semver.org/).

## [Unreleased]

### Added
- Agent autonomy rules with auto mode configuration
- PR standards: mandatory CHANGELOG, README, and API collection updates
- Documented `settings.json` auto mode setup in README

### Changed
- Reorganized agents into `founds/` (oracle, sentinel) and `experts/` (architect, dev-py, review-py, debater, tech-pm, explorer, builder)
- CLAUDE.md rewritten with founds/experts architecture, autonomy rules, and PR checklist
- README rewritten — project-agnostic, no references to specific downstream projects

### Removed
- `agents/slack-monitor.md` — unused
- `agents/memory-agent.md` — concept replaced by Mem0 MCP (planned)
- `agents/executor.md` — pipeline never used
- `agents/adapters/slack.md` — procedural doc with hardcoded paths, not an agent
- `skills/sre-observability.md` — single file, knowledge inlined into sentinel
