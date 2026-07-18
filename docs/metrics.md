# Metrics

Measured values only. Do not add estimates or targets here; those live in `PRD.md`.
CV bullets are written from this file after real numbers exist.

## Sprint 1 (infrastructure)

| Metric | Value | Measured | Method |
|---|---|---|---|
| `terraform apply` (24 resources: site, oidc, budgets, dns logging) | completed, 0 changed / 0 destroyed | 2026-07-13 | `terraform apply` of a saved plan; wall-clock dominated by CloudFront distribution creation |
| apex response, TTFB (median of 3) | ~0.10 s | 2026-07-13 | `curl -w %{time_starttransfer}` against `https://johnbabalola.com` |
| SSL Labs grade | **A+** (all completed endpoints) | 2026-07-13 | ssllabs.com/ssltest — see `docs/screenshots/sprint1-ssllabs-grade.png` |
| Security headers | HSTS (max-age 63072000, includeSubDomains, preload), X-Content-Type-Options nosniff, X-Frame-Options DENY | 2026-07-13 | `curl -I` — see `docs/screenshots/sprint1-security-headers.txt` |
| apex over HTTPS (screenshot) | live | 2026-07-13 | `docs/screenshots/sprint1-apex-live.png` |
| www → apex redirect | HTTP 301 to `https://johnbabalola.com/` (clean Location, no trailing `?`) | 2026-07-18 | `curl -I https://www.johnbabalola.com` after applying `module.site.aws_cloudfront_function.www_redirect` — see `docs/screenshots/sprint1-www-redirect.txt` and `sprint1-www-redirect-clean.png` |
| HTTP → HTTPS redirect | HTTP 301 | 2026-07-13 | `curl -I http://johnbabalola.com` |
| 404 handling | `/404.html`, HTTP 404 | 2026-07-13 | `curl` of a missing path |

Notes: budget alert SNS subscription (baabalola@gmail.com) is **confirmed** — alerts
will fire at the 50% and 80% thresholds. First-full-month cost is recorded in the
Sprint 2 table once a billing period completes.

### Sprint 1 — Definition of Done: CONFIRMED

Signed off 2026-07-18 by John (owner). All Sprint 1 DoD items verified:
apex HTTPS 200 with HSTS/nosniff/frame-deny; SSL Labs A+; www→apex 301 with a clean
`Location` (trailing-`?` bug fixed and applied 2026-07-18); HTTP→HTTPS 301; 404→`/404.html`;
`terraform plan` clean (0 destroy); OIDC deploy role least-privilege; no `AccessKeyId`
in repo or workflow logs; threat model current; budget SNS confirmed; `CV.md` section 8
updated with earned keywords. Evidence in `docs/screenshots/`. Sprint 2 authorised to start.

## Sprint 2 (pipeline and content)

| Metric | Value | Measured | Method |
|---|---|---|---|
| Push-to-live time | — | — | GitHub Actions log timestamp delta |
| Lighthouse performance (home) | — | — | Lighthouse CLI or DevTools |
| Lighthouse accessibility (home) | — | — | Lighthouse CLI or DevTools |
| Monthly cost (first full month) | — | — | AWS Cost Explorer |
