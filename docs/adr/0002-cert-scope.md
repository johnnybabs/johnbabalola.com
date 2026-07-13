# ADR-0002: Wildcard certificate covering apex and all subdomains

Date: 2026-07-13
Status: Accepted

## Context

The ACM certificate must cover `johnbabalola.com` and any subdomains that will
be added as future project demos (vidcast.johnbabalola.com, portal.johnbabalola.com,
etc. — described in PRD section 3). At the time of Sprint 1 only the apex and
`www` are in use. The cert must be in `us-east-1` for CloudFront.

## Options considered

| Dimension | Wildcard `*.johnbabalola.com` + apex SAN (chosen) | Per-subdomain certificates | Apex-only certificate |
|---|---|---|---|
| Monthly cost | Free (ACM-managed, DNS validation) | Free per cert; but N certs to manage | Free |
| Implementation time | One cert request, one Terraform resource | One resource per subdomain, or automation | One cert request |
| Operational complexity | Low: one cert to monitor, one renewal, one Terraform resource | High: add a cert for each new subdomain demo; risk of missing renewal | Very low, but blocks subdomains |
| Scalability ceiling | Covers any future `*.johnbabalola.com` subdomain without a new cert | Each subdomain needs its own cert before it can go live | Does not support subdomains at all |
| Security posture | Good: wildcard limits blast radius to subdomains of one domain; DNS validation via Route 53 automated | Equal: each cert is individually validated | Slightly better: no wildcard exposure, but blocks future use |
| Attack surface introduced | Wildcard cert: if the private key were compromised, any subdomain is at risk; mitigated by ACM key management (AWS holds the private key) | Individual certs: a compromised cert affects one subdomain | Single cert: lower wildcard exposure |
| Existing expertise | Standard Terraform `aws_acm_certificate` with multiple SANs | Same Terraform resource, more instances | Same |
| Compliance fit | Acceptable: ACM-managed wildcard is a common production pattern; private key never leaves AWS | Equivalent | Does not meet project requirements |

## Decision

Option 1: one ACM certificate with SANs `johnbabalola.com` and `*.johnbabalola.com`.

The wildcard covers the apex (via explicit SAN — wildcards do not cover the apex
by default) and all future subdomains. This removes the need to request a new
cert for each project demo and is the standard pattern for a portfolio with
multiple planned subdomains. The private key is managed by ACM and never exported.

## Consequences

Positive: single Terraform resource to manage; one renewal event; any future
`*.johnbabalola.com` subdomain can go live immediately with just a Route 53 record
and a CloudFront distribution.

Negative: a wildcard cert, if its private key were compromised, covers all
subdomains; in practice this risk is owned by AWS (ACM never exports private keys).
