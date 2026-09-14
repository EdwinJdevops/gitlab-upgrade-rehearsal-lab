# AGENTS.md

## Mission

Prove or falsify the customer-state GitLab upgrade-replay hypothesis. Do not turn this repository into a generic GitLab administration toolkit.

## Hard constraints

- Never mutate production GitLab.
- Never add automatic production upgrade or rollback behavior.
- Never invent upgrade-path rules. Consume authoritative GitLab sources.
- Never emit "safe to upgrade" or equivalent language.
- Never serialize secret values into logs, fixtures, tests, or evidence.
- Never broaden v0 beyond single-node Linux-package GitLab without an accepted ADR.
- No AI/LLM decisions in the execution path.
- No SaaS dependency for sensitive state.
- Historical failures must be revalidated against current GitLab before being used as evidence of a gap.
- If a failure is cheaply detectable statically, prefer an upstream GitLab contribution.

## Engineering rules

- Change behavior through tests first when practical.
- Every external source used for execution must have provenance: URL/repository, revision or digest, retrieval time, and integrity hash where possible.
- Shell commands must use fixed executables and structured arguments; no string-built shell pipelines from untrusted input.
- Results use only the evidence vocabulary in ADR-0002.
- Unsupported conditions fail closed as `BLOCKED`, `UNKNOWN`, or `NOT_TESTED`.
- Keep dependencies minimal. New dependencies require a short justification in the PR.
- Documentation and experiment results are part of the product surface and must be updated with behavioral changes.

## Development sequence

1. Baseline current official GitLab tooling.
2. Reproduce a historical failure with a deterministic fixture.
3. Show whether baseline catches it.
4. Add replay only when baseline does not.
5. Measure incremental signal.
6. Repeat with a materially different failure class.
7. Hold go/no-go review before implementing a general CLI.
