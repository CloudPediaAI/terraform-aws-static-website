# S3 bucket for redirecting www.domain to domain
resource "aws_s3_bucket" "web_portal_redirect" {
  count = (var.need_www_redirect) ? 1 : 0

  bucket = "www.${local.bucket_name}"
  tags   = var.tags
}

resource "aws_s3_bucket_ownership_controls" "web_portal_redirect_acl_ownership" {
  count = (var.need_www_redirect) ? 1 : 0

  bucket = aws_s3_bucket.web_portal_redirect[0].id
  rule {
    object_ownership = "ObjectWriter"
  }
}

resource "aws_s3_bucket_policy" "web_portal_redirect_policy" {
  count = (var.need_www_redirect) ? 1 : 0

  bucket     = aws_s3_bucket.web_portal_redirect[0].id
  policy = data.aws_iam_policy_document.www_access_public[0].json
  # policy     = (local.origin_access == "oac") ? data.aws_iam_policy_document.www_access_oac[0].json : (local.origin_access == "oai") ? data.aws_iam_policy_document.www_access_oai[0].json : data.aws_iam_policy_document.www_access_public[0].json
  depends_on = [aws_s3_bucket_ownership_controls.web_portal_redirect_acl_ownership]
}

resource "aws_s3_bucket_website_configuration" "web_portal_redirect_config" {
  count = (var.need_www_redirect) ? 1 : 0

  bucket = aws_s3_bucket.web_portal_redirect[0].id
  redirect_all_requests_to {
    host_name = local.domain_name
  }
}
