resource "aws_acm_certificate" "root" {
  provider                  = aws.us-east-1
  domain_name               = local.domain_name
  validation_method         = "DNS"
  # subject_alternative_names = [local.www_domain_name]

  tags = var.tags

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_route53_record" "root_validation" {
  for_each = {
    for dvo in aws_acm_certificate.root.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }

  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  ttl             = 60
  type            = each.value.type
  zone_id         = (var.hosted_zone_id != null) ? data.aws_route53_zone.by_id[0].zone_id : data.aws_route53_zone.by_name[0].zone_id
}

resource "aws_acm_certificate_validation" "root" {
  provider                = aws.us-east-1
  certificate_arn         = aws_acm_certificate.root.arn
  validation_record_fqdns = [for record in aws_route53_record.root_validation : record.fqdn]
}
