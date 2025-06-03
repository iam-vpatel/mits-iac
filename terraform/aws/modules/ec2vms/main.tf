# Pull in existing resources
data "aws_subnet" "ec2_subnet" {
  id = var.subnet_id
}

data "aws_security_group" "ec2_sg" {
  id = var.security_group_id
}

data "aws_iam_instance_profile" "iam_profile" {
  name = var.iam_instance_profile
}

data "aws_key_pair" "ssh_key" {
  key_name = var.key_name
}

resource "aws_instance" "ec2vms" {
  count         = var.instance_count
  key_name      = data.aws_key_pair.ssh_key.key_name
  ami           = var.ami_id
  instance_type = var.instance_type

  subnet_id                   = data.aws_subnet.ec2_subnet.id
  vpc_security_group_ids      = [data.aws_security_group.ec2_sg.id]
  iam_instance_profile        = data.aws_iam_instance_profile.iam_profile.name
  associate_public_ip_address = false

  root_block_device {
    volume_size           = var.root_volume_size
    volume_type           = var.root_volume_type
    delete_on_termination = var.root_delete_on_termination

    encrypted  = var.root_volume_encrypted
    kms_key_id = var.kms_key_id
  }

  ebs_block_device {
    device_name           = var.ebs_device_name
    volume_size           = var.ebs_volume_size
    volume_type           = var.ebs_volume_type
    delete_on_termination = var.ebs_delete_on_termination

    encrypted  = var.ebs_volume_encrypted
    kms_key_id = var.kms_key_id
  }

  user_data = templatefile("${path.module}/scripts/init-hostname.sh.tpl", {
    function    = var.function
    environment = var.environment
    prefix_name = var.prefix_name
    index       = count.index + 1
  })

  tags = {
    Name        = "${var.prefix_name}-${var.environment}-${var.function}-${count.index + 1}"
    Environment = var.environment
  }
  # nextgen-dev-demo-01
  volume_tags = {
    Name        = "${var.prefix_name}-${var.environment}-${var.function}-${count.index + 1}"
    Environment = var.environment
  }
}
