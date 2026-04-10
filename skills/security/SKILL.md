---
name: security
description: |
  Application security knowledge base (2026). Covers OWASP Top 10 (2021) with mitigations,
  zero trust architecture principles, STRIDE threat modeling, input validation and output encoding,
  authentication patterns (JWT, OAuth2, OIDC, MFA), authorization (RBAC, ABAC, ReBAC),
  secrets management (vault, rotation, never-hardcoded), cryptography standards (TLS 1.3,
  AES-256-GCM, Argon2), dependency and supply chain security, security testing (SAST, DAST,
  dependency scanning), and incident response basics.
  Use when: (1) Reviewing code for security issues, (2) Designing authentication/authorization,
  (3) Setting up secrets management, (4) Running threat modeling, (5) Responding to vulnerabilities.
  Triggers: /security, OWASP, authentication, authorization, STRIDE, secrets, CVE, vulnerability.
type: knowledge
---

# Security — Knowledge Base

## Purpose

This skill is the knowledge base for application security (2026).
It covers the threat landscape, authentication, authorization, secrets, cryptography,
and testing patterns needed to build secure systems.

**What this skill contains:**
- OWASP Top 10 (2021) with concrete mitigations
- Zero trust architecture principles
- STRIDE threat modeling
- Input validation and output encoding
- Authentication (JWT, OAuth2/OIDC, MFA, session management)
- Authorization (RBAC, ABAC, ReBAC)
- Secrets management (vault, rotation policy)
- Cryptography standards (what to use, what to avoid)
- Dependency and supply chain security
- Security testing (SAST, DAST, dependency scanning)
- Security review checklist

---

## Philosophy

### Security is a Design Constraint, Not an Afterthought

Security bugs are the most expensive to fix after deployment. Design principles:

1. **Defense in depth** — multiple independent layers; one failure doesn't compromise the system
2. **Least privilege** — every component has only the permissions it needs
3. **Assume breach** — design for containment, not just prevention
4. **Fail secure** — when a security check fails, deny access (never default-allow)
5. **Security by default** — insecure configurations require explicit opt-in, not vice versa

---

## 1. OWASP Top 10 (2021)

### A01 — Broken Access Control

**Risk:** Users accessing resources they should not.

```python
# GOOD: verify ownership at every data access
async def get_order(order_id: str, current_user: User) -> Order:
    order = await order_repo.get(order_id)
    if order is None:
        raise NotFoundError("Order", order_id)
    if order.user_id != current_user.id and not current_user.is_admin:
        raise ForbiddenError("You do not own this order")
    return order

# BAD: trust client-provided user_id in payload
# order = await order_repo.get_by_user(request.body.user_id, order_id)
```

**Mitigations:**
- Enforce authorization at the data layer, not just the route layer
- Never trust client-provided identity claims (user_id in body/query)
- Use parameterized queries — never raw SQL with user input
- Log all access control failures

### A02 — Cryptographic Failures

**Risk:** Sensitive data exposed due to weak or missing encryption.

| Use | Do NOT Use |
|-----|-----------|
| AES-256-GCM for symmetric encryption | AES-ECB (deterministic, reveals patterns) |
| Argon2id for passwords | MD5, SHA-1 for passwords |
| TLS 1.3 for transport | TLS 1.0/1.1, SSL |
| ECDSA / RSA-2048 for signatures | RSA-512 |
| HKDF / PBKDF2 for key derivation | Direct hash for key derivation |

```python
from argon2 import PasswordHasher
from argon2.exceptions import VerifyMismatchError

ph = PasswordHasher(
    time_cost=3,      # iterations
    memory_cost=65536, # 64 MB
    parallelism=4,
)

# Hash password on registration
hashed = ph.hash(plain_password)

# Verify on login
try:
    ph.verify(hashed, plain_password)
    if ph.check_needs_rehash(hashed):
        hashed = ph.hash(plain_password)  # upgrade parameters
except VerifyMismatchError:
    raise AuthenticationError("Invalid credentials")
```

### A03 — Injection

**Risk:** Attacker-controlled data interpreted as code (SQL, OS commands, LDAP, etc.).

```python
# GOOD: parameterized queries
async def get_user_by_email(email: str) -> User | None:
    return await db.fetchrow(
        "SELECT * FROM users WHERE email = $1",  # $1 is a parameter
        email,
    )

# BAD: string interpolation → SQL injection
# f"SELECT * FROM users WHERE email = '{email}'"

# GOOD: command execution — never shell=True with user input
import subprocess
result = subprocess.run(
    ["convert", "-resize", "800x600", input_path, output_path],
    capture_output=True,
    timeout=30,
    check=True,
)

# BAD: shell=True allows injection
# subprocess.run(f"convert {user_path}", shell=True)
```

### A04 — Insecure Design

