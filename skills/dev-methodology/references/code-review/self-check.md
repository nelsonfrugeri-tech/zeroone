# Pre-Submission Self-Check

## Before Opening a PR

### Qualidade de Código
- [ ] All tests pass locally
- [ ] No debug/print statements left
- [ ] No commented-out code
- [ ] No TODO without a linked issue
- [ ] No hardcoded values that should be config
- [ ] Error handling covers edge cases

### Security
- [ ] No secrets/credentials in code
- [ ] Input validation at boundaries
- [ ] No SQL injection vectors
- [ ] No XSS vectors (if frontend)

### Testes
- [ ] New code has tests
- [ ] Edge cases covered (empty, null, boundary)
- [ ] Error paths tested
- [ ] Tests are deterministic (no flaky)

### Documentação
- [ ] CHANGELOG updated
- [ ] README updated (if behavior changed)
- [ ] Complex logic has inline comments
- [ ] Public API documented

### Higiene de Git
- [ ] Commits are logical units (not "fix" or "wip")
- [ ] Branch is rebased on latest main
- [ ] No merge commits in feature branch
- [ ] PR description explains WHY, not just WHAT

### Performance
- [ ] No N+1 queries introduced
- [ ] No unbounded collections in memory
- [ ] Pagination for list endpoints
