# M0 corpus triage — 2026-09-14

Status: preliminary evidence review, not a product go decision

## Executive result

No current replay escape is proven yet.

The research found strong evidence that state-dependent upgrade failures continue to occur on GitLab Self-Managed and Dedicated installations in 2026. It also found equally important counter-evidence: GitLab is actively backporting fixes, adding corrective-action tests, maintaining authoritative upgrade alerts, and expanding end-to-end upgrade CI.

Therefore the current M0 state is:

`INSUFFICIENT_EVIDENCE_CONTINUE_M0`

Do not build a reusable replay engine yet.

## Classification semantics

- `absorbed_upstream`: the historical defect has been fixed/backported or converted into authoritative GitLab guidance/testing.
- `baseline_detected`: current official upgrade tooling/guidance surfaces the known condition before or during planning.
- `candidate_replay_escape`: current reproduction proves the official baseline misses a materially important failure that isolated replay can expose.
- `unsupported_v0`: the case is outside the frozen single-node Linux-package scope.
- `not_reproducible`: a current reproduction was attempted and failed to reproduce the claimed behavior.
- `insufficient_evidence`: the failure class is credible but has not yet passed current-baseline/reproduction requirements.

## Original corpus

### GL-9916 — Mattermost target-version configuration false negative

Preliminary disposition: `absorbed_upstream`

Historical failure: `gitlab-ctl check-config --version 19.0.x` could pass on an 18.11 installation even though removed Mattermost configuration would fail reconfigure after installing 19.0.

GitLab's resolution path included backporting future deprecation knowledge to the stable branch and later correcting stale-state false positives. The case remains useful as an example of why target-version checks can fail, but it is not current evidence that our replay layer owns a durable gap.

Sources:
- https://gitlab.com/gitlab-org/omnibus-gitlab/-/work_items/9916
- https://gitlab.com/gitlab-org/omnibus-gitlab/-/merge_requests/9553
- https://gitlab.com/gitlab-org/omnibus-gitlab/-/merge_requests/9594

### GL-10001 — stale Mattermost state caused a preflight false positive

Preliminary disposition: `absorbed_upstream`

This is the inverse of GL-9916: a deterministic preflight can become over-conservative when it cannot distinguish active configuration from stale historical state. GitLab fixed the specific problem upstream.

Source:
- https://gitlab.com/gitlab-org/omnibus-gitlab/-/issues/10001

### GL-8048 — data-dependent migration failure despite clean background-migration state

Preliminary disposition: `insufficient_evidence`

This remains a strong historical demonstration of the thesis: a customer's database contents violated a target migration assumption even though no failed/pending background migration was reported.

However, GitLab now has `db:migrate:multi-version-upgrade`, backed by PostgreSQL dumps seeded with application data. We have not proven that an equivalent failure class still escapes that current test architecture.

Sources:
- https://gitlab.com/gitlab-org/omnibus-gitlab/-/issues/8048
- https://docs.gitlab.com/development/database/dbmigrate_multi_version_upgrade_job/

### GET-1023 — readiness URL regression

Preliminary disposition: `absorbed_upstream`

The failure shows that upgrade automation itself can introduce regressions, but it was fixed and is not the customer-state gap this repository is testing.

Source:
- https://gitlab.com/gitlab-org/gitlab-environment-toolkit/-/issues/1023

### GET-1047 — Geo secondary attempted writes against a read-only database

Preliminary disposition: `unsupported_v0`

The historical incident is useful evidence that topology matters. Geo is intentionally outside v0, so the correct behavior is rejection, not approximation.

Source:
- https://gitlab.com/gitlab-org/gitlab-environment-toolkit/-/issues/1047

### GL-590848 / GitLab 18.9 single-record BBM failure family

Preliminary disposition: `baseline_detected` + `absorbed_upstream`

The 18.9 failure family is important because batched background migrations could be marked complete without processing a single-record range, leaving data unbackfilled and causing later `PG::CheckViolation` errors. GitLab fixed/backported the underlying behavior and documented the affected upgrade condition.

This is evidence that customer data shape matters. It is not a current replay win because the failure became official upgrade knowledge and patch work.

Sources:
- https://gitlab.com/gitlab-org/gitlab/-/issues/591056
- https://support.gitlab.com/hc/en-us/articles/25992549646364-Upgrade-to-18-9-0-fails-with-PG-CheckViolation-on-commit-user-mentions
- https://docs.gitlab.com/update/versions/gitlab_18_changes/

## New 2026 high-value historical fixtures

These cases are more relevant to the current thesis than several older corpus entries. None is yet classified as `candidate_replay_escape` because the current baseline comparison and controlled reproduction have not been completed.

### GL-605197 — `keys.organization_id` NOT NULL failure on Self-Managed/Dedicated

Preliminary disposition: `absorbed_upstream`, high-value historical replay fixture

GitLab 19.0 contained a post-deploy migration that could halt upgrades with a `PG::CheckViolation` when `keys.organization_id` remained NULL. The earlier backfill joined keys to users; keys with `NULL user_id` or references to deleted users were silently skipped.

