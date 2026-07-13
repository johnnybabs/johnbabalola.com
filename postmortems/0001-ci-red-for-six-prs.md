# Postmortem 0001: Six PRs merged into main with a red CI check

- **Date of incident:** 2026-07-13
- **Date of postmortem:** 2026-07-13
- **Author:** John Babalola
- **Status:** Resolved
- **Severity:** Low (no production impact; process and quality-gate failure)

This is a blameless postmortem. The goal is to fix the system that allowed the
error, not to assign fault. The structure follows the incident-response chapter
of `02_DevSecOps_Engineering_Standards.md`: summary, impact, detection, timeline,
root cause, resolution, and action items.

---

## Summary

During Sprint 1, six pull requests were squash-merged into `main` while the
repository's only CI check — the `Lint and Validate` job ("Pre-commit, Terraform
validate, Gitleaks") — was failing. Five were the foundational Sprint 1 PRs
(#1 through #5), merged in a single reconciliation batch; the sixth was the DNS
module (#7), merged later before the gap was noticed. The check had in fact
**never passed since the repository was created**, so every one of the six went
in red. That the sixth merged the same way after the first five confirmed the
controls were genuinely absent, rather than the misses being one-off slips.

No infrastructure was misconfigured as a result: every merged change had been
`terraform validate`-d and `plan`-reviewed by hand before apply, and the failures
were in the *linting harness configuration*, not in the infrastructure code's
correctness. The incident is therefore a failure of pipeline discipline and of
an honest self-review process, not an outage.

## Impact

- **Production impact:** None. The site was not live yet; no deploy pipeline had run.
- **Quality-gate impact:** For the duration of Sprint 1, the repository had a
  green-looking workflow badge intention but a red reality. The shift-left
  guarantees the pipeline was supposed to provide (secret scanning, IaC scanning,
  format and validation gates) were running but their **blocking** value was zero,
  because nothing stopped a red merge.
- **Reputational impact (the real asset):** For a portfolio repository whose
  entire premise is "the infrastructure discipline is the product", a history of
  merging into `main` on red is a visible weakness. This postmortem converts that
  weakness into evidence of the opposite: that the gap was found, understood, and
  systemically closed.

## Detection

The failures were surfaced by the repository owner asking, in plain terms, why
the "Pre-commit, Terraform validate, Gitleaks" action kept failing. There was no
automated alert, because the check was not wired to block anything and no one had
been reading the Actions tab. That absence of detection is itself a finding
(see root cause #2).

## Timeline (all times 2026-07-13, UTC)

| Time | Event |
|---|---|
| 14:17–14:19 | PRs #1–#5 squash-merged into `main` in a single reconciliation batch. Every one had a failing `Lint and Validate` run. |
| 14:44 | PR #7 (DNS module) merged, also red. |
| ~15:10 | Owner asks why the lint action keeps failing. Investigation begins. |
| 15:25 | Fix PR (#8) opened after reproducing every failure locally; first-ever green CI run recorded (`conclusion: success`). |
| 15:41 | Fix PR #8 merged; `main` is green. |
| ~15:45 | Branch protection enabled on `main` requiring the check; this postmortem written. |

## Root cause

Three contributing causes combined. No single one would have produced the
incident alone.

### 1. The pre-commit hooks were never installed or run locally

`pre-commit` was never installed on the development machine and there was no
`.git/hooks/pre-commit`. The hooks only ever executed in CI. This mattered
because the `.pre-commit-config.yaml` itself contained latent bugs that a single
local run would have exposed immediately:

- `terraform_validate` was passed `--args=-backend=false`. That flag belongs to
  `terraform init`, not `terraform validate`, so validate aborted with
  `flag provided but not defined: -backend` on every directory.
- `terraform_validate` was run against the child module directories standalone.
  The `dns` and `budgets` modules declare provider `configuration_aliases`
  (`aws.us_east_1`) that the root supplies, so they cannot be validated in
  isolation and errored with `Provider configuration not present`.
- The two module `versions.tf` files omitted `required_version`, which `tflint`
  flagged as a blocking issue.
- `backend.tf` had a formatting deviation `terraform fmt` would have auto-fixed.
- A Checkov skip on the query-log group used the wrong check ID
  (`CKV_AWS_338`, retention) for a finding that was actually `CKV_AWS_158`
  (KMS), so the intended suppression never applied.

Every one of these is a five-second local catch. None were caught because the
gate that would catch them was only ever run after merge, in a place no one looked.

### 2. `main` had no required status checks

Branch protection existed only as an intention. `main` was, in fact,
unprotected: there were no required status checks, so a failing `Lint and
Validate` run did nothing to block a squash-merge. The merges went through the
GitHub API and the red check was simply ignored, silently.

### 3. The self-review checklist was ticked without being run

Each of the six PRs carried a self-review checklist that included
"`make lint` passes locally (pre-commit: fmt, validate, tflint, gitleaks,
checkov)". That box was ticked on every PR. It was not true on any of them —
`make lint` had never been run, because `pre-commit` was not installed. A
checklist item that is ticked by habit rather than by execution is worse than no
checklist, because it manufactures false confidence.

## Resolution

Fix PR #8 resolved every failure, verified by running the full suite locally to a
clean `exit 0` **before** pushing — this time for real:

- Removed `--args=-backend=false` from the `terraform_validate` hook.
- Added `exclude: ^infra/modules/` to `terraform_validate`; the child modules are
  validated through the `infra/` root, which composes them with providers resolved.
- Added `required_version = ">= 1.9.0"` to both module `versions.tf` files.
- Ran `terraform fmt`.
- Corrected the Checkov skip IDs on the query-log group to `CKV_AWS_158` (KMS) and
  `CKV_AWS_338` (7-day retention), each with a matching exception entry
  (EXC-012, EXC-013). An audit of all ten `#checkov:skip=` comments confirmed the
  other eight IDs were correct.

The CI run for PR #8 was the first `success` in the repository's history.

## What went well

- The infrastructure code was correct despite the harness being broken; hand-run
  `terraform validate` and `plan` review caught what the automated gate could not.
- Once investigated, every failure was reproduced locally and fixed at root cause
  rather than suppressed.

## What went poorly

- A quality gate was treated as configured because it existed in a YAML file,
  without ever confirming it ran or blocked anything.
- Self-review attestations were made without performing the attested action.

## Action items (process controls that prevent recurrence)

Two controls, both now in place, each targeting a different root cause:

1. **The lint check is a required status check on `main`.** Branch protection now
   requires "Pre-commit, Terraform validate, Gitleaks" to pass before any PR can
   merge, blocks force-pushes, and requires changes to go through a PR. A red
   check can no longer reach `main` through the normal path. *(Closes root cause #2.)*

2. **`make dev-setup` installs pre-commit as a local git hook.** Running it once
   after clone wires `pre-commit install`, so the same hooks that gate CI run on
   every local commit and catch config and IaC errors before they are ever pushed.
   *(Closes root cause #1.)*

For root cause #3, the discipline change is simpler and non-technical: a
self-review checkbox is ticked only after the command behind it has actually been
run and its output observed. The required check now enforces this in practice —
ticking the box without running the hooks will be contradicted by a red PR.

## Lessons

- A pipeline gate provides zero protection until it is both **run** and
  **blocking**. "It's in the config" is not "it works".
- The cheapest place to catch a broken quality gate is the first local run. The
  most expensive is never, which is where this one lived until it was asked about.
- Writing this up publicly is the point, not an embarrassment: the repository is
  stronger for showing a process failure caught and systemically closed than it
  would be for showing an unbroken record that hid the same gap.
