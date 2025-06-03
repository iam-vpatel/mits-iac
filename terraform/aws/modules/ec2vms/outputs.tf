output "instance_ids" {
  description = "IDs of created EC2 instances"
  value       = aws_instance.ec2vms[*].id
}

output "public_ips" {
  description = "Public IPs of EC2 instances"
  value       = aws_instance.ec2vms[*].public_ip
}

output "private_ips" {
  description = "Private IPs of EC2 instances"
  value       = aws_instance.ec2vms[*].private_ip
}

output "hostnames" {
  description = "Assigned hostnames"
  value       = [for i in aws_instance.ec2vms : i.tags["Name"]]
}
