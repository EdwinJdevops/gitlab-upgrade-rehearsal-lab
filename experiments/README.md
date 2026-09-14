# Experiments

No experiment is a demo. Each experiment must answer a falsifiable question.

Required structure for a future experiment directory:

```text
experiments/EXP-XXX-name/
  README.md          # hypothesis, source, setup, expected baseline
  fixture/           # synthetic/sanitized state only
  baseline/          # official precheck result
  replay/            # isolated replay result
  evidence/          # non-secret normalized evidence
```

The first experiment is intentionally not implemented until the current GitLab baseline for the selected historical case is reproduced and documented.
