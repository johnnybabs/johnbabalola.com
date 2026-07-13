## What changed and why

<!-- One paragraph. Link the sprint task. -->

## Evidence

<!-- For infrastructure PRs: paste the `terraform plan` summary.
     For deploy PRs: paste the `curl -I` output showing security headers.
     For content PRs: screenshot or `diff --stat`. -->

## Self-review checklist

- [ ] `make lint` passes locally (pre-commit: fmt, validate, tflint, gitleaks, checkov)
- [ ] No credentials, `.tfstate`, or `.tfvars` files staged (`git status --ignored`)
- [ ] `CLAUDE.md`, `01_Production_Repo_Standards.md`, `02_DevSecOps_Engineering_Standards.md` are NOT staged
- [ ] For infra PRs: `terraform plan` output attached above, no unintended resource changes
- [ ] For infra PRs: all new resources tagged `Project=website`, `Owner=johnnybabs`, `Teardown=false`
- [ ] For infra PRs: no `*FullAccess` managed policies added
- [ ] `docs/security-exceptions.md` updated if any check was skipped
- [ ] `CHANGELOG.md` updated

## Rollback

<!-- How to undo this change if it causes an issue after merge. -->
