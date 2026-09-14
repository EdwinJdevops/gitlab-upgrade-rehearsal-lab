# EXP-001 — Linux-package required-stop enforcement

Status: **specified, not executed**

Issue: #4

## Question

On a disposable single-node GitLab CE Linux-package installation, does the current package pre-install path reject a maintained-version upgrade from `19.1.8` directly to `19.3.2` before package replacement or reconfiguration because `19.2` is a required upgrade stop?

This experiment does not test customer-state replay. It tests whether the old deterministic Omnibus path-enforcement concern still exists in current maintained releases.

## Why these versions

At the 2026-09-14 checkpoint GitLab's maintenance policy lists `19.3`, `19.2`, and `19.1` as the maintained releases. The 2026-09-10 critical patch release published:

- `19.3.2`
- `19.2.6`
- `19.1.8`

GitLab's upgrade-path documentation requires `19.2` as a GitLab 19 upgrade stop before moving to later 19.x releases. Therefore:

- source: `19.1.8`
- required intermediate stop: `19.2.6`
- target: `19.3.2`
- intentionally forbidden transition under test: `19.1.8 -> 19.3.2`

Do not substitute older unsupported releases merely to make the check fail.

## Source-level expectation

The current Omnibus `config/templates/package-scripts/preinst.erb` observed during experiment design contains an inline upgrade check with `MIN_VERSION=19.2`. For RPM and DEB upgrade invocation paths it calls `upgrade_check` before `config_check`, `pg_check`, backup, or reconfiguration. If the installed `OLD_MINOR_VERSION` is below `19.2`, the script exits non-zero.

That source inspection predicts rejection of `19.1.8 -> 19.3.2`, but it is **not** the experiment result. Packaging behavior must be observed from the released package.

Historical Omnibus issue #6218 is why this must be tested on the actual package path: Linux-package pre-install behavior has constraints that differ from Docker, and old issues cannot substitute for current execution evidence.

## Environment

Use a disposable VM only.

Frozen environment class:

- Ubuntu 24.04 LTS (`noble`), x86_64
- GitLab CE Linux package
- single node
- local PostgreSQL/Redis as packaged/configured by GitLab
- no production data
- no external runners
- no production DNS, OAuth, webhooks, SMTP, object storage, cloud credentials, or other integrations
- VM snapshot or destroy/recreate capability

The VM sizing is an experiment-runner choice, not part of the semantic result. Record CPU, RAM, disk, cloud/provider and image identifier in the evidence.

## Baseline inputs that must be captured before package mutation

Materialize and SHA-256 hash the exact bytes used for:

1. GitLab `config/upgrade_path.yml`
2. Support Upgrade Path `path.json`
3. Support Upgrade Path `alerts.yml`

Record URL, retrieval UTC timestamp, byte count and SHA-256. If these inputs cannot be captured, classify the run `BLOCKED`.

Also record:

- Ubuntu image/release
- architecture
- installed package version before the attempt
- target package version requested
- `preinst` script extracted from the exact target `.deb`, plus SHA-256
- GitLab CE package SHA-256 where available locally

## Setup

Install the GitLab package repository using GitLab's current official Linux-package instructions for Ubuntu 24.04. Do not use an unofficial mirror.

Install exactly `19.1.8-ce.0`. Confirm:

```bash
sudo dpkg-query -W -f='${Status} ${Version}\n' gitlab-ce
sudo gitlab-rake gitlab:env:info
```

Before the forbidden transition, prove that `19.2.6-ce.0` and `19.3.2-ce.0` are available from the configured package source:

```bash
apt-cache madison gitlab-ce | grep -E '19\.(1\.8|2\.6|3\.2)-ce\.0'
```

If any exact package is unavailable, stop and classify the run `BLOCKED`. Do not silently choose another patch release.

## Capture the target package without installing it

Download the exact target package first:

```bash
mkdir -p evidence/package
cd evidence/package
apt-get download gitlab-ce=19.3.2-ce.0
sha256sum ./*.deb > gitlab-ce-19.3.2.sha256
mkdir -p control
sudo dpkg-deb -e ./*.deb control
sha256sum control/preinst > preinst.sha256
cp control/preinst preinst.txt
cd ../..
```

Record whether the extracted released `preinst` contains the expected required-stop enforcement. Source inspection is secondary evidence; the runtime attempt remains decisive.

## Pre-attempt state

Capture, without secrets:

