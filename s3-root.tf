resource "aws_s3_bucket" "root" {
  bucket = local.bucket_name
  tags   = var.tags
}

resource "aws_s3_bucket_cors_configuration" "root" {
  bucket = aws_s3_bucket.root.id

  cors_rule {
    allowed_headers = ["Authorization", "Content-Length"]
    allowed_methods = ["GET", "POST"]
    allowed_origins = ["https://${local.domain_name}"]
    max_age_seconds = 3000
  }
}

resource "aws_s3_bucket_ownership_controls" "root" {
  bucket = aws_s3_bucket.root.id
  rule {
    object_ownership = "ObjectWriter"
  }
}

# to turn off Block public access (bucket settings)
resource "aws_s3_bucket_public_access_block" "root" {
  count = (local.origin_access == "public") ? 1 : 0

  bucket                  = aws_s3_bucket.root.id
  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

resource "aws_s3_bucket_acl" "root" {
  count = (local.origin_access == "public") ? 1 : 0

  bucket     = aws_s3_bucket.root.id
  acl        = "public-read"
  depends_on = [aws_s3_bucket_public_access_block.root, aws_s3_bucket_ownership_controls.root]
}

resource "aws_s3_bucket_policy" "root" {
  bucket     = aws_s3_bucket.root.id
  policy     = (local.origin_access == "oac") ? data.aws_iam_policy_document.root_access_oac[0].json : (local.origin_access == "oai") ? data.aws_iam_policy_document.root_access_oai[0].json : data.aws_iam_policy_document.root_access_public[0].json
  depends_on = [aws_s3_bucket_acl.root]
}

resource "aws_s3_bucket_website_configuration" "root" {
  bucket = aws_s3_bucket.root.id

  index_document {
    suffix = "index.html"
  }

  error_document {
    key = "error.html"
  }
}