This is valuable because the bad state existed on Self-Managed/Dedicated while GitLab.com was already clean. GitLab fixed the migration and backported the fix to supported 19.x branches.

The scientific question is not whether the bug still exists. It is whether a production-state replay architecture would have exposed this class before the upstream fix while GitLab's representative seeded state did not.

Sources:
- https://gitlab.com/gitlab-org/gitlab/-/work_items/605197
- https://gitlab.com/gitlab-org/gitlab/-/merge_requests/245539
- https://gitlab.com/gitlab-org/gitlab/-/merge_requests/245625

### GL-603303 — `web_hook_logs_daily` fast chained-upgrade constraint failure

Preliminary disposition: `absorbed_upstream`, high-value historical replay fixture

The 19.0 constraint validation could fail on Self-Managed instances doing a fast chained upgrade because orphan partition rows with all sharding keys NULL remained before the retention window removed them. Finalize and validate migrations could execute back-to-back before the 14-day partition lifecycle cleared those rows.

GitLab neutralized the failing validation on supported 19.x branches and is completing cleanup/revalidation work upstream.

This is materially different from a simple static config error because state, partition retention time, and migration sequencing interact.

Sources:
- https://gitlab.com/gitlab-org/gitlab/-/work_items/603303
- https://gitlab.com/gitlab-org/gitlab/-/merge_requests/245680
- https://gitlab.com/gitlab-org/gitlab/-/merge_requests/244171

### GL-605940 — sharding-key backfill hit orphaned parent / hard-FK mismatch

Preliminary disposition: `insufficient_evidence`, high-priority current triage

A severity-1 upgrade incident was caused by a sharding-key backfill copying a `project_id` from a parent that can temporarily retain deleted-project references through loose-FK cleanup into a child column protected by a hard FK. That mismatch caused `PG::ForeignKeyViolation` and blocked the 18.11 -> 19.0 upgrade.

GitLab hardened the specific backfill, audited other tables for the same structural pattern, changed sharding guidance, and continued follow-up fixes. This strongly confirms that real customer historical/cleanup state can expose migration assumptions that are valid in cleaner environments.

It does not yet prove our product gap. We must establish whether current authoritative alerts/tests/prechecks now cover the relevant class and whether a reusable replay fixture adds signal beyond the upstream corrective actions.

Sources:
- https://gitlab.com/gitlab-org/gitlab/-/merge_requests/246021
- https://gitlab.com/gitlab-org/gitlab/-/work_items/606941
- https://docs.gitlab.com/development/organization/sharding/

## Vendor counter-signal: GitLab is actively closing the gap

Omnibus work item #10025, created in September 2026 as a corrective action, proposes expanded E2E upgrade CI:

- Docker N-1 -> current MR through GitLab QA `UpdateFromPrevious`;
- current MR -> N+1 through `UpdateToNext` where applicable;
- investigation of an E2E framework specifically for Linux-package upgrades because package behavior differs from Docker, including `preinst` execution.

This is strategically important. A third-party replay project is competing with an application owner that is actively increasing upgrade-test coverage.

Source:
- https://gitlab.com/gitlab-org/omnibus-gitlab/-/work_items/10025

## Detective status

The target-version `--upgrade-alerts` mode found in GitLab Detective remains a draft design MR in the evidence reviewed on 2026-09-14. It explicitly describes itself as a first draft that had not been fully tested. M0 must not credit draft behavior as a released control.

Source:
- https://gitlab.com/gitlab-com/support/toolbox/gitlab-detective/-/merge_requests/244

The Support Upgrade Path alerts remain part of the baseline independently of whether Detective's upgrade-alert mode is merged.

## What has been proven

1. The failure domain is real and active in 2026.
2. Several failures are genuinely state-dependent rather than simple path/version mistakes.
3. Self-Managed/Dedicated state can differ materially from GitLab.com state.
4. GitLab is actively converting escaped failures into patches, guidance, tests, generator changes, and corrective actions.
5. Historical failures alone therefore cannot justify a standalone product.

## What has NOT been proven

1. We have not demonstrated a current failure that official GitLab baseline mechanisms miss and our isolated replay catches.
2. We have not demonstrated two materially different reusable replay wins.
3. We have not proven that a useful replay can be built without customer-specific staging work.
4. We have not proven acceptable compute/storage/security cost for realistic customer state.
5. We have not proven OSS adoption demand.

## M0 decision at this checkpoint

`INSUFFICIENT_EVIDENCE_CONTINUE_M0`

Next work is controlled reproduction and baseline comparison, not product implementation.

Priority order:

1. Verify the current baseline precisely (#2).
2. Re-test current Omnibus unsupported-path enforcement (#4).
3. Study GL-605197, GL-603303, and GL-605940 as historical fixtures against current seeded migration/QA coverage (#5).
4. Open the isolated replay gate (#6) only if a current baseline escape is demonstrated.
5. Route deterministic findings upstream (#7).
6. Resolve the go/stop decision in #8.
