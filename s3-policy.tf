
data "aws_iam_policy_document" "root_access_public" {
  count = (local.origin_access == "public") ? 1 : 0

  statement {
    sid = "allowReqFromPublic"
    effect = "Allow"

    principals {
      type        = "*"
      identifiers = ["*"]
    }

    actions = [
      "s3:GetObject"
    ]

    resources = [
      aws_s3_bucket.web_portal.arn,
      "${aws_s3_bucket.web_portal.arn}/*"
    ]

  }
}

data "aws_iam_policy_document" "root_access_oac" {
  count = (local.origin_access == "oac") ? 1 : 0

  statement {
    sid = "denyHTTPrequests"
    effect = "Deny"
    actions = ["s3:*"]

    principals {
      type        = "*"
      identifiers = ["*"]
    }

    resources = [
      aws_s3_bucket.web_portal.arn,
      "${aws_s3_bucket.web_portal.arn}/*"
    ]

    condition {
      test     = "Bool"
      variable = "aws:SecureTransport"
      values = ["false"]
    }
  }

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
      "${aws_s3_bucket.web_portal.arn}/*"
    ]

    condition {
      test     = "StringEquals"
      variable = "AWS:SourceArn"
      values   = [format("arn:aws:cloudfront::%s:distribution/%s", data.aws_caller_identity.current.account_id, aws_cloudfront_distribution.oac[0].id)]
    }
  }
}

data "aws_iam_policy_document" "root_access_oai" {
  count = (local.origin_access == "oai") ? 1 : 0

  statement {
    sid = "denyHTTPrequests"
    effect = "Deny"
    actions = ["s3:*"]

    principals {
      type        = "*"
      identifiers = ["*"]
    }

    resources = [
      aws_s3_bucket.web_portal.arn,
      "${aws_s3_bucket.web_portal.arn}/*"
    ]

    condition {
      test     = "Bool"
      variable = "aws:SecureTransport"
      values = ["false"]
    }
  }
  
  statement {
    sid = "allowReqFromCloudFrontOnly"
    effect = "Allow"
    actions = ["s3:GetObject"]

    principals {
      type        = "AWS"
      identifiers = [aws_cloudfront_origin_access_identity.oai[0].iam_arn]
    }

    resources = [
      "${aws_s3_bucket.web_portal.arn}/*"
    ]
  }
}


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
      "${aws_s3_bucket.web_portal_redirect[0].arn}/*"
    ]

    condition {
      test     = "StringEquals"
      variable = "AWS:SourceArn"
      values   = [format("arn:aws:cloudfront::%s:distribution/%s", data.aws_caller_identity.current.account_id, aws_cloudfront_distribution.public_www[0].id)]
    }
  }
}
