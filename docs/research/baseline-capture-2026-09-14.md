# Baseline capture — 2026-09-14

Status: successful byte-level capture of the mutable machine-readable M0 baseline inputs.

## Why this exists

`docs/research/baseline-provenance-2026-09-14.md` defines which GitLab-owned inputs form the control group. This record freezes the exact bytes observed by the capture job without copying GitLab's rule data into this repository.

The raw files remain GitLab-owned sources. This repository records only retrieval metadata and hashes.

## Successful capture

GitHub Actions workflow: `baseline-capture`

Run ID: `34851683269`

Runner:

- Ubuntu 24.04.5 LTS
- runner image `ubuntu-24.04`
- runner image version `20260907.300.1`
- workflow token permission: `contents: read`

Capture code commit: `269a36b165daede567f7a5ff87f84fe9f375ab1c`

| Retrieved UTC | Input | Bytes | SHA-256 | Source |
|---|---:|---:|---|---|
| 2026-09-14T13:49:59Z | `upgrade_path.yml` | 1485 | `4dc6762856109b530f82099353102110970a5b6826d9c0cb3ae23dad14eb6c1d` | `https://gitlab.com/gitlab-org/gitlab/-/raw/master/config/upgrade_path.yml` |
| 2026-09-14T13:50:00Z | `path.json` | 417 | `765525fe99c0aa30139cdb0995e040e0bd5d88e54f57853a14e85e00418418a3` | `https://gitlab-com.gitlab.io/support/toolbox/upgrade-path/path.json` |
| 2026-09-14T13:50:00Z | `alerts.yml` | 5274 | `2fd362d78034cf908de94cc4384f3f4bc53b9a8584f76a6efa7855c2f90b5889` | `https://gitlab.com/gitlab-com/support/toolbox/upgrade-path/-/raw/main/alerts.yml` |

The job also validated that `path.json` parsed as JSON, that the captured `upgrade_path.yml` contained the structured GitLab 19 / minor 2 required-stop entry, and that `alerts.yml` matched the expected Support-alert data shape.

## Failed first capture attempt

Run ID `34851418766` failed after all three files had been downloaded and hashed.

The failure was in this repository's validation logic, not in GitLab's data or network retrieval. The first implementation incorrectly searched the YAML text for a literal `19.2`. GitLab's file represents that stop structurally as `major: 19` followed by `minor: 2`.

The capture code was corrected to validate the structured fields with `awk`, then the complete workflow was rerun successfully. The failed run is intentionally recorded because hiding failed validation attempts would make the research trail less reliable.

The first run happened to produce the same byte counts and hashes as the successful run, but only the successful run above is used as the M0 frozen capture.

## Interpretation

This completes the byte-level provenance requirement for the current M0 control group. It does **not** establish that any upgrade is safe, and it does not prove a replay-product gap.

Any later experiment that depends on mutable GitLab metadata must either reference this capture as its frozen control input or create a new capture and record the new hashes. Silent use of current mutable URLs is not acceptable evidence.
