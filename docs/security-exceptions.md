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
