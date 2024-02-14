output "instance" {
  value       = aws_instance.this
  description = "EC2 instance information"
}

output "instance_private_ips" {
  value       = aws_instance.this[*].private_ip
  description = "EC2 instances' private ip"
}

output "instance_public_ips" {
  value       = aws_instance.this[*].public_ip
  description = "EC2 instances' public ip"
}

output "instance_az" {
  value = aws_instance.this[*].availability_zone
  description = "Availability zone - use to update ebs-storageclass configuration"  
}
