# Security exceptions register

Every deviation from the DevSecOps standard (`02_DevSecOps_Engineering_Standards.md`)
is recorded here. An exception without an expiry date is a Tier 1 violation.
Exceptions are reviewed at the start of each sprint; expired exceptions are either
resolved or re-approved with a new date.

Owner of all exceptions unless otherwise noted: John Babalola.

---

## EXC-001: Licence scanning not implemented

**Requirement:** SCA licence scanning (from standards Tier 3 table).
**Reason:** Solo portfolio lab. All dependencies are MIT or Apache-2 licensed;
no proprietary codebase or redistribution concern.
**Tier:** 3 (documented design — no implementation required).
**Expiry:** 2027-01-01. Re-evaluate if a proprietary dependency is added.

---

## EXC-002: OWASP ZAP DAST scan deferred to Sprint 2

**Requirement:** ZAP baseline scan against the live site (standards Tier 2).
**Reason:** The live site does not exist until Sprint 1 is complete. The scan
requires a live TLS endpoint to be meaningful.
**Tier:** 2 (demonstrated at lab scale, Sprint 2 DoD).
**Expiry:** Sprint 2 DoD. If Sprint 2 is not completed by 2026-08-31, this
exception is escalated to a finding.

---

## EXC-003: Image signing and admission control not implemented

**Requirement:** Cosign + Kyverno image signing (standards Tier 3).
**Reason:** This project has no container images. Applies to vidcast and portal;
deferred to January 2027 roadmap wave.
**Tier:** 3 (documented design).
**Expiry:** 2027-01-01.

---

## EXC-004: WAF not deployed on CloudFront

