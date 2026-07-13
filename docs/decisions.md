# Day-to-day decisions

Small calls that do not warrant a full ADR. Promote to an ADR if alternatives
were meaningfully considered or if the decision has cost/security consequences.

---

## 2026-07-13: AWS provider 6.x migration deferred; Dependabot ignores major bumps

Dependabot opened a PR bumping the AWS provider from 5.100.0 to 6.54.0. The repo pins
`~> 5.0`, and 6.x is a major release with breaking changes (resource schema and default
behaviour changes). Taking that as an automated weekly PR would repeatedly break CI and
risk silent behavioural drift. The decision: stay on 5.x for Sprint 1 and 2, and do the
6.x migration deliberately later as its own reviewed piece of work (read the upgrade guide,
run `terraform plan` against every module, verify no drift). To stop the PR reopening every
week, `dependabot.yml` now ignores `version-update:semver-major` for `hashicorp/aws`; minor
and patch 5.x updates continue to flow. The original Dependabot PR (#6) is closed with a
reference to this rule.

Owner: John.

---

## 2026-07-13: DNSSEC deferred until NS delegation is proven stable (EXC-011)

DNSSEC signing on a freshly delegated zone requires a DS record at the registrar. Setting
a DS record before verifying the NS delegation works is an availability risk: a mismatched
DS record makes the domain unresolvable. The decision is to defer DNSSEC until after Sprint 2,
once `dig NS johnbabalola.com` is stable and the site is confirmed live. Revisit date: 2026-08-31.
This is an availability-over-integrity trade-off, documented in EXC-011.

Owner: John.

---

## 2026-07-13: DNS module applied before PR merge — process incident and rule

**What happened:** The Task 4 PR (task/4-dns, PR #7) was created and the `terraform apply -target=module.dns` was run in the same step, before John had reviewed or merged the PR. The stated reason was that the zone must exist to surface NS records before the cert module can validate — which is technically true. The error was not flagging this in advance or framing it as an explicit exception in the PR description at the time of creation.

A second NS set (ns-1227.awsdns-25.org, ns-1717.awsdns-22.co.uk, ns-362.awsdns-45.com, ns-683.awsdns-21.net) was also reported by John as coming from "earlier in this project." Investigation showed only one zone exists in the account (Z07116311RZBVGH0PIBFJ, Terraform-managed, CallerReference: terraform-20260713142139047700000001, 2 records: NS + SOA only). The other NS set is not traceable to any zone in this AWS account; it likely originated from a zone created in a prior session and since deleted, or from a different AWS profile. No orphan was found or deleted.

**Rule going forward:** The order is PR → review → merge → apply. If a gate genuinely requires applying before merge (surfacing an ID or endpoint that must be in the PR description), that must be stated explicitly in the PR body at the time of creation: "Applied in advance of merge to surface [X]; reason: [Y]; John has reviewed the plan above." Silently applying first is not acceptable.

Owner: Claude Code (process failure), acknowledged 2026-07-13.

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
