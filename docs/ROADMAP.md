# Roadmap

The roadmap is intentionally gated. Passing a phase is required before beginning the next.

## M0 - Prove or kill the gap

- freeze current official baseline and source revisions
- classify public historical failures against current GitLab tooling
- define evidence schema
- build synthetic fixtures only where current baseline does not already close the case
- compare baseline vs isolated replay
- publish results, including negative results
- go/no-go review

**Exit:** either stop/upstream findings, or demonstrate multiple reusable state-dependent replay wins.

## M1 - Minimal reusable rehearsal primitive

Only if M0 passes:

- deterministic CLI core
- exact-version source environment lifecycle
- official upgrade-path resolver adapter
- isolated state import
- stop-by-stop assertions
- evidence bundle generation
- clean teardown

No production mutation.

## M2 - Production-derived state adapter

Only after M1 and threat-model review:

- read-only manifest collector
- operator-provided backup/snapshot input
- strict secret handling
- object-storage completeness checks
- data-egress controls
- explicit fidelity report

## M3 - Broader topology

Not scheduled. Multi-node, external DB/Redis, Geo, Kubernetes, and other topology support require separate evidence that the additional complexity is justified.