**Mitigations:**
- Threat model every new feature (see STRIDE section)
- Define security requirements before implementation
- Use proven design patterns (do not invent custom crypto)
- Include security acceptance criteria in user stories

### A05 — Security Misconfiguration

```python
# Checklist for production configuration
assert settings.debug is False
assert settings.secret_key != "development-key"
assert settings.database_url.startswith("postgresql://")
assert "sslmode=require" in settings.database_url

# Disable verbose error messages in production
@app.exception_handler(Exception)
async def generic_error_handler(request: Request, exc: Exception):
    if settings.debug:
        raise exc  # show full traceback in dev
    # In production: log the error, return generic message
    logger.error("unhandled_exception", exc_info=True)
    return JSONResponse(
        status_code=500,
        content={"error": {"code": "INTERNAL_ERROR", "message": "An unexpected error occurred"}},
    )
```

### A06 — Vulnerable and Outdated Components

See [Dependency Security](#6-dependency-and-supply-chain-security) section.

### A07 — Identification and Authentication Failures

See [Authentication](#3-authentication) section.

### A08 — Software and Data Integrity Failures

```bash
# Verify checksums when downloading artifacts
curl -sL https://example.com/app.tar.gz | sha256sum -c expected.sha256

# Pin dependencies to exact versions (prevent supply chain attacks)
# requirements.txt
requests==2.32.3
# NOT requests>=2.32
```

### A09 — Security Logging and Monitoring Failures

```python
# Log all security events — structured, immutable, centralized
security_logger = structlog.get_logger("security")

def log_auth_attempt(email: str, success: bool, ip: str, user_agent: str) -> None:
    security_logger.info(
        "authentication_attempt",
        email=email,
        success=success,
        ip=ip,
        user_agent=user_agent,
        # Never log the password or token
    )

def log_access_denied(user_id: str, resource: str, action: str) -> None:
    security_logger.warning(
        "access_denied",
        user_id=user_id,
        resource=resource,
        action=action,
    )
```

### A10 — Server-Side Request Forgery (SSRF)

```python
import ipaddress
from urllib.parse import urlparse

ALLOWED_SCHEMES = {"https"}
BLOCKED_HOSTS = {"localhost", "127.0.0.1", "0.0.0.0", "169.254.169.254"}

def validate_external_url(url: str) -> str:
    """Validate URL is safe to fetch — prevents SSRF."""
    parsed = urlparse(url)

    if parsed.scheme not in ALLOWED_SCHEMES:
        raise ValidationError(f"URL scheme {parsed.scheme!r} not allowed")

    hostname = parsed.hostname or ""
    if hostname in BLOCKED_HOSTS:
        raise ValidationError("URL points to internal network")

    # Block private IP ranges
    try:
        addr = ipaddress.ip_address(hostname)
        if addr.is_private or addr.is_loopback or addr.is_link_local:
            raise ValidationError("URL points to internal network")
    except ValueError:
        pass  # hostname is a domain name, not an IP — OK

    return url
```

---

## 2. STRIDE Threat Modeling

### STRIDE Categories

| Threat | Description | Mitigation |
|--------|-------------|-----------|
| **S**poofing | Impersonating another user or system | Authentication, MFA, signed tokens |
| **T**ampering | Modifying data in transit or at rest | HMAC signatures, TLS, integrity checks |
| **R**epudiation | Denying an action occurred | Audit logging, digital signatures |
| **I**nformation Disclosure | Leaking sensitive data | Encryption, access control, data masking |
| **D**enial of Service | Exhausting resources | Rate limiting, circuit breakers, CDN |
| **E**levation of Privilege | Gaining unauthorized permissions | Least privilege, RBAC, input validation |

### Threat Modeling Process

```
1. IDENTIFY ASSETS
   - What data is sensitive? (PII, credentials, payment data, health data)
   - What operations are privileged? (admin actions, data deletion, payment)
   - What external integrations exist?

2. CREATE DATA FLOW DIAGRAM
   - Map all entry points (APIs, webhooks, queues)
   - Map all data stores (databases, caches, files)
   - Map all trust boundaries (internet, internal network, DMZ)

3. APPLY STRIDE PER COMPONENT
   - For each data flow: which STRIDE threats apply?
   - Rate each threat: Probability (H/M/L) × Impact (H/M/L)

4. DEFINE MITIGATIONS
   - One mitigation per identified threat
   - Verify mitigation in acceptance criteria

5. VALIDATE
   - Security tests cover each mitigation
   - Automated SAST/DAST in CI pipeline
```

---

## 3. Authentication

### JWT Best Practices

```python
from datetime import datetime, timedelta, timezone
import jwt

SECRET_KEY = settings.jwt_secret  # from env, min 256 bits
ALGORITHM = "HS256"
ACCESS_TOKEN_EXPIRE = timedelta(minutes=15)
REFRESH_TOKEN_EXPIRE = timedelta(days=7)

def create_access_token(user_id: str, roles: list[str]) -> str:
    now = datetime.now(tz=timezone.utc)
    payload = {
        "sub": user_id,
        "roles": roles,
        "iat": now,
        "exp": now + ACCESS_TOKEN_EXPIRE,
        "jti": secrets.token_urlsafe(16),  # unique token ID (for revocation)
    }
    return jwt.encode(payload, SECRET_KEY, algorithm=ALGORITHM)

def decode_and_validate_token(token: str) -> dict:
    try:
        payload = jwt.decode(token, SECRET_KEY, algorithms=[ALGORITHM])
    except jwt.ExpiredSignatureError:
        raise AuthenticationError("Token expired")
    except jwt.InvalidTokenError as e:
        raise AuthenticationError(f"Invalid token: {e}")

    # Check revocation list (Redis)
    if redis.exists(f"revoked:jti:{payload['jti']}"):
        raise AuthenticationError("Token has been revoked")

    return payload
```

### OAuth2 / OIDC

```
Flow selection:
  Public web app (SPA)     → Authorization Code + PKCE
  Server-side web app      → Authorization Code
  Machine-to-machine       → Client Credentials
  Native mobile app        → Authorization Code + PKCE
  Device (TV, CLI)         → Device Authorization

Scopes to request:
  Minimum required: openid, email
  Only request what you need
  Never store access tokens longer than needed
```

### MFA Requirements

```
When MFA is required:
- Admin panel access
- Payment operations
- Account settings changes (email, password)
- Data export/deletion
- API key creation

Accepted MFA methods (order of strength):
  FIDO2/WebAuthn (hardware key, passkey) — strongest
  TOTP (authenticator app)
  SMS OTP — weakest (SIM swap risk), avoid for high-value operations
```

---

## 4. Authorization

### RBAC (Role-Based Access Control)

```python
from enum import Enum

class Permission(Enum):
    USERS_READ = "users:read"
    USERS_WRITE = "users:write"
    USERS_DELETE = "users:delete"
    ORDERS_READ = "orders:read"
    ORDERS_WRITE = "orders:write"
    ADMIN = "admin:*"

ROLE_PERMISSIONS: dict[str, set[Permission]] = {
    "viewer": {Permission.USERS_READ, Permission.ORDERS_READ},
    "editor": {Permission.USERS_READ, Permission.USERS_WRITE, Permission.ORDERS_READ, Permission.ORDERS_WRITE},
    "admin": {p for p in Permission},  # all permissions
}

def has_permission(user: User, permission: Permission) -> bool:
    user_permissions: set[Permission] = set()
    for role in user.roles:
        user_permissions |= ROLE_PERMISSIONS.get(role, set())
    return permission in user_permissions or Permission.ADMIN in user_permissions
```

### Authorization Rules

```
1. Authorization checks at every layer — route handler AND data access layer
2. Deny by default — no permission means no access (never default-allow)
3. Check ownership — user.id == resource.owner_id for non-admin operations
4. Audit trail — log every denied access attempt
5. Separate read from write permissions — read is cheap to grant, write is not
```

---

## 5. Secrets Management

### Rules (Non-Negotiable)

```
1. NEVER hardcode secrets in code
2. NEVER commit secrets to git (even private repos)
3. NEVER log secrets (API keys, tokens, passwords)
4. NEVER pass secrets via URL parameters
5. NEVER store secrets in client-side code (JavaScript bundle, mobile app)
```

### Secret Storage Hierarchy

| Environment | Store | Access Pattern |
|-------------|-------|---------------|
| Local dev | `.env` (gitignored) + `.env.example` | Direct env vars |
| CI/CD | Platform secrets (GitHub Actions secrets) | Injected as env vars |
| Production | HashiCorp Vault / AWS Secrets Manager | SDK with short-lived tokens |
| Database passwords | Vault dynamic secrets | Rotated automatically |

### Rotation Policy

```
API keys: rotate every 90 days
JWT signing keys: rotate every 30 days
Database passwords: rotate every 30 days (Vault dynamic secrets)
TLS certificates: auto-rotate via cert-manager / Let's Encrypt
After any suspected exposure: rotate immediately
```

### Python: pydantic-settings for Secrets

```python
from pydantic import Field, SecretStr
from pydantic_settings import BaseSettings

class Settings(BaseSettings):
    # SecretStr: value is masked in logs/repr
    database_password: SecretStr
    api_key: SecretStr
    jwt_secret: SecretStr = Field(min_length=32)

    def get_database_url(self) -> str:
        # .get_secret_value() only where needed
        return f"postgresql://user:{self.database_password.get_secret_value()}@host/db"
```

---

## 6. Dependency and Supply Chain Security

### Automated Scanning

```yaml
# .github/workflows/security.yml
name: Security Scan
on: [push, pull_request, schedule]
  cron: "0 6 * * 1"  # weekly on Monday

jobs:
  dependency-scan:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      # Python — pip-audit
      - run: pip install pip-audit
      - run: pip-audit --requirement requirements.txt --strict

      # Node.js — pnpm audit
      - run: pnpm audit --audit-level moderate

      # Container images — Trivy
      - name: Trivy vulnerability scan
        uses: aquasecurity/trivy-action@master
        with:
          image-ref: myapp:latest
          exit-code: "1"
          severity: "CRITICAL,HIGH"

      # SAST — Semgrep
      - name: Semgrep SAST
        uses: semgrep/semgrep-action@v1
        with:
          config: auto
```

### Dependency Rules

```
1. Pin exact versions — never >=, ~=, or ^
2. Audit new dependencies before adding (check CVE history, maintenance status)
3. Prefer small, focused libraries over large frameworks (smaller attack surface)
4. Check package name for typosquatting (requests vs requets)
5. Verify checksums for downloaded artifacts
6. Run dependency audit in CI on every PR and weekly schedule
```

---

## 7. Security Testing

### SAST (Static Analysis)

```bash
# Python
bandit -r src/ -ll  # severity LOW+
semgrep --config=auto src/

# TypeScript/JavaScript
eslint --plugin security src/

# Multi-language
semgrep --config=p/owasp-top-ten .
```

### DAST (Dynamic Analysis)

```bash
# OWASP ZAP — passive scan against running app
docker run -t owasp/zap2docker-stable zap-baseline.py \
  -t http://localhost:8000 \
  -r zap-report.html \
  -I  # ignore warnings for CI (exit 0)

# For CI: fail on medium+ severity
docker run -t owasp/zap2docker-stable zap-baseline.py \
  -t http://localhost:8000 \
  --exit-code 2  # fail on MEDIUM+
```

### Security Testing Checklist

```markdown
### Authentication
- [ ] Test expired token → 401
- [ ] Test invalid token signature → 401
- [ ] Test token reuse after logout → 401
- [ ] Test brute force (rate limiting kicks in)

### Authorization
- [ ] Test user A accessing user B's resource → 403
- [ ] Test unauthorized role performing privileged action → 403
- [ ] Test missing auth header → 401
- [ ] Test elevated privilege after role downgrade

### Injection
- [ ] SQL injection in all text inputs
- [ ] OS command injection in path/filename inputs
- [ ] XSS in all user-controlled output

### Secrets
- [ ] No secrets in git history
- [ ] No secrets in logs
- [ ] No secrets in API responses
- [ ] Secrets rotated in staging/production
```

---

## Security Review Checklist

```markdown
### Input Validation
- [ ] All external inputs validated at boundaries (Pydantic, zod, etc.)
- [ ] No SQL/command injection possible (parameterized queries, subprocess list)
- [ ] File uploads validated (type, size, content inspection)
- [ ] URL inputs validated against SSRF (private IP ranges blocked)

### Authentication
- [ ] Passwords hashed with Argon2id (never MD5/SHA-1)
- [ ] JWTs short-lived (<= 15 min access, <= 7 day refresh)
- [ ] MFA required for privileged operations
- [ ] Brute force protection (rate limiting on auth endpoints)

### Authorization
- [ ] Every endpoint has an authorization check
- [ ] Resource ownership verified (not just role)
- [ ] Default-deny (no permission = no access)
- [ ] Access denial logged

### Secrets
- [ ] No secrets in code or git
- [ ] Secrets loaded from environment / vault
- [ ] SecretStr used in Python settings
- [ ] Rotation schedule defined

### Cryptography
- [ ] Argon2id for passwords
- [ ] AES-256-GCM for encryption
- [ ] TLS 1.3 for all transport
- [ ] No custom crypto

### Dependencies
- [ ] Exact versions pinned
- [ ] Dependency audit passes in CI
- [ ] No known CVEs with CRITICAL or HIGH severity

### Logging
- [ ] Security events logged (auth, access denied, data export)
- [ ] No sensitive data in logs (passwords, tokens, PII)
- [ ] Logs are immutable and shipped to SIEM
```

---

## Reference Files

- [references/owasp-top-10.md](references/owasp-top-10.md) — OWASP Top 10 detailed mitigations
- [references/authentication.md](references/authentication.md) — JWT, OAuth2/OIDC, session management
- [references/authorization.md](references/authorization.md) — RBAC, ABAC, ReBAC patterns
- [references/secrets-management.md](references/secrets-management.md) — Vault patterns, rotation
- [references/cryptography.md](references/cryptography.md) — Algorithms, key management
- [references/threat-modeling.md](references/threat-modeling.md) — STRIDE process, templates
- [references/security-testing.md](references/security-testing.md) — SAST, DAST, penetration testing
