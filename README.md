# GitLab Upgrade Rehearsal Lab

> **Status: research / validation only. Not production-ready.**
>
> This repository exists to test one hypothesis: whether replaying a supported GitLab Self-Managed upgrade against stateful, production-derived or synthetic historical state reveals failures that GitLab's current documented prechecks and test machinery do not detect.

This is **not** another upgrade-path calculator, vulnerability scanner, package-upgrade wrapper, health dashboard, backup tool, or replacement for GitLab Detective, GitLab QA, GitLab Environment Toolkit, or GitLab Support.

## Research question

Given a GitLab source state `S`, source version `V1`, target version `V2`, and a supported GitLab upgrade path, can an isolated replay discover materially important, state-dependent upgrade failures that current static/preflight mechanisms miss?

The only acceptable output is evidence about what was actually tested. The project must never claim that an upgrade is "safe".

## Current decision

**Do not productize yet.** First prove the gap.

We continue only if multiple materially different historical failure classes:

1. are not caught by current documented GitLab prechecks;
2. are reproducible through automated isolated replay;
3. cannot reasonably be reduced to cheap deterministic checks that belong upstream in GitLab;
4. can be tested without sending sensitive customer state to a third party; and
5. share enough infrastructure that one reusable harness detects them.

If those conditions are not met, the correct outcome is to stop this project and upstream any useful deterministic checks or regression tests.

## v0 scope

- GitLab Self-Managed installed with the Linux package (Omnibus)
- single-node only
- non-Geo
- non-HA
- production source is read-only
- isolated rehearsal environment
- synthetic/sanitized fixtures first
- official GitLab upgrade path and official checks only
- explicit evidence states: `VERIFIED`, `BLOCKED`, `UNKNOWN`, `NOT_TESTED`

## Explicit non-goals

- no production upgrade execution
- no automatic rollback
- no SaaS control plane
- no upload of customer backups or `gitlab-secrets.json` to a third party
- no Kubernetes/Helm support in v0
- no multi-node, Geo, or HA in v0
- no AI/LLM decision-making in the execution path
- no independent upgrade-rule database
- no CVE scanner
- no claim of "safe to upgrade"

## Why this repository exists

GitLab already owns authoritative upgrade-path data, upgrade alerts, GitLab Detective, migration tests, GitLab QA upgrade scenarios, and environment tooling. The unresolved question is narrower: static knowledge and seeded fixtures cannot necessarily model every customer's historical database state, configuration, topology, secrets, object-storage usage, and external integrations.

The project earns the right to exist only if isolated state replay provides measurable signal beyond those official mechanisms.

## First milestone: prove or kill the thesis

See [`docs/rfc/0001-validation-thesis.md`](docs/rfc/0001-validation-thesis.md), [`docs/research/baseline-2026-09-14.md`](docs/research/baseline-2026-09-14.md), and [`docs/research/failure-corpus.md`](docs/research/failure-corpus.md).

No production-facing feature work is permitted before the go/no-go review.

## Sources of truth

The project consumes, but does not fork, GitLab-maintained sources including:

- https://gitlab.com/gitlab-org/gitlab/-/blob/master/config/upgrade_path.yml
- https://gitlab.com/gitlab-com/support/toolbox/upgrade-path
- https://gitlab.com/gitlab-com/support/toolbox/gitlab-detective
- https://gitlab.com/gitlab-org/gitlab-qa
- https://docs.gitlab.com/update/plan_your_upgrade/
- https://docs.gitlab.com/development/database/dbmigrate_multi_version_upgrade_job/

## License

Apache-2.0. This project is unofficial and is not affiliated with or endorsed by GitLab Inc.
