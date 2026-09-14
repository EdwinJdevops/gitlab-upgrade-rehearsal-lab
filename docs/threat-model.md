# Threat model

The dangerous part of upgrade rehearsal is not version parsing. It is handling restored application state that may contain credentials, webhooks, runner registrations, identity-provider configuration, encrypted variables, internal hostnames, object-storage endpoints, and other production integrations.

## Protected assets

- GitLab secrets and encryption keys
- repository contents and proprietary source
- database contents
- CI/CD variables and tokens
- user/account data
- object-storage contents
- internal topology and hostnames
- production availability and integrity

## Primary threats and controls

### Accidental production mutation

Control: production access is read-only. Rehearsal credentials must be separate. Restored state runs in a network-isolated environment with default-deny egress after state restoration. No production AWS/GCP/Azure credentials are injected.

### Restored GitLab calls external systems

Control: default-deny egress, no live runners, no production DNS assumptions, and explicit allowlists only for dependencies that are part of a declared test. Package artifacts should be staged before stateful replay where practical.

### Secret leakage into logs/evidence

Control: command output redaction, structured evidence allowlist, no environment dumps, no secret-value serialization, and tests that seed canary secrets and fail if they appear in artifacts.

### False confidence from incomplete state

Control: missing object storage, external PostgreSQL/Redis, Geo, or other unsupported dependencies become `UNKNOWN`/`NOT_TESTED`/`BLOCKED`. The harness never silently substitutes an approximation.

### Supply-chain compromise

Control: pin external automation dependencies, record source revisions and checksums, minimize third-party GitHub Actions, review dependency updates, and sign release artifacts only after the project passes the validation gate.

### Command injection

Control: typed process arguments and allowlisted commands; never concatenate GitLab metadata, fixture values, paths, or user input into shell command strings.

### Persistence after a run

Control: rehearsal infrastructure is disposable. Sensitive volumes are encrypted while alive and destroyed after the run. Retained evidence excludes secrets and raw customer state.
