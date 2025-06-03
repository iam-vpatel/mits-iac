
resource "aws_instance" "this" {
  count         = var.instance_count
  ami           = var.ami_id
  instance_type = var.instance_type
  subnet_id     = var.subnet_id
  associate_public_ip_address = false

  tags = merge(var.tags, {
    Name = "${var.hostname}"
  })
}

output "private_ip" {
  value = aws_instance.this[0].private_ip
}

output "hostname" {
  value = var.hostname
}
