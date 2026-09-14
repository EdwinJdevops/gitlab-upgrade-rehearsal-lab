# ADR-0002: Evidence must distinguish proof from uncertainty

Status: Accepted

## Result vocabulary

- `VERIFIED`: the named property was directly exercised and its assertion passed in this run.
- `BLOCKED`: a prerequisite or assertion failed and the dependent stage was not allowed to continue.
- `UNKNOWN`: the run cannot establish the property with the available state or environment.
- `NOT_TESTED`: the property was intentionally outside this experiment's scope.
- `WARN`: relevant evidence exists but does not by itself establish failure or success.

## Forbidden language

The tool must not emit:

- "safe to upgrade"
- "production ready"
- "no risk"
- "no compromise"
- "guaranteed rollback"

A successful rehearsal means only that the tested state transition and listed assertions succeeded under the recorded rehearsal conditions.

## Provenance requirements

Every evidence bundle records:

- run ID and timestamp
- source GitLab version and edition
- target version
- resolved official upgrade path
- environment class
- fixture/state identifier
- source revisions/digests for authoritative GitLab metadata
- exact assertions executed
- command exit status and normalized result
- artifact hashes
- explicit limitations/unknowns

Secrets and raw credentials are never evidence.
