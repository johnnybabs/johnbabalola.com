#!/usr/bin/env bash
set -euo pipefail

if [[ "${1:-}" != "--force" ]]; then
  cat <<'EOF'
ERROR: This stack is tagged Teardown=false.

  johnbabalola.com is the permanent portfolio site and the evidence
  archive for all other projects. It should NOT be destroyed.

  If you genuinely need to tear it down (e.g. domain transfer, account
  close), re-run with --force and be prepared to lose all live content:

      ./teardown.sh --force

EOF
  exit 1
fi

echo ""
echo "WARNING: --force passed. This will destroy the live site and all"
echo "         supporting infrastructure (CloudFront, S3, Route 53, ACM,"
echo "         budgets, OIDC role). The domain will go dark immediately."
echo ""
echo "Press Ctrl-C within 10 seconds to abort."
sleep 10

echo ""
echo "Running terraform destroy in infra/..."
cd "$(dirname "$0")/infra"
terraform destroy
