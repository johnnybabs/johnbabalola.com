# Threat model: johnbabalola.com

Date: 2026-07-13
Status: Current
Review trigger: any change to architecture, pipeline, or IAM configuration.

---

## The four questions

**1. What breaks this?**
The site stops serving if CloudFront loses access to the S3 origin (OAC misconfiguration, bucket deletion, ACM cert expiry) or if the Route 53 hosted zone loses its NS delegation. The GitHub Actions pipeline stops deploying if the OIDC role trust is revoked or the role's IAM policy is changed. There is no database, no compute, and no backend — the blast radius of any single failure is limited to the static site becoming unavailable.

**2. What does it cost?**
Outage cost: reputational only (recruiter-facing portfolio). No revenue. No SLA. Recovery is re-running `terraform apply` or pushing a new commit; RTO is under 30 minutes for an engineer with AWS access. A compromise that serves malicious content (XSS, phishing) is the higher-impact failure mode — it affects domain reputation and any visitor who loaded the page before the compromise was detected.

**3. Who fixes it when it fails, and do they have everything they need?**
John Babalola, sole operator. All recovery procedures are in `docs/runbooks/`. AWS access is via the AWS console or CLI with John's SSO credentials. GitHub access is via John's account. No on-call rotation; no pager. For a leaked credential, the runbook is `docs/runbooks/leaked-credential.md`.

**4. Who attacks this, how, and what do they gain?**
Realistic attackers: (a) automated scanners targeting misconfigured S3 buckets for data exfiltration; (b) opportunistic attackers who compromise a GitHub Action dependency to inject code into the pipeline; (c) phishers who use a domain-takeover technique to serve fraudulent content under johnbabalola.com. Motivated adversary gain is low: this is a personal site with no sensitive data. The domain reputation and John's professional identity are the assets worth protecting.

---

## Assets

| Asset | Classification | Impact if lost or compromised |
|---|---|---|
| Domain reputation (`johnbabalola.com`) | Public | Phishing/malware served under John's name; recruiter trust destroyed |
| AWS account | Internal | Unauthorised resource creation; cost abuse; data in all projects at risk |
| S3 bucket contents | Public (static HTML/CSS) | If tampered: malicious content served to visitors |
| OIDC IAM role | Internal | If abused: arbitrary writes to the S3 bucket and CloudFront invalidations |
| GitHub repository | Public | If compromised: malicious code deployed via Actions pipeline |

---

## Trust boundaries

| Boundary | Description |
|---|---|
| Internet → CloudFront | Public. CloudFront terminates TLS; unauthenticated read-only access to static content. |
| CloudFront → S3 | Private. OAC-signed requests only; bucket rejects any unsigned request. |
| GitHub Actions → AWS | Machine identity only. OIDC token exchanged for short-lived credentials scoped to one bucket and one distribution. No static keys. |
| John → AWS console/CLI | Human. SSO login; MFA enforced by AWS account settings. |
| John → GitHub | Human. GitHub account with 2FA. Push to main gated by branch protection. |

---

## Data flows

| Flow | Protocol | Authentication | Sensitive data? |
|---|---|---|---|
| Visitor → CloudFront | HTTPS (TLS 1.2 min) | None (public read) | No |
| CloudFront → S3 | HTTPS | OAC sig v4 | No |
| GitHub Actions → STS | HTTPS | OIDC JWT | Role ARN in workflow (not secret) |
| STS → GitHub Actions | HTTPS | N/A | Short-lived credentials (in-memory, not logged) |
| GitHub Actions → S3 | HTTPS | IAM SigV4 | No |
| GitHub Actions → CloudFront | HTTPS | IAM SigV4 | No |
| John → GitHub | HTTPS/SSH | 2FA | Source code |
| John → AWS | HTTPS | SSO/MFA | AWS management |

---

## Entry points

