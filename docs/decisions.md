# Day-to-day decisions

Small calls that do not warrant a full ADR. Promote to an ADR if alternatives
were meaningfully considered or if the decision has cost/security consequences.

---

## 2026-07-13: AWS Budgets USD threshold set to $63

AWS Budgets is denominated in USD. The PRD target is £50/month. Using a
fixed conversion of 1 GBP = 1.26 USD (mid-market, July 2026), $63 is the
nearest round number above £50. The threshold is not dynamically linked to
the exchange rate; review annually or if GBP/USD moves more than 10%.

Owner: John.

---

## 2026-07-13: Terraform state bootstrap uses local state by design

The state bucket cannot store its own creation state — the classic
chicken-and-egg problem. Resolution: `infra/bootstrap/` is a minimal
separate Terraform config with local state (`.gitignore`d) that creates
only the S3 bucket and DynamoDB lock table. Once those exist, all other
configs point their backends at the bucket. The bootstrap state file is
discarded after the bucket is verified; if the bucket is ever recreated,
re-run `infra/bootstrap/` from scratch. Documented in `docs/runbooks/`.

Owner: John.
