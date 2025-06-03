
output "private_ip" {
  value = aws_instance.this[0].private_ip
}

output "hostname" {
  value = var.hostname
}
