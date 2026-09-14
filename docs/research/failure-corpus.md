# Historical upgrade-failure corpus

This corpus is an experiment input, not evidence that a historical defect still exists.

For every case, ask first: **does the frozen current GitLab baseline already catch, prevent, document, or regression-test this condition?** If yes, do not claim replay value from it.

See [`corpus-triage-2026-09-14.md`](corpus-triage-2026-09-14.md) for the current evidence review and dated dispositions.

| ID | Historical class | Public reference | What it tests | Current M0 disposition |
|---|---|---|---|---|
| GL-9916 | target-version configuration false negative | https://gitlab.com/gitlab-org/omnibus-gitlab/-/work_items/9916 | whether target-version checks can miss removed configuration | `absorbed_upstream`; regression history only |
| GL-10001 | stale configuration false positive | https://gitlab.com/gitlab-org/omnibus-gitlab/-/issues/10001 | whether checks distinguish active config from stale historical state | `absorbed_upstream`; regression history only |
| GL-8048 | data-dependent migration constraint failure | https://gitlab.com/gitlab-org/omnibus-gitlab/-/issues/8048 | whether current seeded multi-version migration tests reproduce the failure class | `insufficient_evidence`; current reproduction still required |
| GET-1023 | generated readiness URL regression | https://gitlab.com/gitlab-org/gitlab-environment-toolkit/-/issues/1023 | upgrade-automation regression | `absorbed_upstream`; not customer-state differentiation |
| GET-1047 | Geo secondary write against read-only DB | https://gitlab.com/gitlab-org/gitlab-environment-toolkit/-/issues/1047 | topology-dependent behavior | `unsupported_v0`; reject rather than approximate |
| GL-590848 / GL-591056 | single-record BBM leaves state unbackfilled before later constraints | https://gitlab.com/gitlab-org/gitlab/-/issues/591056 | whether migration metadata can disagree with actual data | `baseline_detected` + `absorbed_upstream` |
| GL-605197 | `keys.organization_id` NOT NULL failure on Self-Managed/Dedicated | https://gitlab.com/gitlab-org/gitlab/-/work_items/605197 | skipped orphan/deleted-user state from prior backfill | `absorbed_upstream`; historical calibration fixture |
| GL-603303 | `web_hook_logs_daily` validation fails during fast chained upgrade | https://gitlab.com/gitlab-org/gitlab/-/work_items/603303 | orphan state + partition retention + migration sequencing | `absorbed_upstream` for the blocking defect; temporal-state fixture |
| GL-605940 | loose-FK parent state copied into hard-FK child | https://gitlab.com/gitlab-org/gitlab/-/merge_requests/246021 | async cleanup backlog + orphan parent + hard-FK child migration | `absorbed_upstream` for patched maintained lines; highest-value calibration fixture |
| OMNIBUS-10025 | corrective action to expand E2E upgrade CI | https://gitlab.com/gitlab-org/omnibus-gitlab/-/work_items/10025 | vendor counter-signal: Linux-package/Docker upgrade CI is expanding | baseline evolution; monitor, do not duplicate |

## Frozen baseline

M0 does not compare fixtures against vague "current GitLab" behavior. The control group is frozen in:

- [`baseline-provenance-2026-09-14.md`](baseline-provenance-2026-09-14.md)
- [`baseline-capture-2026-09-14.md`](baseline-capture-2026-09-14.md)

The baseline includes:

- authoritative `config/upgrade_path.yml` required-stop semantics;
- Support Upgrade Path `path.json` and `alerts.yml`;
- released GitLab Detective diagnostics, without crediting draft upgrade-alert behavior;
- `gitlab-ctl check-config --version ...`;
- `gitlab-rake gitlab:check`;
- `gitlab-rake gitlab:doctor:secrets`;
- background-migration completion checks;
- `db:migrate:multi-version-upgrade` using a PostgreSQL dump seeded from the latest required stop;
- `pg-dump-generator` / Data Seeder fixture generation;
- GitLab QA `UpdateFromPrevious` and `UpdateToNext` scenarios;
- GitLab's documented production-clone rehearsal, restore, and rollback guidance.

The mutable machine-readable inputs used by this M0 checkpoint have byte-level retrieval timestamps and SHA-256 digests recorded in the baseline-capture document. Future experiments must either use that frozen control or create a new capture. Silent use of moving URLs is not acceptable evidence.

## Required measurements per fixture

Record:

- exact source and target GitLab versions and edition;
- exact vendor-input revisions or digests;
- minimum synthetic state required to reproduce the condition;
- whether the frozen baseline detects the condition before the failing transition;
- whether isolated replay detects anything additional;
- exact failing operation, migration, constraint, or assertion;
- false-positive / false-negative behavior;
- whether the condition is better represented as an upstream deterministic check or seeded regression;
- reconstruction/restoration duration;
- storage and compute requirements;
- privilege and secret requirements;
- whether sanitized synthetic state is sufficient;
- fidelity limitations.

## Calibration versus differentiation

A historical fixture can be useful even when the original defect is fixed, but only for calibration.

GL-605940 is currently the strongest calibration candidate because GitLab publishes both a precise synthetic orphan-state reproduction and the patched behavior. A correct rehearsal harness should be able to reproduce the failure on an affected pre-fix revision and demonstrate that it disappears on the patched revision.

That result would validate the harness. It would **not** prove a current product gap.

A `candidate_replay_escape` requires all of the following:

1. the condition is reproducible on a currently relevant source/target path;
2. the frozen official baseline does not establish the problem before transition execution;
3. isolated state replay does expose it;
4. the failure is materially state-dependent rather than an unsupported path, known alert, or static configuration rule;
5. the result is not better solved by one inexpensive upstream deterministic check or seeded regression;
6. the same core replay machinery is reusable across more than one materially different failure class.

## Current gate

As of the 2026-09-14 triage, **zero current `candidate_replay_escape` cases have been proven**.

The repository therefore remains in M0 research. Do not build a general replay engine, production executor, SaaS control plane, or customer-state ingestion path until a current candidate survives the frozen baseline and issue #6 explicitly opens.
