# ZAP baseline scan — findings

**Target:** https://johnbabalola.com (live site, skeleton content)
**Scanner:** OWASP ZAP baseline (`ghcr.io/zaproxy/zaproxy:stable`, `zap-baseline.py`)
**Date:** 2026-07-18
**Result (initial):** FAIL 0 · WARN 7 · PASS 60 (High 0, Medium 1, Low 5, Informational 3)
**Result (re-scan after remediation, 2026-07-18):** FAIL 0 · WARN 4 · PASS 63 — the Medium CSP finding and all four cross-origin/permissions header findings cleared; the 4 remaining warnings are the accepted `Server: CloudFront` header and cache-info items.

Raw reports in this folder: `zap-baseline-report.html`, `zap-baseline-report.md`,
`zap-console.log`. This is the one-time baseline required by the DevSecOps standard;
re-run after the case-study content lands.

## Findings and disposition

Findings 1–5 were **remediated on 2026-07-18** by adding the headers to the
CloudFront `response_headers_policy` in `infra/modules/site` (applied; verified
live with `curl -I` and a headless-browser load with no CSP violations and the
stylesheet still applying). Findings 6–7 are accepted.

| # | Alert | Risk | Disposition |
|---|---|---|---|
| 1 | Content Security Policy (CSP) header not set [10038] | Medium | **Fixed** — strict CSP added: `default-src 'none'; style-src 'self'; img-src 'self'; font-src 'self'; base-uri 'none'; form-action 'none'; frame-ancestors 'none'`. |
| 2 | Cross-Origin-Embedder-Policy missing [90004] | Low | **Fixed** — `COEP: require-corp`. |
| 3 | Cross-Origin-Opener-Policy missing | Low | **Fixed** — `COOP: same-origin`. |
| 4 | Cross-Origin-Resource-Policy missing | Low | **Fixed** — `CORP: same-origin`. |
| 5 | Permissions-Policy header not set [10063] | Low | **Fixed** — locked-down `Permissions-Policy` denying camera, microphone, geolocation, payment, USB, etc. |
| 6 | Server leaks version via `Server` header [10036] | Low | **Accept** — the header is `Server: CloudFront` (no version). CloudFront does not allow removing it. No real leak. |
| 7 | Re-examine Cache-Control directives [10015] | Informational | **Accept** — `public, max-age=300` is intentional for static content; short TTL plus invalidation on deploy. |

Re-scan reports: `zap-baseline-report-rescan.{html,md}` (2026-07-18, after remediation).

Informational-only (normal for a static site): Storable/Cacheable Content [10049],
Retrieved from Cache [10050], and the endpoint/status-code statistics.

## Recommended remediation

Findings 1–5 are all additional security-response headers. They belong in the
existing CloudFront `response_headers_policy` in `infra/modules/site` (which already
sets HSTS, `X-Content-Type-Options`, and `X-Frame-Options`). A single Terraform
change adds:

- `Content-Security-Policy: default-src 'none'; style-src 'self'; img-src 'self'; font-src 'self'; base-uri 'none'; form-action 'none'; frame-ancestors 'none'`
- `Permissions-Policy` denying sensitive features
- `Cross-Origin-Opener-Policy: same-origin`, `Cross-Origin-Embedder-Policy: require-corp`, `Cross-Origin-Resource-Policy: same-origin`

The CSP must be revisited when the CV page adds a downloadable PDF and if any
case study embeds an external architecture diagram or image.

Findings 6 and 7 are accepted; see `docs/security-exceptions.md` if formalised.