**Requirement:** WAF for application-layer DDoS and rule-based filtering
(standards Tier 3).
**Reason:** Portfolio site; no user-submitted input; no backend. WAF costs
approximately $5/month minimum, which exceeds the site's entire monthly budget
($1 running cost). Volumetric DDoS risk is partially mitigated by the $63
budget alert (see threat model residual risk #1).
**Tier:** 3 (documented design). Entry in `docs/enterprise-scale.md` will
note the production pattern (AWS WAF with managed rule groups).
**Expiry:** 2027-01-01.

---

## EXC-005: No real-time content integrity monitoring

**Requirement:** Security observability — alert on unexpected S3 writes
(standards Tier 2, adapted for this project).
**Reason:** S3 event notifications routing to SNS/Lambda are out of scope for
a static portfolio. CloudTrail provides audit trail; the GitHub Actions deploy
log provides change attribution. A budget alert catches cost anomalies from
unexpected writes.
**Tier:** 2 partial. Detection relies on CloudTrail review rather than real-time alerting.
**Expiry:** 2027-01-01.

---

## EXC-006: mTLS and service mesh not implemented

**Requirement:** Zero-trust service-to-service mTLS (standards Tier 3).
**Reason:** No service-to-service traffic exists in this architecture
(CloudFront to S3 uses OAC, not mTLS). Istio/App Mesh noted in
`docs/enterprise-scale.md`.
**Tier:** 3 (not applicable to this project).
**Expiry:** N/A — revisit if a backend service is added.

---

## EXC-007: DynamoDB lock table uses AWS-managed SSE, not CMK (CKV_AWS_119)

**Requirement:** CKV_AWS_119 — DynamoDB tables encrypted with a customer-managed KMS key.
**Reason:** AWS-managed SSE (`enabled = true` without a key ARN) is the Tier 2 lab baseline
per `02_DevSecOps_Engineering_Standards.md` ("AWS-managed keys are the lab baseline"). One CMK
demonstration with annual rotation and CloudTrail key-usage logging is implemented in Project C
(the Secrets Manager secret), satisfying the pattern at portfolio scale. A CMK for the Terraform
lock table adds ~$1/month (KMS key cost) with no meaningful security improvement in a solo lab.
**Tier:** 2 (demonstrated in Project C; lab baseline acceptable here).
**Checkov skip:** `#checkov:skip=CKV_AWS_119` in `infra/bootstrap/main.tf`.
**Expiry:** 2027-07-13.

---

## EXC-008: S3 buckets use AWS-managed SSE, not CMK (CKV_AWS_145)

**Requirement:** CKV_AWS_145 — S3 buckets encrypted with a customer-managed KMS key.
**Reason:** Same rationale as EXC-007. AWS-managed AES256 SSE is the Tier 2 lab baseline.
Applies to the state bucket (`johnnybabs-tf-state`) and its access-log bucket. A CMK for
Terraform state or access logs adds cost and operational complexity (key rotation, key policy
maintenance) with no security improvement in a context where the data is internal infrastructure
state with no PII or secrets.
**Tier:** 2 (demonstrated in Project C; lab baseline acceptable here).
**Checkov skip:** `#checkov:skip=CKV_AWS_145` in `infra/bootstrap/main.tf` on both S3 bucket resources.
**Expiry:** 2027-07-13.

---

## EXC-009: S3 buckets do not have cross-region replication (CKV_AWS_144)

**Requirement:** CKV_AWS_144 — S3 bucket cross-region replication enabled.
**Reason:** Cross-region replication of Terraform state costs approximately $0.02–0.05/month
per GB transferred, adds a replication IAM role, and doubles the storage cost. For a solo
portfolio lab with a £50/month budget ceiling, this is Tier 3: documented design only.
In production, Terraform state replication to a DR region would be implemented with a
replication rule and a destination bucket in a second region. RTO for state loss in this
project: re-run `infra/bootstrap/`, worst case 30 minutes.
**Tier:** 3 (documented design — not implemented).
**Checkov skip:** `#checkov:skip=CKV_AWS_144` in `infra/bootstrap/main.tf` on both S3 bucket resources.
**Expiry:** 2027-07-13.

---

## EXC-010: S3 buckets do not have event notifications enabled (CKV2_AWS_62)

**Requirement:** CKV2_AWS_62 — S3 buckets should have event notifications enabled.
**Reason:** Event notifications on the Terraform state bucket and the access-log bucket would
route to an SNS topic or Lambda for near-real-time change alerting. For a static portfolio with
CloudTrail enabled account-wide, every S3 API call is already audited. Adding event notifications
on the state bucket duplicates CloudTrail coverage at extra cost and operational overhead.
Event notifications on the site bucket (future) are covered by EXC-005 (content integrity
monitoring). Tier 3 for state and log buckets.
**Tier:** 3 (documented design — not implemented; CloudTrail substitutes).
**Checkov skip:** `#checkov:skip=CKV2_AWS_62` in `infra/bootstrap/main.tf` on both S3 bucket resources.
**Expiry:** 2027-07-13.

---

## EXC-011: DNSSEC not enabled on Route 53 hosted zone (CKV2_AWS_38)

**Requirement:** CKV2_AWS_38 — Route 53 hosted zone should have DNSSEC signing enabled.
**Reason:** DNSSEC requires a DS (Delegation Signer) record to be set at the domain registrar
on top of a delegation that is currently being newly established. A mismatched or prematurely
set DS record makes the entire domain unresolvable for the duration of the DS record's TTL at
the parent zone. Enabling DNSSEC before the NS delegation is proven stable is an availability
risk that outweighs the integrity benefit during initial cutover. This is an explicit
availability-over-integrity trade-off, not a cost or complexity decision.
Implementation path: once the site is live, the NS delegation is confirmed stable, and Sprint 2
is complete, add `aws_route53_key_signing_key` and `aws_route53_hosted_zone_dnssec` to the dns
module, then add the DS record at the registrar.
**Tier:** 2 (DNSSEC is a legitimate production control; deliberately deferred, not permanently skipped).
**Checkov skip:** `#checkov:skip=CKV2_AWS_38` inline in `infra/modules/dns/main.tf`.
**Expiry:** Post Sprint 2 (once NS delegation is proven stable and site is live). Target: 2026-08-31.

---

## Adding a new exception

Copy the template below. Do NOT merge a PR that adds a `skip-check` to
`.checkov.yaml` or `.tflint.hcl` without a corresponding entry here.

```
## EXC-XXX: <short title>

**Requirement:** <what standard or check is being skipped>
**Reason:** <why; reference the constraint>
**Tier:** <1/2/3>
**Expiry:** <YYYY-MM-DD or named milestone>
```
