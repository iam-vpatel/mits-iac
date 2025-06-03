
provider "aws" {
  region = var.aws_region
}

module "ec2_instance" {
  source         = "./modules/ec2"
  instance_count = 1
  instance_type  = "t2.micro"
  ami_id         = var.ami_id
  subnet_id      = var.subnet_id
  hostname       = "web01"
  domain_name    = var.domain_name
  tags = {
    Environment = "dev"
    Project     = "demo"
  }
}

module "dns_record" {
  source      = "./modules/route53_record"
  zone_id     = var.route53_zone_id
  record_name = "${module.ec2_instance.hostname}.${var.domain_name}"
  target_ip   = module.ec2_instance.private_ip
}
