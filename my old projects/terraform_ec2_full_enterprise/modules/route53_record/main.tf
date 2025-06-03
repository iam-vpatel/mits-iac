
resource "aws_route53_record" "fqdn" {
  zone_id = var.zone_id
  name    = var.record_name
  type    = "A"
  ttl     = 300
  records = [var.target_ip]
}
