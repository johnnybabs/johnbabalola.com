# Runbook: leaked credential or abused OIDC role

Written: 2026-07-13 (before first deploy — required by DevSecOps standard).
Owner: John Babalola.

This runbook covers two scenarios: (a) the GitHub Actions OIDC role credentials
appear in logs or are used outside the expected workflow, and (b) a long-lived
AWS access key is found in git history or a log (this project does not create
long-lived keys, but the response is the same if one is found in another project).

---

## Step 1: Revoke trust immediately

**For the OIDC role (primary path):**

```bash
# Remove the trust policy from the OIDC role to prevent any further
# credential issuance. This stops the bleeding without deleting the role.
aws iam update-assume-role-policy \
  --role-name johnbabalola-com-github-deploy \
  --policy-document '{"Version":"2012-10-17","Statement":[]}'
```

This severs GitHub Actions' ability to assume the role. Active sessions
using credentials already issued remain valid until they expire (typically
1 hour). Proceed to Step 2 immediately.

**For a static access key (if one is ever found):**

```bash
aws iam update-access-key \
  --access-key-id <KEY_ID> \
  --status Inactive \
  --user-name <USERNAME>
# Then delete it:
aws iam delete-access-key \
  --access-key-id <KEY_ID> \
  --user-name <USERNAME>
```

---

## Step 2: Audit CloudTrail for use

Open the AWS console → CloudTrail → Event history, or run:

```bash
# Check last 24 hours of API calls by the OIDC role
aws cloudtrail lookup-events \
  --lookup-attributes AttributeKey=Username,AttributeValue=johnbabalola-com-github-deploy \
  --start-time "$(date -u -d '24 hours ago' +%Y-%m-%dT%H:%M:%SZ)" \
  --query 'Events[*].{Time:EventTime,Name:EventName,Source:EventSource,IP:CloudTrailEvent}' \
  --output table
```

Look for any `s3:PutObject`, `s3:DeleteObject`, or `cloudfront:CreateInvalidation`
calls that do not correspond to a known GitHub Actions run. Cross-reference
the GitHub Actions run history at:
`https://github.com/johnnybabs/johnbabalola.com/actions`

---

## Step 3: Assess the impact

- Were any S3 objects written or deleted outside a legitimate deploy?
  If yes: audit current bucket contents against the last known-good deploy commit.
- Were any CloudFront invalidations created outside a legitimate deploy?
  If yes: verify the cache is serving the correct content (`curl -I https://johnbabalola.com`).
- Was any content modified that would be visible to visitors?
  If yes: proceed to Step 4 (restore).

---

## Step 4: Restore clean content (if needed)

```bash
# Redeploy from the last known-good commit
git checkout <last-known-good-sha>
aws s3 sync site/dist/ s3://<bucket-name>/ --delete
aws cloudfront create-invalidation \
  --distribution-id <distribution-id> \
  --paths "/*"
```

Verify with `curl -I https://johnbabalola.com` and check the site visually.

---

## Step 5: Rebuild the role trust (after investigation)

Once you have confirmed the blast radius and restored clean state, rebuild
the OIDC role via Terraform:

```bash
cd infra && terraform apply -target=module.github_oidc
```

This reinstates the trust policy with the pinned condition
`repo:johnnybabs/johnbabalola.com:ref:refs/heads/main`.

---

## Step 6: Post-incident

- Record the incident in `docs/decisions.md` with date, nature of compromise,
  and outcome.
- If any third-party action's SHA was involved, update the pin and file a
  Dependabot-style PR.
- Review and tighten the OIDC trust condition if needed.
- Set a reminder to re-verify CloudTrail is still enabled after the incident.

---

## Contact

AWS account: John Babalola (sole operator).
GitHub repo: https://github.com/johnnybabs/johnbabalola.com
AWS region: eu-west-2 (resources), us-east-1 (ACM cert).
