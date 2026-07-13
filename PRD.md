# PRD: Portfolio website at johnbabalola.com

## 1. Objective

A permanent, recruiter-facing portfolio at `https://johnbabalola.com`, hosted on AWS, provisioned entirely with Terraform, deployed automatically by GitHub Actions on every push to `main`. The site is both the shop window and itself a demonstrable project: a recruiter can read the case studies AND inspect the repo that builds the thing they are looking at. Because all other project infrastructure is torn down after screenshots, this site is the permanent home of the evidence.

## 2. Users and success criteria

Primary user: a Belfast or remote-UK recruiter or hiring manager spending 60 to 90 seconds. Success: within one screen they know who John is, that he builds real AWS infrastructure, and where the proof lives. Secondary success: the repo itself reads as professional IaC (modules, OIDC pipeline, PR history).

Measurable definition of success: site live on the apex domain with TLS and an A grade on SSL Labs; Lighthouse performance and accessibility above 90; deploy pipeline from push to live under 3 minutes; total running cost under £1.50 per month.

## 3. Scope

In scope: apex + www, static site, 4 page types (home, projects index, project case study, CV), contact via mailto (no backend in v1), Route 53 hosted zone creation and subdomain readiness for later projects, GitHub Actions OIDC deploy with CloudFront invalidation, AWS Budgets alarms (the account-wide £25/£40 alerts live in this repo's Terraform since it is the permanent one).

Out of scope for v1 (backlog): contact form with SES (reuse CBAPrints pattern), analytics (CloudFront standard logs are enough), blog hosted on-site (Medium first, canonical links later), status subdomain.

## 4. Architecture

- S3 private bucket (no public access) holding the built site.
- CloudFront distribution with Origin Access Control (OAC) to the bucket, HTTP to HTTPS redirect, default root object `index.html`, custom error mapping 404 to `/404.html`.
- ACM certificate for `johnbabalola.com` and `*.johnbabalola.com` in `us-east-1` (CloudFront requirement), DNS-validated.
- Route 53 public hosted zone for `johnbabalola.com`; A/AAAA alias records for apex and `www` to CloudFront. The wildcard cert means later subdomain demos only need a record plus their own origin.
- Terraform: modules `dns`, `certificate`, `site` (S3+CloudFront+OAC), `budgets`, `github-oidc` (IAM role trusting the repo). Remote state in S3 with DynamoDB locking.
- CI/CD: on push to main, build the site, `aws s3 sync` with `--delete`, targeted CloudFront invalidation. OIDC role scoped to this bucket and distribution only.
- Site generator: Astro (static output) or plain HTML/CSS. Decision rule: if content authoring speed matters more than zero-dependency simplicity, Astro; the infrastructure is the point either way, no client-side framework.

Registrar note: if johnbabalola.com is NOT registered with Route 53, after the hosted zone is created its 4 NS records must be set at the registrar. This is the single manual step in the whole project.

## 5. Content plan

- Home: name, title line ("Cloud DevOps Engineer, Belfast"), 3-sentence intro, stack badges, links (GitHub, Medium, email, CV), work eligibility line ("UK Dependent Visa, eligible to work immediately").
- Projects index: card per project.
- Case-study template (one page per project, this structure is fixed): the problem; architecture diagram; key decisions and trade-offs; what broke and how it was fixed; measured outcomes; what it cost; teardown proof; link to repo and Medium post. Launch content: VidCast, CBAPrints, Two-Tier HA portal, and this website itself as case study 4. Projects B to E add pages as they ship.
- CV page: HTML rendering plus downloadable PDF (generated from the current `cv_gen.js` output; keep one canonical PDF).
- 404 page.

All copy follows CV writing rules: UK English, no em dashes as connectors, XYZ-style outcome sentences, no forbidden buzzwords, nothing claimed that is not in `CV.md`.

## 6. Sprint plan

### Sprint 1 (weekend 1): infrastructure live

Tasks: repo scaffold; Terraform backend; `dns` + `certificate` modules; NS records updated at registrar if needed; `site` module (S3, CloudFront, OAC); `budgets` module (£50 budget, £25/£40 alerts to baabalola@gmail.com); `github-oidc` module; placeholder index.html served over HTTPS on the apex.

Definition of done: `https://johnbabalola.com` serves the placeholder with valid TLS; `terraform plan` clean; no public S3 access; budget alert email confirmed received (trigger a test); screenshots in `docs/screenshots/`.

### Sprint 2 (weekend 2): pipeline and content

Tasks: GitHub Actions workflow (build, sync, invalidate) via OIDC; site skeleton and styling; home, CV page, projects index; VidCast and Two-Tier case studies written from `CV.md` and the project summary files; this-website case study; 404 page.

Definition of done: push to main goes live in under 3 minutes with no keys in the repo; Lighthouse 90+ on home and one case study; all links resolve; CBAPrints case study may carry over to a follow-up evening.

### Post-launch (1 evening): polish and announce

CBAPrints case study; SSL Labs check; add site URL to GitHub profile, CV contact line, email signature; draft Medium post 0 ("A portfolio site is a DevOps project: S3, CloudFront and OIDC from scratch") from `docs/` notes.

## 7. Deliverables checklist

- [ ] Repo `johnnybabs/johnbabalola.com` public with README (architecture diagram, cost table, pipeline badge)
- [ ] Terraform modules: dns, certificate, site, budgets, github-oidc
- [ ] GitHub Actions deploy workflow, OIDC, no stored keys
- [ ] Live site: home, projects, 3+ case studies, CV page, 404
- [ ] AWS Budgets alerts live (account-wide control for all later projects)
- [ ] `docs/metrics.md`: measured deploy time, Lighthouse scores, monthly cost
- [ ] Medium post 0 draft
- [ ] `CV.md` section 8 updated with: Route 53, ACM, CloudFront, Origin Access Control (after the work is real)

## 8. Cost

One-off: none (domain already owned; renewal about £10 per year at the registrar). Running: hosted zone $0.50/month, CloudFront + S3 + requests at portfolio traffic under $0.50/month, ACM free, total under £1.50/month. This stack is tagged `Teardown=false` and is never destroyed.

## 9. Risks

- NS propagation delay after registrar change: start Sprint 1 with the DNS step for this reason; validation can take hours.
- ACM cert stuck pending: almost always the NS records; verify with `dig NS johnbabalola.com`.
- Scope creep into web design: time-box styling to 3 hours; a clean, fast, plain site beats a half-finished fancy one.
- CV bullets: do not write any until `docs/metrics.md` holds real measured numbers.

## 10. CV bullets this project can honestly earn (final wording after measurement)

- "Shipped johnbabalola.com behind CloudFront with TLS via ACM, deploying in under [measured] minutes per release, by provisioning S3, Route 53 and Origin Access Control with Terraform and a GitHub Actions OIDC pipeline."
- "Eliminated long-lived AWS credentials from the deployment path, by scoping a GitHub Actions OIDC role to a single bucket and CloudFront distribution."
