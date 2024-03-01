data "aws_iam_policy_document" "www_access_public" {
  count = (var.need_www_redirect) ? 1 : 0

  statement {
    sid = "allowReqFromCloudFrontOnly"
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["cloudfront.amazonaws.com"]
    }


    actions = [
      "s3:GetObject"
    ]

    resources = [
      "${aws_s3_bucket.www[0].arn}/*"
    ]

    condition {
      test     = "StringEquals"
      variable = "AWS:SourceArn"
      values   = [format("arn:aws:cloudfront::%s:distribution/%s", data.aws_caller_identity.current.account_id, aws_cloudfront_distribution.public_www[0].id)]
    }
  }
}
