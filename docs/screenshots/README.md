# Screenshots

Evidence trail for the Sprint 1 definition of done and the case study. Because
project infrastructure is torn down after screenshots, these images are the
permanent record.

| File | What it shows | Captured |
|---|---|---|
| `sprint1-first-green-required-check.png` | The first-ever green run of the required `Pre-commit, Terraform validate, Gitleaks` check (PR #8), after the CI-red incident was fixed. Evidence for postmortem 0001 and the case study. | 2026-07-13 |
| `sprint1-apex-live.png` | `https://johnbabalola.com` serving the placeholder over TLS. | 2026-07-13 |
| `sprint1-ssllabs-grade.png` | SSL Labs report showing grade **A+** across CloudFront endpoints (exceeds the A target). | 2026-07-13 |
| `sprint1-security-headers.txt` | `curl -I` output: HSTS, X-Content-Type-Options, X-Frame-Options present. | 2026-07-13 |
| `sprint1-www-redirect.txt` | `curl -I` output: `www` → apex 301. | 2026-07-13 |

## Known minor issue (fix queued in the Task 9 PR)

The `www` redirect currently appends a bare `?` (`https://johnbabalola.com/?`) when
there is no query string, because the CloudFront function treated the always-present
querystring object as truthy. Fixed in `infra/modules/site/functions/www-redirect.js`
(check `keys.length`); applied after the Task 9 PR merges. Functionally the redirect
works; this is cosmetic.
