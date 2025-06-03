
terraform {
  backend "s3" {
    bucket = "my-terraform-states"
    key    = "ec2-route53/terraform.tfstate"
    region = "us-east-1"
  }
}
