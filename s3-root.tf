locals {
  mime_types = {
    "css"  = "text/css"
    "html" = "text/html"
    "ico"  = "image/vnd.microsoft.icon"
    "js"   = "application/javascript"
    "json" = "application/json"
    "map"  = "application/json"
    "png"  = "image/png"
    "jpg"  = "image/jpg"
    "svg"  = "image/svg+xml"
    "txt"  = "text/plain"
  }
}

resource "aws_s3_bucket" "web_portal" {
  bucket = local.bucket_name
  tags   = var.tags
}

resource "aws_s3_bucket_cors_configuration" "web_portal_cors" {
  bucket = aws_s3_bucket.web_portal.id

  cors_rule {
    allowed_headers = ["Authorization", "Content-Length"]
    allowed_methods = ["GET", "POST"]
    allowed_origins = ["https://${local.domain_name}"]
    max_age_seconds = 3000
  }
}

resource "aws_s3_bucket_ownership_controls" "web_portal_acl_ownership" {
  bucket = aws_s3_bucket.web_portal.id
  rule {
    object_ownership = "ObjectWriter"
  }
}

# to turn off Block public access (bucket settings)
resource "aws_s3_bucket_public_access_block" "web_portal" {
  count = (local.origin_access == "public") ? 1 : 0

  bucket                  = aws_s3_bucket.web_portal.id
  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

resource "aws_s3_bucket_acl" "web_portal_acl" {
  count = (local.origin_access == "public") ? 1 : 0

  bucket     = aws_s3_bucket.web_portal.id
  acl        = "public-read"
  depends_on = [aws_s3_bucket_public_access_block.web_portal, aws_s3_bucket_ownership_controls.web_portal_acl_ownership]
}

resource "aws_s3_bucket_policy" "web_portal_policy" {
  bucket     = aws_s3_bucket.web_portal.id
  policy     = (local.origin_access == "oac") ? data.aws_iam_policy_document.root_access_oac[0].json : (local.origin_access == "oai") ? data.aws_iam_policy_document.root_access_oai[0].json : data.aws_iam_policy_document.root_access_public[0].json
  depends_on = [aws_s3_bucket_acl.web_portal_acl]
}

resource "aws_s3_bucket_website_configuration" "web_portal_webConfig" {
  bucket = aws_s3_bucket.web_portal.id

  index_document {
    suffix = "index.html"
  }

  error_document {
    key = "error.html"
  }
}

