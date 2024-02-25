output "bucket" {
  value = aws_s3_bucket.web_portal
  description = "S3 Bucket created for the Static Website"
}

output "cloudfront" {
  value       = (local.origin_access == "public") ? aws_cloudfront_distribution.public[0] : (local.origin_access == "oac") ? aws_cloudfront_distribution.oac[0] : aws_cloudfront_distribution.oai[0]
  description = "CloudFront created for the Static Website"
}

output "website_url" {
  value       = "https://${local.domain_name}"
  description = "URL of the Static Website"
}