| Entry point | Exposure | Controls |
|---|---|---|
| CloudFront distribution | Public internet | TLS only; no origin IP exposed; security headers on all responses |
| GitHub repository | Public (code); protected (push) | Branch protection: require PR; no force-push; CODEOWNERS |
| GitHub Actions pipeline | Triggered by push to main | OIDC trust pinned to `repo:johnnybabs/johnbabalola.com:ref:refs/heads/main` |
| S3 bucket | Private | OAC only; Block Public Access at account and bucket level; no website endpoint |
| AWS console/CLI | Private | SSO + MFA; CloudTrail logging |
| ACM cert management | AWS-internal | Automated DNS validation via Route 53 |

---

## STRIDE table

| # | Category | Threat | Mitigation | Verification |
|---|---|---|---|---|
| 1 | Spoofing | Adversary compromises John's GitHub account and pushes to main, triggering a deploy | GitHub 2FA on John's account; branch protection requiring PR; OIDC trust pinned to specific repo and branch | GitHub security settings audit; IAM role trust policy review |
| 2 | Tampering | Supply-chain attack on a pinned GitHub Action SHA (SHA collision or malicious commit before pinning) | All Actions pinned to full commit SHAs; Gitleaks + Checkov in pre-commit and CI; Dependabot weekly SHA updates | `grep -r 'uses:' .github/` confirms no version-tag pins; Dependabot PRs reviewed |
| 3 | Tampering | Attacker gains write access to S3 bucket and replaces site content with malicious HTML | OIDC role scoped to `s3:PutObject/DeleteObject/ListBucket` on this bucket only; no other principal has write access; CloudTrail logs all S3 writes | IAM role policy review; S3 bucket policy; CloudTrail enabled |
| 4 | Repudiation | Change to infrastructure or content made without audit trail | Every deploy logs GitHub actor, commit SHA, and Actions run URL; CloudTrail records all AWS API calls | CloudTrail enabled account-wide; GitHub Actions logs retained 90 days |
| 5 | Information disclosure | S3 bucket accidentally made public (e.g. Terraform misconfiguration or manual console change) | S3 Block Public Access enabled at account level (overrides bucket-level); no bucket website endpoint; Checkov rule CKV_AWS_53 blocks misconfigured plans | `aws s3api get-public-access-block --bucket <name>`; Checkov in CI |
| 6 | Information disclosure | AWS credentials committed to the git repository | OIDC authentication — no static credentials exist to commit; Gitleaks pre-commit hook and CI scan block any accidental secret commit | `grep -r 'AKIA' .` returns nothing; Gitleaks CI step |
| 7 | Denial of service | Volumetric attack against CloudFront drives cost spike | CloudFront absorbs typical DDoS at edge; Budget alert at $63/month triggers email within 24 hours; WAF deferred (Tier 3, see exceptions) | Budget alert confirmed; CloudFront access logs reviewed if anomaly detected |
| 8 | Elevation of privilege | OIDC role assumed from an unauthorised GitHub repository or branch | Trust condition: `repo:johnnybabs/johnbabalola.com:ref:refs/heads/main` — no wildcards; role has no permissions outside this bucket and distribution | IAM role trust policy; STS assume-role test from a different repo should fail |
| 9 | Elevation of privilege | DNS takeover via dangling subdomain or NS misconfiguration | All Route 53 records managed by Terraform only; no manual DNS changes; wildcard cert prevents subdomain hijacking via ACM | `terraform plan` shows no drift; Route 53 console audit |

---

## Residual risks

| Risk | Reason not fully mitigated | Exception ref | Review date |
|---|---|---|---|
| Volumetric DDoS driving cost | WAF not implemented (cost, Tier 3) | EXC-004 | 2027-01-01 |
| Malicious content between compromise and detection | No real-time integrity monitoring; detection relies on budget alert or manual review | EXC-005 | 2027-01-01 |
| Root user without hardware MFA | Assumed: AWS account root has MFA enabled; not verified in Terraform | — | Verify manually before first deploy |

---

Signed off: John Babalola, 2026-07-13
