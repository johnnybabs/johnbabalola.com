# Origin Access Control — the current AWS-recommended replacement for OAI.
# CloudFront signs origin requests with SigV4; the bucket policy trusts only
# this distribution (see s3.tf).
resource "aws_cloudfront_origin_access_control" "site" {
  name                              = "${var.bucket_name}-oac"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

# Redirects www.<domain> to the apex at the edge (viewer-request), before the
# origin is hit. Cheaper and faster than a redirect bucket.
resource "aws_cloudfront_function" "www_redirect" {
  name    = "${replace(var.domain_name, ".", "-")}-www-redirect"
  runtime = "cloudfront-js-2.0"
  comment = "Redirect www.${var.domain_name} to the apex"
  publish = true
  code    = file("${path.module}/functions/www-redirect.js")
}

# Security headers applied to every response: HSTS (2 years, subdomains,
# preload-ready), nosniff, and frame-deny. Satisfies the Tier 1 headers policy.
resource "aws_cloudfront_response_headers_policy" "security" {
  name = "${replace(var.domain_name, ".", "-")}-security-headers"

  security_headers_config {
    strict_transport_security {
      access_control_max_age_sec = 63072000
      include_subdomains         = true
      preload                    = true
      override                   = true
    }
    content_type_options {
      override = true
    }
    frame_options {
      frame_option = "DENY"
      override     = true
    }
    referrer_policy {
      referrer_policy = "strict-origin-when-cross-origin"
      override        = true
    }
  }
}

resource "aws_cloudfront_distribution" "site" {
  #checkov:skip=CKV_AWS_68:WAF is not deployed on this portfolio distribution; no user input or backend, and WAF exceeds the site's monthly budget. Tier 3. See EXC-004.
  #checkov:skip=CKV_AWS_86:CloudFront access logging is a v1 backlog item (PRD section 3); standard logs add an ACL-enabled log bucket that conflicts with the Block-Public-Access baseline. See EXC-014.
  #checkov:skip=CKV2_AWS_47:Log4j/WAF managed rule protection is not applicable to a static HTML site with no application backend. Tied to the WAF decision. See EXC-004.
  #checkov:skip=CKV_AWS_374:Geo restriction is intentionally none — the site must be globally reachable for recruiters anywhere. See EXC-015.
  #checkov:skip=CKV_AWS_310:Origin failover needs a second origin; a single-bucket static site rebuilt from git has no failover target and no availability requirement justifying one. See EXC-015.
  enabled             = true
  is_ipv6_enabled     = true
  comment             = var.domain_name
  default_root_object = "index.html"
  price_class         = "PriceClass_100" # North America + Europe; sufficient for UK-facing traffic
  aliases             = [var.domain_name, "www.${var.domain_name}"]

  origin {
    origin_id                = "s3-${aws_s3_bucket.site.id}"
    domain_name              = aws_s3_bucket.site.bucket_regional_domain_name
    origin_access_control_id = aws_cloudfront_origin_access_control.site.id
  }

  default_cache_behavior {
    target_origin_id           = "s3-${aws_s3_bucket.site.id}"
    viewer_protocol_policy     = "redirect-to-https"
    allowed_methods            = ["GET", "HEAD"]
    cached_methods             = ["GET", "HEAD"]
    compress                   = true
    response_headers_policy_id = aws_cloudfront_response_headers_policy.security.id

    # AWS managed CachingOptimized policy id.
    cache_policy_id = "658327ea-f89d-4fab-a63d-7e88639e58f6"

    function_association {
      event_type   = "viewer-request"
      function_arn = aws_cloudfront_function.www_redirect.arn
    }
  }

  # SPA-style: serve a real 404 page for missing objects.
  custom_error_response {
    error_code            = 403
    response_code         = 404
    response_page_path    = "/404.html"
    error_caching_min_ttl = 60
  }
  custom_error_response {
    error_code            = 404
    response_code         = 404
    response_page_path    = "/404.html"
    error_caching_min_ttl = 60
  }

  viewer_certificate {
    acm_certificate_arn      = var.certificate_arn
    ssl_support_method       = "sni-only"
    minimum_protocol_version = "TLSv1.2_2021"
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }
}
