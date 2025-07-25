output "ec2_public_ip" {
  description = "Publiczny adres IP EC2"
  value       = aws_instance.devops_ec2.public_ip
} 