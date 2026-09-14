# M0 corpus triage — 2026-09-14

Status: evidence review. Not a product go decision.

## Decision

`INSUFFICIENT_EVIDENCE_CONTINUE_M0`

No current `candidate_replay_escape` has been proven.

The control group is now frozen in:

- `baseline-provenance-2026-09-14.md`
- `baseline-capture-2026-09-14.md`

The next valid evidence must come from controlled reproduction. Historical incidents are not replay wins.

## Classification rules

- `absorbed_upstream`: GitLab fixed/backported the defect or converted it into authoritative guidance/testing.
- `baseline_detected`: current released baseline surfaces the condition before the transition that would fail.
- `candidate_replay_escape`: a current reproduction demonstrates a material failure that the frozen baseline misses and state replay exposes.
- `unsupported_v0`: outside single-node Linux-package v0.
- `not_reproducible`: a valid current reproduction attempt does not reproduce the claimed behavior.
- `insufficient_evidence`: credible failure class, but current reproduction/baseline comparison is incomplete.

## Original corpus

### GL-9916 — target-version Mattermost configuration false negative

Disposition: `absorbed_upstream`.

GitLab changed the target-version configuration knowledge upstream and subsequently corrected stale-state false positives. This is useful regression history, not a current replay gap.

Sources:

- https://gitlab.com/gitlab-org/omnibus-gitlab/-/work_items/9916
- https://gitlab.com/gitlab-org/omnibus-gitlab/-/merge_requests/9553
- https://gitlab.com/gitlab-org/omnibus-gitlab/-/merge_requests/9594

### GL-10001 — stale Mattermost state caused a preflight false positive

Disposition: `absorbed_upstream`.

The defect demonstrates that static preflight can be over-conservative when stale state is indistinguishable from active configuration. The specific defect was fixed upstream.

Source:

- https://gitlab.com/gitlab-org/omnibus-gitlab/-/issues/10001

### GL-8048 — customer-data migration constraint failure

Disposition: `insufficient_evidence`.

Historically, customer database contents violated a target migration assumption despite clean background-migration status. Current GitLab now executes `db:migrate:multi-version-upgrade` against a PostgreSQL dump generated from the latest required stop and populated using Data Seeder factories plus `db:seed_fu` fixtures. We have not yet executed the historical state against the current test path, so this is not a replay win.

Sources:

- https://gitlab.com/gitlab-org/omnibus-gitlab/-/issues/8048
- https://docs.gitlab.com/development/database/dbmigrate_multi_version_upgrade_job/

### GET-1023 — readiness URL regression

Disposition: `absorbed_upstream` / not customer-state differentiation.

This is an automation regression, not the state-history gap under test.

Source:

- https://gitlab.com/gitlab-org/gitlab-environment-toolkit/-/issues/1023

### GET-1047 — Geo secondary attempted writes to read-only database

Disposition: `unsupported_v0`.

Geo is outside the frozen single-node Linux-package boundary. The correct behavior for this project is rejection, not approximation.

Source:

- https://gitlab.com/gitlab-org/gitlab-environment-toolkit/-/issues/1047

### GL-590848 / 591056 — single-record BBM left data unbackfilled

Disposition: `baseline_detected` + `absorbed_upstream`.

GitLab fixed/backported the behavior and documented the affected upgrade condition. It remains evidence that migration metadata and actual data can diverge, but it is not current differentiation.

Sources:

- https://gitlab.com/gitlab-org/gitlab/-/issues/591056
- https://docs.gitlab.com/update/versions/gitlab_18_changes/

## 2026 state-dependent migration incidents

These are stronger scientific inputs than several older cases because they occurred on Self-Managed/Dedicated state in the GitLab 19 upgrade line. They still do not prove a standalone replay product.

### GL-605197 — `keys.organization_id` NOT NULL failure

Current disposition: `absorbed_upstream` for the original defect; retain as a historical fixture.

The failing state was simple and material: SSH-key rows with `organization_id IS NULL` survived the earlier join-based backfill when `user_id` was NULL or pointed to a deleted user. The 19.0 constraint migration then failed with `PG::CheckViolation`.

GitLab's fix:

1. no-op the failing historical constraint migration;
2. add a batched residual-NULL backfill that assigns the default organization;
3. add the NOT NULL constraint again in a later migration;
4. backport the correction across affected 19.x branches.

The master MR also documents a deterministic local fixture for the orphan key state. This is exactly the type of defect that should become an upstream migration regression test when known.

Sources:

- https://gitlab.com/gitlab-org/gitlab/-/work_items/605197
- https://gitlab.com/gitlab-org/gitlab/-/merge_requests/245539
- https://gitlab.com/gitlab-org/gitlab/-/merge_requests/245625

