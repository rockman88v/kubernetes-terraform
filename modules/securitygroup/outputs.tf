
output "securitygroup" {
  value = aws_security_group.this
  description = "Map of public security groups : port => sg"  
}
output "securitygroup_id" {
  value = aws_security_group.this.id
  description = "Security group Id" 
}