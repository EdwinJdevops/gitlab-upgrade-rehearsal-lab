# ADR-0001: v0 scope is one narrow environment class

Status: Accepted

## Decision

v0 targets only single-node GitLab Self-Managed Linux-package installations.

Supported experiment boundary:

- one GitLab node
- Linux package / Omnibus
- local or bring-your-own-compute execution
- synthetic/sanitized fixtures first
- exact source version and CE/EE type
- supported GitLab upgrade path only

Not supported in v0:

- production mutation
- automated rollback
- Kubernetes/Helm
- Docker as a claimed production-equivalent Linux-package environment
- Geo
- HA/multi-node
- external PostgreSQL/Redis as a validated topology
- production object storage unless copied to an isolated rehearsal resource
- live runners or production CI execution
- SaaS execution
- AI-generated upgrade decisions

## Rationale

Expanding topology before proving incremental detection would create infrastructure breadth without validating the core hypothesis. Unsupported topology must return `NOT_TESTED` or `BLOCKED`, never a best-effort green result.
