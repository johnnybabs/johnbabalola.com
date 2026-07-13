# Runbook: manual site deploy (Sprint 1)

Until the GitHub Actions pipeline lands (Sprint 2), the placeholder site is
uploaded by hand. This is the only manual content step in Sprint 1.

## Prerequisites

- AWS CLI v2 authenticated to the account (John runs `aws sso login` or `aws configure`).
- The `site` module applied, so the bucket and distribution exist.

## Steps

Read the resource names from Terraform outputs rather than hardcoding them:

```bash
cd infra
BUCKET=$(terraform output -raw site_bucket_id)
DIST=$(terraform output -raw cloudfront_distribution_id)

# Upload the static files (index.html, 404.html, style.css).
aws s3 sync ../site/ "s3://${BUCKET}/" --delete \
  --exclude ".*" \
  --cache-control "public, max-age=300"

# Invalidate the edge cache so the new content is served immediately.
aws cloudfront create-invalidation --distribution-id "${DIST}" --paths "/*"
```

## Verify

```bash
curl -I https://johnbabalola.com          # 200, security headers present
curl -I https://www.johnbabalola.com      # 301 to https://johnbabalola.com
curl -s -o /dev/null -w "%{http_code}" https://johnbabalola.com/does-not-exist  # 404
```

## Notes

- `--delete` removes objects in the bucket that are no longer in `site/`, keeping
  the bucket a faithful mirror of the source.
- The `.*` exclude keeps dotfiles out of the bucket.
- In Sprint 2 this is replaced by `deploy.yml`, which does the same `sync` and
  targeted invalidation under the OIDC deploy role.
