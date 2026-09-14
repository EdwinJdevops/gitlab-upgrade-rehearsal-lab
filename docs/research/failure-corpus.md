# Historical upgrade-failure corpus

This corpus is an experiment input, not a claim that each historical bug remains unfixed.

For every case, first ask: **does current GitLab tooling already catch this?** If yes, classify the case as `absorbed_upstream`; do not claim project value from it.

| ID | Historical class | Public reference | What it tests | Expected research disposition |
|---|---|---|---|---|
| GL-9916 | target-version configuration false negative | https://gitlab.com/gitlab-org/omnibus-gitlab/-/work_items/9916 | whether current target-config checks catch removed config | likely upstream/static; baseline first |
| GL-10001 | stale configuration false positive | https://gitlab.com/gitlab-org/omnibus-gitlab/-/issues/10001 | whether checks distinguish active config from stale state | likely upstream/static; baseline first |
| GL-8048 | data-dependent migration constraint failure | https://gitlab.com/gitlab-org/omnibus-gitlab/-/issues/8048 | whether current seeded multi-version migration tests now reproduce the class | high-value baseline comparison |
| GET-1023 | generated readiness URL regression | https://gitlab.com/gitlab-org/gitlab-environment-toolkit/-/issues/1023 | automation regression | regression corpus only; outside v0 product scope |
| GET-1047 | Geo secondary write against read-only DB | https://gitlab.com/gitlab-org/gitlab-environment-toolkit/-/issues/1047 | topology-dependent action | v0 must reject as unsupported |
| GL-590848 | migration constraint issue carried in upgrade alerts | https://gitlab.com/gitlab-org/gitlab/-/issues/590848 | whether authoritative alerts absorb known failures | should be consumed upstream, not duplicated |

## Modern baseline to compare against

The experiment must account for current GitLab capabilities, not historical assumptions:

- GitLab Detective read-only diagnostics
- official `upgrade_path.yml`
- Support Upgrade Path alerts
- `gitlab-ctl check-config --version ...`
- `gitlab-rake gitlab:check`
- `gitlab-rake gitlab:doctor:secrets`
- background migration checks
- `db:migrate:multi-version-upgrade` with seeded PostgreSQL dumps
- GitLab QA `UpdateFromPrevious` / `UpdateToNext`

## Required measurements per fixture

Record:

- whether current baseline detects the problem before upgrade execution
- whether state replay detects anything additional
- false positive / false negative behavior
- exact failing operation and assertion
- minimum state needed to reproduce
- whether the failure can become a deterministic upstream check
- reconstruction/restoration duration
- storage/compute requirements
- privilege and secret requirements
- whether sanitized synthetic state is sufficient
- fidelity limitations