```bash
mkdir -p evidence/before
sudo dpkg-query -W -f='${Version}\n' gitlab-ce | tee evidence/before/package-version.txt
sudo gitlab-ctl status > evidence/before/gitlab-ctl-status.txt 2>&1
sudo gitlab-rake gitlab:env:info > evidence/before/gitlab-env-info.txt 2>&1
sha256sum /opt/gitlab/version-manifest.json > evidence/before/version-manifest.sha256
```

Do not copy `/etc/gitlab/gitlab-secrets.json`, credentials, private keys, tokens or environment dumps into evidence.

## Forbidden transition

Run exactly one package-manager attempt and preserve its exit code and output:

```bash
set +e
sudo apt-get install -y gitlab-ce=19.3.2-ce.0 \
  >evidence/forbidden-upgrade.stdout.log \
  2>evidence/forbidden-upgrade.stderr.log
rc=$?
printf '%s\n' "$rc" | tee evidence/forbidden-upgrade.exit-code
set -e
```

Do **not** retry, add bypass flags, edit the package, touch skip files, or manually run migrations before recording the result.

## Post-attempt checks

Immediately capture:

```bash
mkdir -p evidence/after
sudo dpkg-query -W -f='${Status} ${Version}\n' gitlab-ce | tee evidence/after/package-version.txt
sudo gitlab-ctl status > evidence/after/gitlab-ctl-status.txt 2>&1 || true
sha256sum /opt/gitlab/version-manifest.json > evidence/after/version-manifest.sha256
```

Then inspect package-manager state:

```bash
dpkg --audit > evidence/after/dpkg-audit.txt 2>&1 || true
sudo journalctl --since '-15 min' --no-pager > evidence/after/system-journal.txt 2>&1
```

Before committing any log, inspect and redact it. Raw VM evidence is local/private by default.

## Assertions

`A1_PATH_REQUIRES_STOP`

`VERIFIED` only if the captured authoritative baseline requires `19.2` between `19.1.8` and `19.3.2`.

`A2_PACKAGE_REJECTS_FORBIDDEN_TRANSITION`

`VERIFIED` only if the package-manager attempt exits non-zero and the failure is attributable to the required-stop check, not network/package-resolution/configuration failure.

`A3_TARGET_NOT_INSTALLED`

`VERIFIED` only if the installed package remains `19.1.8-ce.0` after the failed attempt.

`A4_NO_RECONFIGURE_OR_MIGRATION_STARTED`

`VERIFIED` only if the collected evidence shows rejection occurred before GitLab reconfiguration/migration work. Do not infer this merely from a non-zero exit code.

`A5_INSTANCE_REMAINS_OPERABLE`

`VERIFIED` only if the same local instance remains running/healthy enough to report normal GitLab status after rejection. This assertion is about the disposable test instance only.

## Classification

### `absorbed_upstream`

Use only if A1-A4 are verified and the forbidden transition is rejected before destructive package transition/reconfigure.

If so, close issue #4 as absorbed and do not implement local path-enforcement logic.

### `current_defect_reproduced`

Use only if A1 is verified but the package proceeds past the point where the required-stop check should have stopped it, or installs/reconfigures `19.3.2` despite skipping required `19.2`.

If reproduced, stop local workaround work. First draft an upstream Omnibus issue/MR design using GitLab-owned upgrade metadata.

### `not_reproducible`

Use when the exact valid experiment executes correctly but the historical failure behavior cannot be reproduced.

### `insufficient_evidence`

Use when execution occurs but evidence cannot establish where the transition was blocked or whether package mutation/reconfigure began.

### `BLOCKED`

Use when the exact packages, baseline bytes, isolated VM, or required evidence cannot be obtained.

## Expected result before execution

Source inspection strongly predicts `absorbed_upstream` for this specific path. That is a prediction, not a result.

If execution confirms it, EXP-001 contributes **zero evidence** for a standalone replay product. That negative result is useful because deterministic required-stop enforcement belongs in GitLab/Omnibus, not in this repository.

## Primary references

- https://docs.gitlab.com/policy/maintenance/
- https://docs.gitlab.com/update/upgrade_paths/
- https://docs.gitlab.com/releases/patches/patch-release-gitlab-19-3-2-released/
- https://gitlab.com/gitlab-org/omnibus-gitlab/-/raw/master/config/templates/package-scripts/preinst.erb
- https://gitlab.com/gitlab-org/omnibus-gitlab/-/issues/6202
- https://gitlab.com/gitlab-org/omnibus-gitlab/-/issues/6218
