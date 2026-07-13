# ADR-0001: S3 + CloudFront + OAC as the hosting platform

Date: 2026-07-13
Status: Accepted

## Context

The portfolio site is a static collection of HTML/CSS files. It needs HTTPS on
the apex domain, a custom domain, globally low latency for UK recruiter traffic,
minimal monthly running cost (PRD target: under £1.50/month), and a deployment
story that is itself a portfolio artefact (IaC, OIDC pipeline, no long-lived
keys). The site has no server-side logic, no database, and no user-submitted
data. The infrastructure is tagged `Teardown=false` and must stay live.

Constraints: solo operator, £50/month account budget, all IaC in Terraform,
deployment via GitHub Actions OIDC. The chosen option must not require an
always-on compute instance.

## Options considered

| Dimension | S3 + CloudFront + OAC (chosen) | AWS Amplify | GitHub Pages |
|---|---|---|---|
| Monthly cost | ~$1.00 (hosted zone $0.50 + CloudFront/S3 requests) | ~$1.00 for hosting; extra for build minutes above free tier | Free |
| Implementation time | ~4 hours (Terraform modules exist as patterns) | ~1 hour (console wizard) | ~30 minutes |
| Operational complexity | Medium: 5 Terraform resources, OAC config, security headers policy | Low: managed platform | Very low: git push |
| Scalability ceiling | Global edge, no ceiling at portfolio scale | Global edge, managed | GitHub CDN, no custom origin |
| Security posture | High: private bucket, OAC, custom security headers, OIDC pipeline, no public IP | Medium: Amplify manages origin, limited header control | Low: public git-backed, no custom headers without extra config, no bucket-level control |
| Attack surface introduced | CloudFront distribution (public), S3 bucket (private, OAC only), Route 53 zone | Amplify app (public), git integration, Amplify console | GitHub Pages endpoint, git repo |
| Existing expertise | John has built this pattern (VidCast repo) | John has not used Amplify | John has used GitHub Pages |
| Compliance fit | Full: OAC is AWS-current recommendation; private bucket; HSTS; matches production pattern | Partial: less granular IAM; no OAC equivalent | Minimal: no private origin, no OIDC deploy story |
| Portfolio signal | High: demonstrates S3, CloudFront, OAC, ACM, Route 53, OIDC — every service a recruiter expects to see | Low: hides the infrastructure; Amplify does it for you | Very low: not IaC, no AWS |

## Decision

Option 1: S3 + CloudFront + Origin Access Control.

The bucket stays private; TLS terminates at CloudFront; OAC is the
current AWS-recommended pattern (OAI is deprecated). The infrastructure
itself is a portfolio artefact, and this option exercises the most
recruiter-relevant AWS skills. Cost difference versus GitHub Pages is
under $1.00/month, which is acceptable given the career ROI.

## Consequences

Positive: private bucket, HSTS and security headers possible, matches
production AWS architecture, full IaC in Terraform, OIDC deploy pipeline.

Negative: CloudFront invalidations required on deploy; slightly more Terraform
to maintain than a managed platform; ACM cert must be in us-east-1 (provider
alias required in Terraform).
