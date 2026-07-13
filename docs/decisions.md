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

## 2026-07-13: S3 backend uses use_lockfile instead of dynamodb_table

`dynamodb_table` is deprecated in Terraform 1.10+. `use_lockfile = true` uses S3
conditional writes (`if-none-match`) for state locking, which requires versioning on
the bucket (already enabled) and no additional resources. The DynamoDB table
(`johnnybabs-terraform-locks`) was created in bootstrap and is retained as infrastructure
but is no longer wired to the S3 backend. It costs $0 at PAY_PER_REQUEST with no
operations and can be used by future projects that pin to Terraform < 1.10.

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
