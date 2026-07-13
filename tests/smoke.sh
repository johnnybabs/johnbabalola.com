#!/usr/bin/env bash
# Smoke test: run after every deploy. Checks apex and www behaviour, TLS, and
# the three required security headers. Exit non-zero on any failure.
set -euo pipefail

DOMAIN="${1:-johnbabalola.com}"
APEX="https://${DOMAIN}"
WWW="https://www.${DOMAIN}"

pass() { echo "PASS: $1"; }
fail() { echo "FAIL: $1"; exit 1; }

# Apex returns HTTP 200
status=$(curl -s -o /dev/null -w "%{http_code}" "$APEX")
[ "$status" = "200" ] && pass "apex HTTP 200" || fail "apex returned $status"

# www redirects to apex (301 or 302)
redir=$(curl -s -o /dev/null -w "%{http_code}" "$WWW")
[[ "$redir" = "301" || "$redir" = "302" ]] && pass "www redirects ($redir)" || fail "www returned $redir, expected redirect"

# Security headers present on apex
headers=$(curl -s -I "$APEX")

echo "$headers" | grep -qi "strict-transport-security" \
  && pass "HSTS header present" || fail "HSTS header missing"

echo "$headers" | grep -qi "x-content-type-options" \
  && pass "X-Content-Type-Options header present" || fail "X-Content-Type-Options header missing"

echo "$headers" | grep -qi "x-frame-options" \
  && pass "X-Frame-Options header present" || fail "X-Frame-Options header missing"

echo ""
echo "All smoke tests passed for ${DOMAIN}"
