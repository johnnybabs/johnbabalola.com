# ADR-0003: Plain HTML/CSS as the site generator

Date: 2026-07-13
Status: Accepted

## Context

The site is a static portfolio: home, projects index, case-study pages, CV page,
and 404. No user-submitted data, no dynamic rendering, no client-side framework.
The primary success criterion (PRD section 2) is that a recruiter spending 60
to 90 seconds understands who John is and where the proof of work lives.

The infrastructure is the portfolio artefact, not the front-end framework. The
PRD constraint is: "no client-side framework, no cookies, no trackers." The
decision rule in PRD section 4 is: "if content authoring speed matters more than
zero-dependency simplicity, Astro; the infrastructure is the point either way."

## Options considered

| Dimension | Plain HTML/CSS (chosen) | Astro (static output) | Next.js static export |
|---|---|---|---|
| Monthly cost | Free (S3 + CloudFront, no build cost) | Free hosting; negligible build time on GitHub Actions free tier | Free hosting; longer build time |
| Implementation time | Immediate: write HTML, sync to S3 | ~2 hours: project scaffold, component authoring, build step, deploy wiring | ~4 hours: Next.js config for static export, no SSR needed here |
| Operational complexity | Minimal: no build step, no node_modules, no lock file to maintain | Low: npm ci, astro build, s3 sync; one more step in deploy.yml | Medium: Next.js version churn, peer dependencies, React overhead |
| Scalability ceiling | Content authoring becomes slow past ~20 pages without a template layer | Scales well: component reuse, content collections, MDX | Scales well, but overbuilt for a static portfolio |
| Security posture | Highest: no build toolchain to compromise; no npm supply chain; deploy artefact equals source | Good: npm supply chain is an additional attack surface; Trivy/npm audit needed | Same risk as Astro plus React's transitive dependencies |
| Attack surface introduced | None beyond the HTML files themselves | node_modules supply chain; Astro compiler; npm registry | node_modules supply chain; React; Next.js compiler; npm registry |
| Existing expertise | John can write HTML/CSS today | John would need to learn Astro component model | John has React experience from other contexts |
| Compliance fit | Highest: zero dependencies = zero CVEs to track; SCA trivially passes | SCA required for npm dependencies | SCA required; more dependencies to track |

## Decision

Option 1: plain HTML/CSS.

The infrastructure is the portfolio point; the site content is the explanation.
At the planned scale (4 page types, ~8 pages at launch), a template layer adds
no authoring speed benefit and introduces an npm supply chain. The build step
in Sprint 2's deploy workflow becomes `cp -r site/ site/dist/` rather than
`astro build` — one fewer failure mode.

**Revisit trigger:** if the number of case-study pages exceeds 12 and maintaining
consistent navigation and layout across plain HTML files becomes the bottleneck,
introduce Astro as the templating layer. Record that decision as a new ADR
superseding this one.

## Consequences

Positive: zero build toolchain, zero npm dependencies, no lock file, no CVEs
to track, smallest possible attack surface, instant deploy (s3 sync of static files).

Negative: no component reuse — navigation and footer must be duplicated across
pages or maintained via a shared include mechanism (planned: one shared CSS file,
navigation HTML repeated across pages, or a simple bash build script if needed
before the Astro threshold is reached).
