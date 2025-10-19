output "region" {
  description = "AWS region used"
  value       = var.aws_region
}
output "instance_public_ip" {
  description = "Public IP of the EC2 instance"
  value       = aws_instance.web.public_ip
}

output "instance_url" {
  description = "Access your web app via this URL"
  value       = "http://${aws_instance.web.public_ip}"
}
