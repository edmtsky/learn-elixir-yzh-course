**Authentication vs. Authorization**

- **Authentication (AuthN)**: Verifies *who you are*
  (e.g., username/password, biometrics, tokens).

- **Authorization (AuthZ)**: Determines *what you can access*
  (e.g., permissions, roles, policies).

**Short Names in Programming**:
- **AuthN**: Abbreviation for *Authentication*.
- **AuthZ**: Abbreviation for *Authorization*.

**Examples**:
- In OAuth 2.0: `Bearer` tokens (AuthN) and scopes/roles (AuthZ).
- In frameworks like Spring Security:
  `@PreAuthorize` (AuthZ) vs. login flows (AuthN).
- Headers: `Authorization: Bearer <token>` (AuthN) + policies (AuthZ).

**Key Takeaway**:
- **AuthN** = Identity check.
- **AuthZ** = Permission check.
