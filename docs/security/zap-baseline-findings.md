# ZAP baseline scan — findings

**Target:** https://johnbabalola.com (live site, skeleton content)
**Scanner:** OWASP ZAP baseline (`ghcr.io/zaproxy/zaproxy:stable`, `zap-baseline.py`)
**Date:** 2026-07-18
**Result:** FAIL 0 · WARN 7 · PASS 60 (High 0, Medium 1, Low 5, Informational 3)

Raw reports in this folder: `zap-baseline-report.html`, `zap-baseline-report.md`,
`zap-console.log`. This is the one-time baseline required by the DevSecOps standard;
re-run after the case-study content lands.

## Findings and disposition

| # | Alert | Risk | Disposition |
|---|---|---|---|
| 1 | Content Security Policy (CSP) header not set [10038] | Medium | **Fix** — add a strict CSP via the CloudFront response-headers policy. Easy win on a static, no-JS site. |
| 2 | Cross-Origin-Embedder-Policy missing [90004] | Low | Fix alongside CSP (add `COEP: require-corp`). |
| 3 | Cross-Origin-Opener-Policy missing | Low | Fix alongside CSP (add `COOP: same-origin`). |
| 4 | Cross-Origin-Resource-Policy missing | Low | Fix alongside CSP (add `CORP: same-origin`). |
| 5 | Permissions-Policy header not set [10063] | Low | Fix — add a locked-down `Permissions-Policy` (deny camera, microphone, geolocation, etc.). |
| 6 | Server leaks version via `Server` header [10036] | Low | **Accept** — the header is `Server: CloudFront` (no version). CloudFront does not allow removing it. No real leak. |
| 7 | Re-examine Cache-Control directives [10015] | Informational | **Accept** — `public, max-age=300` is intentional for static content; short TTL plus invalidation on deploy. |

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
