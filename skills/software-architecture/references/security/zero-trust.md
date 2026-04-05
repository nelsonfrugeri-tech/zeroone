# Security Architecture

## Zero Trust Principles
1. **Never trust, always verify** — every request is authenticated and authorized
2. **Least privilege** — minimum access needed for the task
3. **Assume breach** — design for containment, not just prevention
4. **Verify explicitly** — identity, device, location, data classification

## Defense in Depth
```
Layer 1: Network (firewalls, segmentation, mTLS)
Layer 2: Identity (authn, authz, MFA, JWT validation)
Layer 3: Application (input validation, CSRF, CORS, rate limiting)
Layer 4: Data (encryption at rest, encryption in transit, masking)
Layer 5: Monitoring (audit logs, anomaly detection, SIEM)
```

## STRIDE Threat Modeling
| Threat | Property violated | Mitigation |
|--------|------------------|------------|
| Spoofing | Authentication | MFA, strong auth |
| Tampering | Integrity | Input validation, signing |
| Repudiation | Non-repudiation | Audit logging |
| Information disclosure | Confidentiality | Encryption, access control |
| Denial of service | Availability | Rate limiting, CDN |
| Elevation of privilege | Authorization | RBAC, least privilege |

## Implementation Checklist
- [ ] TLS everywhere (no HTTP)
- [ ] JWT validation on every request
- [ ] RBAC/ABAC for authorization
- [ ] Input sanitization at boundaries
- [ ] Secrets in vault, never in code/config
- [ ] Dependency scanning (Snyk, Dependabot)
- [ ] Audit logging for sensitive operations
