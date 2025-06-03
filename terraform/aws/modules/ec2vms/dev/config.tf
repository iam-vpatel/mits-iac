terraform {
  backend "s3" {
    key = "ec2vms/dev/terraform.tfstate"
  }
}

module "ec2vms" {
  source = "../" # points to the parent TF module
  # EC2 VM Creation for MITS Next Gen VMS 
  prefix_name          = "nextgen"
  environment          = "dev"
  function             = "demo"
  aws_region           = "us-west-1"
  account_no           = "387367330562"
  kms_key_id           = "arn:aws:kms:us-west-1:387367330562:key/feeb054e-4752-4adc-b702-9d353543200f"
  key_name             = "mits-nonprod-nextgen"
  ami_id               = "ami-0307c96a1d5348b0d"
  instance_type        = "t2.micro"
  instance_count       = 1
  subnet_id            = "subnet-0aacd216efc47bdbb"
  security_group_id    = "sg-066c85fd4a44a8640"
  iam_instance_profile = "MitsEC2InstanceProfile"
  root_volume_size     = 10
  ebs_device_name      = "/dev/sdb"
  ebs_volume_size      = 10
  # Ansible Controller integration
  # ansible_token           = var.ansible_token
  # ansible_controller_host = var.ansible_controller_host
  # job_template_id         = var.job_template_id
}


