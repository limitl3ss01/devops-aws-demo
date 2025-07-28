output "public_ip" {
  value = aws_instance.devops_ec2.public_ip
}

output "security_group_id" {
  value = aws_security_group.devops_sg.id
}

output "instance_id" {
  value = aws_instance.devops_ec2.id
} 