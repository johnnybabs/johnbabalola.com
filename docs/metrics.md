# Metrics

Measured values only. Do not add estimates or targets here; those live in `PRD.md`.
CV bullets are written from this file after real numbers exist.

## Sprint 1 (infrastructure)

| Metric | Value | Measured | Method |
|---|---|---|---|
| `terraform apply` time (full stack) | — | — | Stopwatch from `make apply` |
| `curl -I https://johnbabalola.com` response time | — | — | `time curl -I` |
| SSL Labs grade | — | — | ssllabs.com/ssltest |
| Screenshot: apex HTTPS | — | — | See docs/screenshots/ |
| Screenshot: www redirect | — | — | See docs/screenshots/ |
| Screenshot: security headers | — | — | See docs/screenshots/ |

## Sprint 2 (pipeline and content)

| Metric | Value | Measured | Method |
|---|---|---|---|
| Push-to-live time | — | — | GitHub Actions log timestamp delta |
| Lighthouse performance (home) | — | — | Lighthouse CLI or DevTools |
| Lighthouse accessibility (home) | — | — | Lighthouse CLI or DevTools |
| Monthly cost (first full month) | — | — | AWS Cost Explorer |
