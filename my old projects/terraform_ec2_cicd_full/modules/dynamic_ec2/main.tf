
resource "aws_instance" "dynamic_ec2" {
  for_each = var.instances

  ami                         = each.value.ami
  instance_type               = each.value.instance_type
  subnet_id                   = each.value.subnet_id
  associate_public_ip_address = false

  tags = merge(each.value.tags, {
    Name = each.key
  })
}
