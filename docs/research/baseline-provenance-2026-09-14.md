# Baseline provenance — 2026-09-14

Captured at: `2026-09-14T13:35:26Z`

Purpose: make M0's control group reconstructible without pretending that a mutable branch URL or a generated GitLab Pages artifact is immutable.

This file is provenance metadata, not a second source of upgrade rules. The authoritative sources remain GitLab-owned sources.

## Provenance rules

1. Prefer an authoritative GitLab repository or documentation URL.
2. When an immutable GitLab commit or release is available, record it.
3. When only a mutable branch or generated artifact is available, record the retrieval time and explicitly mark it mutable.
4. A GitHub mirror may be used only as an independent verification aid. It is never authoritative for GitLab upgrade semantics.
5. Draft merge requests are research inputs, not released baseline behavior.
6. Before any M0 experiment is treated as evidence, the experiment runner must materialize mutable inputs and record a byte-level SHA-256 in the experiment evidence bundle.

## Frozen baseline inventory

| Mechanism | Authoritative source | Pin / observation | Release status | M0 interpretation |
|---|---|---|---|---|
| Required upgrade stops | `https://gitlab.com/gitlab-org/gitlab/-/raw/master/config/upgrade_path.yml` | Mutable `master` source observed on 2026-09-14. Independent GitHub mirror verification: commit `769726ce26ccfb52fb9c8b2a3adf34bbeadb29f9`, dated 2026-03-30, is the latest mirror commit touching `config/upgrade_path.yml` at this checkpoint. | Released / authoritative | This is the source of truth for required-stop semantics. Do not maintain a private copy of the rules. |
| Support Upgrade Path generated path data | `https://gitlab-com.gitlab.io/support/toolbox/upgrade-path/path.json` | Generated GitLab Pages artifact; mutable. The support repository build copies `ruby/path.json` into the published site. The observed `setup.sh` revision carrying that generation step is `a7bc3f5a`. | Released generated artifact | Treat patch-level path output as time-sensitive. Snapshot and hash it at experiment time instead of hard-coding today's generated output. |
| Support upgrade alerts | `https://gitlab.com/gitlab-com/support/toolbox/upgrade-path/-/raw/main/alerts.yml` | Mutable `main` source observed on 2026-09-14. It exposes structured applicability fields including version range, severity, required version, check phase and message. | Released support data | Applicable alerts are part of baseline detection. A replay win cannot claim novelty for a condition already represented here. |
| GitLab Detective | `https://gitlab.com/gitlab-com/support/toolbox/gitlab-detective/-/blob/main/README.md` | Repository head observed as `1d7ad2e2` at this checkpoint. Latest published release observed: `v1.2.0`, release commit `9b260fa2`, released 2026-05-04. | Released tool, explicitly experimental | Credit only behavior present in released/current Detective. The project itself labels Detective experimental. |
| Detective upgrade-alert mode | `https://gitlab.com/gitlab-com/support/toolbox/gitlab-detective/-/merge_requests/244` | Open draft MR at this checkpoint. The MR states the mode is a first draft and has not been fully tested; its pipeline is not a released control. | Draft / unreleased | Do not credit `--upgrade-alerts` as current baseline capability. Support `alerts.yml` remains baseline independently. |
| GitLab QA upgrade scenarios | `https://gitlab.com/gitlab-org/gitlab-qa/-/blob/master/docs/what_tests_can_be_run.md` | File revision observed: `6bb69db9`. The documented `UpdateFromPrevious` flow resolves official path data, populates state with health/smoke tests, upgrades through the path and runs tests. `UpdateToNext` tests development-to-next-stable transitions. | Released/current QA behavior | Generic "run an upgrade in a container" is already covered vendor-side. M0 must demonstrate signal from customer/historical state beyond QA-generated state. |
| Multi-version DB migration test | `https://docs.gitlab.com/development/database/dbmigrate_multi_version_upgrade_job/` | Mutable documentation page observed on 2026-09-14. The baseline documents a PostgreSQL dump from the latest required stop populated with seeded application data. | Released/current CI behavior | Historical migration bugs do not count until compared against current seeded multi-version coverage. |
| Operator upgrade planning | `https://docs.gitlab.com/update/plan_your_upgrade/` and `https://docs.gitlab.com/update/upgrade_paths/` | Mutable documentation pages observed on 2026-09-14. | Released documentation | Production-like clone testing, supported paths, background-migration completion and rollback planning are existing GitLab operator guidance. |
| Restore constraints | `https://docs.gitlab.com/administration/backup_restore/restore_gitlab/` | Mutable documentation page observed on 2026-09-14. | Released documentation | Exact source version/edition, secrets and storage/config fidelity are prerequisites for any credible state replay. |

## Independent verification note for `upgrade_path.yml`

GitLab moved required-stop ownership into `gitlab-org/gitlab` so that `config/upgrade_path.yml` is the source of truth. The Support project's legacy `upgrade-path.yml` explicitly says not to edit it and points to the GitLab project instead.

The GitHub `gitlabhq/gitlabhq` mirror is useful only to independently pin what the mirror observed. At this checkpoint its latest commit touching `config/upgrade_path.yml` is:

`769726ce26ccfb52fb9c8b2a3adf34bbeadb29f9`

That mirror commit must not replace the GitLab source in execution.

## Mutable-input rule for experiments

The baseline cannot be considered frozen merely because this document has a date. Before running any fixture comparison, the runner must capture the exact bytes used for every mutable machine-readable input, especially:

- `config/upgrade_path.yml`
- Support `path.json`
- Support `alerts.yml`

The evidence bundle must record the retrieval timestamp, source URL and SHA-256. If the bytes cannot be captured, the experiment is `BLOCKED`, not approximately reproducible.

## Current baseline decision

The control group is sufficiently defined to proceed with source inspection and execution planning, but issue #2 should remain open until one networked experiment run captures byte-level hashes for the mutable machine-readable inputs.

This is intentional. A prose citation or a web index timestamp is not a substitute for the bytes that drove an experiment.
