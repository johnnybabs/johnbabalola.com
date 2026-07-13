# johnbabalola.com

Portfolio site for John Babalola, Cloud DevOps Engineer, Belfast.

[![Lint](https://github.com/johnnybabs/johnbabalola.com/actions/workflows/lint.yml/badge.svg)](https://github.com/johnnybabs/johnbabalola.com/actions/workflows/lint.yml)
[![Deploy](https://github.com/johnnybabs/johnbabalola.com/actions/workflows/deploy.yml/badge.svg)](https://github.com/johnnybabs/johnbabalola.com/actions/workflows/deploy.yml)

## Architecture

```
GitHub Actions (OIDC) ──► S3 (private bucket)
                                │
                                ▼
Browser ──► CloudFront (OAC) ──► origin
           (TLS, security
            headers, www→apex
            redirect)
                │
                ▼
         ACM cert (us-east-1)
         Route 53 hosted zone
```

*Architecture diagram (Lucidchart): added in Sprint 1 DoD.*

## Cost

| Resource | Monthly cost (USD) | Notes |
|---|---|---|
| Route 53 hosted zone | $0.50 | Fixed |
| CloudFront + S3 | < $0.50 | Portfolio-level traffic |
| ACM certificate | Free | Managed renewal |
| AWS Budgets | Free | Alert threshold $63 (~£50) |
| **Total** | **< $1.00 (~£0.80)** | |

## How to deploy

1. `make init` — initialise Terraform with remote state
2. `make plan` — review the plan, paste output in the PR
3. `make apply` — apply on merge to main (or via GitHub Actions)

See `docs/runbooks/` for the full bootstrap procedure from cold.

## Baseline questions

1. Can a new engineer deploy this safely from the README alone? — See `docs/runbooks/`, `Makefile`, and this README.
2. Can a failure be diagnosed from logs and dashboards without shelling into anything? — CloudFront access logs + CloudTrail; no SSH paths exist.
3. Does the cost table say what it costs and why? — See table above.
4. Can CloudTrail plus Actions logs say who changed what and when? — Yes; every deploy logs commit SHA, actor, and outcome.
5. Does teardown remove everything, provably? — See `teardown.sh`; tagged `Teardown=false` so destruction is intentionally guarded.
6. Can a non-technical reader understand why this design was chosen? — See `docs/adr/`.
7. Does the threat model name the threats, and does each have a mitigation or exception? — See `docs/threat-model.md`.
8. Is there a written response for a leaked credential and a failed deploy? — See `docs/runbooks/leaked-credential.md`.
9. What happens if a dependency is compromised, and how would you know? — GitHub Actions pinned to commit SHAs; Dependabot weekly updates; Gitleaks in pre-commit and CI. See `docs/security-exceptions.md`.