M0 implication: valuable historical evidence that representative state missed a real Self-Managed condition, but no current baseline escape survives the upstream fix.

### GL-603303 — `web_hook_logs_daily` fast chained-upgrade constraint failure

Current disposition: `absorbed_upstream` for the original upgrade-blocking failure; retain as a temporal-state fixture.

Failure mechanism:

- orphan webhook-log rows had all sharding keys NULL;
- finalize and constraint-validation migrations could run back-to-back during a fast chained upgrade;
- daily partitions retain rows for 14 days, so time-based cleanup had not removed them;
- validation failed with `PG::CheckViolation`.

GitLab neutralized the blocking validation and backported that change to 19.0, 19.1 and 19.2. Follow-up cleanup moved to a batched background migration because a synchronous scan was too expensive; final validation is deliberately deferred until a later required-stop boundary.

Sources:

- https://gitlab.com/gitlab-org/gitlab/-/work_items/603303
- https://gitlab.com/gitlab-org/gitlab/-/merge_requests/245679
- https://gitlab.com/gitlab-org/gitlab/-/merge_requests/245680
- https://gitlab.com/gitlab-org/gitlab/-/merge_requests/247913
- https://gitlab.com/gitlab-org/gitlab/-/merge_requests/247935

M0 implication: this is a useful fixture because the failure depends on data shape, partition retention time and chained-upgrade timing. But the known defect is already being carried through GitLab's own migration lifecycle, so it cannot be counted as a current replay escape.

### GL-605940 — loose-FK parent state copied into hard-FK child

Current disposition: `absorbed_upstream` for maintained patched releases; retain as the highest-value deterministic historical fixture.

Failure mechanism:

- `packages_helm_metadata_caches.project_id` could temporarily reference a deleted project because cleanup is handled by loose-FK machinery;
- `packages_helm_metadata_cache_states.project_id` is protected by a hard FK to `projects.id`;
- the backfill copied the dangling parent `project_id` into the hard-FK child;
- the 18.11 -> 19.0 transition aborted with `PG::ForeignKeyViolation`.

GitLab's correction makes the background migration orphan-tolerant: it removes un-backfillable orphan parents, lets the child cascade away, then backfills valid rows. The merged MR includes regression specs and an explicit manual end-to-end synthetic reproduction. GitLab's 19.2.1 / 19.1.3 / 19.0.5 patch notes list the corresponding backports for the maintained branches at that point.

Sources:

- https://gitlab.com/gitlab-org/gitlab/-/merge_requests/246021
- https://gitlab.com/gitlab-org/gitlab/-/merge_requests/246366
- https://gitlab.com/gitlab-org/gitlab/-/merge_requests/246416
- https://docs.gitlab.com/releases/patches/patch-release-gitlab-19-2-1-released/

M0 implication: this is not a current product gap. It is, however, an excellent falsification fixture because GitLab publishes a precise synthetic state and the original failure. If our future harness cannot reproduce the old failure on an affected pre-fix revision and show its disappearance on the patched revision, our replay machinery is not trustworthy.

## What current GitLab already does

The frozen M0 baseline includes:

- authoritative required-stop data;
- Support Upgrade Path path data and alerts;
- released read-only diagnostics;
- target/current configuration and health checks;
- seeded multi-version database migration testing;
- GitLab QA upgrade scenarios;
- documented production-clone rehearsal and rollback planning.

The `db:migrate:multi-version-upgrade` job specifically tests migration execution from the latest required stop using a seeded PostgreSQL dump. Its presence raises the bar: a candidate must depend on state that the current generator/test dump does not represent, not merely on a migration that once had a bug.

## Current evidence result

The strongest 2026 incidents confirm all of the following:

1. Self-Managed/Dedicated historical state can differ materially from GitLab.com and seeded clean-state assumptions.
2. Async cleanup, loose foreign keys, deleted parents, retention windows and chained upgrade timing are credible sources of migration failure.
3. GitLab is actively converting those escaped states into regression specs, backports, BBMs, migration redesigns and upgrade guidance.
4. A historical incident therefore loses product value once it is deterministic and upstream-owned.

What remains unproven:

- a currently reproducible state-dependent failure that survives the frozen official baseline;
- two materially different replay-only wins;
- useful replay without bespoke per-customer staging;
- acceptable compute/storage/security cost for production-derived state.

## Next experiment order

1. Execute EXP-001 from issue #4 in a disposable Linux-package VM. Source inspection predicts an upstream rejection; the runtime result must decide it.
2. For issue #5, use GL-605940 first as a harness-validation fixture because GitLab publishes both the failure-state construction and patched behavior.
3. Do not count GL-605940 as differentiation. It is a calibration test.
4. Search for a post-fix, currently supported state-dependent migration incident only after the calibration path is trustworthy.
5. Open issue #6 only after a current candidate survives the frozen baseline.
