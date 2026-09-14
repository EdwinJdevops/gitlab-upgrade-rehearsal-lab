# RFC-0001: Validate customer-state upgrade replay before productization

Status: Accepted for experiment

## Context

GitLab Self-Managed upgrades are state transitions over a large stateful system. GitLab already provides authoritative upgrade-path data, version-specific upgrade notes, health checks, GitLab Detective, migration upgrade tests, GitLab QA scenarios, and infrastructure tooling. Rebuilding those capabilities would be duplicate work.

The remaining hypothesis is narrower:

> A supported upgrade can still fail because target-version code encounters customer-specific historical state that static rules and representative seeded fixtures did not model.

The project must determine whether automated replay of stateful fixtures adds enough incremental detection to justify a reusable open-source tool.

## Decision

Build an **experimental rehearsal harness only**. Do not build a general product, UI, SaaS service, or production upgrade executor.

The harness compares two pipelines for every fixture:

- **A - official baseline:** current GitLab documented prechecks and applicable official diagnostics/tests.
- **B - state replay:** A plus execution of the supported upgrade transition inside a disposable isolated environment.

The metric is not test count. The metric is **incremental signal**: failures detected by B that A could not establish before the state transition.

## Core invariants

1. Production is read-only.
2. Rehearsal state never has implicit write access to production systems.
3. Official GitLab upgrade semantics are authoritative.
4. Unknown or untested behavior is represented explicitly, never converted into green status.
5. No evidence artifact contains secret material.
6. No target-version transition is attempted if the official path says it is unsupported.
7. Every result is reproducible from pinned source versions, fixture identifiers, vendor-metadata revisions, commands, and artifact digests.
8. If a failure can be represented as a deterministic inexpensive check, the preferred destination is upstream GitLab, not a private rule in this repository.

## Go criteria

Continue past the research milestone only if all are true:

- at least two materially different state-dependent failure classes survive the current official baseline;
- replay detects them before any real production change;
- the same core harness can exercise both without bespoke customer-specific orchestration;
- the cases are not better solved as static upstream checks;
- the experiment can run with local/bring-your-own-compute custody of sensitive state;
- the evidence semantics remain honest about untested production properties.

The number two is a minimum diversity gate, not a market-size claim. One reproduced historical bug is not a product thesis.

## Kill criteria

Stop standalone development if any of these becomes true:

- current GitLab Detective/prechecks/multi-version tests catch essentially all meaningful fixtures;
- every useful result reduces to a deterministic rule GitLab can own upstream;
- credible replay requires a bespoke staging architecture for each customer;
- realistic state replay cannot be isolated from production dependencies without destroying fidelity;
- privilege or secret requirements are unacceptable for the value obtained;
- GitLab ships an authoritative equivalent before this project demonstrates additional value.

## First experiment

1. Freeze a dated snapshot of the current official baseline.
2. Build a corpus of public historical upgrade failures.
3. For each case, determine whether it is reproducible today and whether the current baseline catches it.
4. Only for baseline escapes, build the smallest isolated replay needed to reproduce the failure.
5. Record detection delta, runtime, storage, required privileges, sensitive material, fidelity limitations, and upstreamability.
6. Hold a go/no-go review before building a general CLI.
