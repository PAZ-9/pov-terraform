# Public URL (uses EIP DNS)
output "dashboard_app_url" {
  value = "http://${aws_eip.counting-dashboard.public_dns}:9009"
}

# Public IP
output "dashboard_app_ip" {
  value = aws_eip.counting-dashboard.public_ip
}

# Private IP of counting instance (for internal communication)
output "counting_private_ip" {
  value = aws_instance.counting-instance.private_ip
}

# SSH private key
output "dashboard_instance_private_key" {
  description = "Private key for SSH access"
  value       = tls_private_key.counting-dashboard-key.private_key_openssh
  sensitive   = true
}