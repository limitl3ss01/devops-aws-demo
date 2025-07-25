variable "instance_type" {
  description = "Typ instancji EC2"
  default     = "t3.micro"
}

variable "key_name" {
  description = "Nazwa klucza SSH EC2"
  default     = "devops-aws-demo-key"
} 