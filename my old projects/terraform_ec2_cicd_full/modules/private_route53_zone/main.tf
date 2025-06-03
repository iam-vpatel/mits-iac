
resource "aws_route53_zone" "private_zone" {
  name = var.domain_name
  vpc {
    vpc_id = var.vpc_id
  }
  comment     = "Private zone for internal resolution"
  force_destroy = true
}

resource "aws_route53_record" "internal" {
  zone_id = aws_route53_zone.private_zone.zone_id
  name    = var.record_name
  type    = "A"
  ttl     = 300
  records = [var.private_ip]
}
