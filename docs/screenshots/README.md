# Screenshots

Evidence trail for the Sprint 1 definition of done and the case study. Because
project infrastructure is torn down after screenshots, these images are the
permanent record.

| File | What it shows | Captured |
|---|---|---|
| `sprint1-first-green-required-check.png` | The first-ever green run of the required `Pre-commit, Terraform validate, Gitleaks` check (PR #8), after the CI-red incident was fixed. Evidence for postmortem 0001 and the case study. | 2026-07-13 |

## Still to capture (Sprint 1 DoD — after the site module is applied)

These require the CloudFront distribution to be live, so they are taken once
PRs #11/#12 are merged and `module.site` is applied:

- `sprint1-apex-https.png` — `https://johnbabalola.com` served with valid TLS (padlock, cert detail showing the ACM cert).
- `sprint1-www-redirect.png` — `https://www.johnbabalola.com` redirecting to the apex.
- `sprint1-security-headers.png` — response headers (`curl -I`) showing HSTS, `X-Content-Type-Options`, `X-Frame-Options`.
- `sprint1-ssllabs-grade.png` — SSL Labs grade A for the apex.
