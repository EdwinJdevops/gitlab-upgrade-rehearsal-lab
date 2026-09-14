# Historical upgrade-failure corpus

This corpus is an experiment input, not a claim that each historical bug remains unfixed.

For every case, first ask: **does current GitLab tooling already catch this?** If yes, classify it as absorbed/baseline-detected and do not claim project value from it.

See [`corpus-triage-2026-09-14.md`](corpus-triage-2026-09-14.md) for the current evidence review and preliminary dispositions.

| ID | Historical class | Public reference | What it tests | Current research direction |
|---|---|---|---|---|
| GL-9916 | target-version configuration false negative | https://gitlab.com/gitlab-org/omnibus-gitlab/-/work_items/9916 | whether target-version checks can miss removed configuration | absorbed upstream; regression history only |
| GL-10001 | stale configuration false positive | https://gitlab.com/gitlab-org/omnibus-gitlab/-/issues/10001 | whether checks distinguish active config from stale historical state | absorbed upstream; regression history only |
| GL-8048 | data-dependent migration constraint failure | https://gitlab.com/gitlab-org/omnibus-gitlab/-/issues/8048 | whether current seeded multi-version migration tests reproduce the class | insufficient evidence; baseline comparison required |
| GET-1023 | generated readiness URL regression | https://gitlab.com/gitlab-org/gitlab-environment-toolkit/-/issues/1023 | automation regression | absorbed upstream; not customer-state differentiation |
| GET-1047 | Geo secondary write against read-only DB | https://gitlab.com/gitlab-org/gitlab-environment-toolkit/-/issues/1047 | topology-dependent action | unsupported v0; fail closed |
| GL-590848 / 591056 | single-record BBM leaves state unbackfilled before 18.9 constraints | https://gitlab.com/gitlab-org/gitlab/-/issues/591056 | whether finished migration metadata can disagree with actual customer data | fixed/backported and documented; baseline signal |
| GL-605197 | `keys.organization_id` NOT NULL failure on Self-Managed/Dedicated | https://gitlab.com/gitlab-org/gitlab/-/work_items/605197 | customer-state divergence: orphan/deleted-user keys skipped by prior backfill | absorbed upstream; high-value historical replay fixture |
| GL-603303 | `web_hook_logs_daily` constraint fails during fast chained upgrade | https://gitlab.com/gitlab-org/gitlab/-/work_items/603303 | interaction of orphan state, partition retention time, and migration sequencing | absorbed upstream; high-value historical replay fixture |
| GL-605940 | hard-FK child backfill fails on orphaned LFK-backed parent state | https://gitlab.com/gitlab-org/gitlab/-/merge_requests/246021 | async cleanup backlog + historical parent state + migration constraint interaction | insufficient evidence; high-priority triage |
| OMNIBUS-10025 | corrective action to expand E2E upgrade CI | https://gitlab.com/gitlab-org/omnibus-gitlab/-/work_items/10025 | vendor counter-signal: Linux-package and Docker upgrade CI is actively expanding | baseline evolution; monitor, do not duplicate |

## Modern baseline to compare against

The experiment must account for current GitLab capabilities, not historical assumptions:

- GitLab Detective released read-only diagnostics; do not count draft upgrade-alert mode as released
- official `upgrade_path.yml`
- Support Upgrade Path `path.json` and `alerts.yml`
- `gitlab-ctl check-config --version ...`
- `gitlab-rake gitlab:check`
- `gitlab-rake gitlab:doctor:secrets`
- background migration checks
- `db:migrate:multi-version-upgrade` with seeded PostgreSQL dumps
- `pg-dump-generator` / Data Seeder fixture coverage
- GitLab QA `UpdateFromPrevious` / `UpdateToNext`
- GitLab's documented clone-of-production upgrade and rollback rehearsal guidance

## Required measurements per fixture

Record:

- exact source/target GitLab versions and edition
- vendor-tool revisions/digests used for the baseline
- whether current baseline detects the problem before upgrade execution
- whether isolated state replay detects anything additional
- false-positive / false-negative behavior
- exact failing operation and assertion
- minimum state needed to reproduce
- whether the failure can become a deterministic upstream check or seeded regression
- reconstruction/restoration duration
- storage/compute requirements
- privilege and secret requirements
- whether sanitized synthetic state is sufficient
- fidelity limitations

## Current gate

As of the 2026-09-14 triage, **zero current `candidate_replay_escape` cases have been proven**.

The repository therefore remains in M0 research. Do not build the general replay engine until issue #3 demonstrates a current baseline escape and issue #6's gate opens.
