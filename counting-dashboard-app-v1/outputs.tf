output "dashboard_app_url" {
  description = "Public URL to access the dashboard app"
  value       = "http://${aws_instance.dashboard.public_ip}:9009"
}

output "dashboard_instance_ip" {
  description = "Public IP of the dashboard instance"
  value       = aws_instance.dashboard.public_ip
}

output "counting_instance_ip" {
  description = "Private IP of the counting instance"
  value       = aws_instance.counting.private_ip
}

output "ssh_dashboard" {
  description = "SSH command to connect to the dashboard instance"
  value       = "ssh -i ${local.private_key_filename} ubuntu@${aws_instance.dashboard.public_ip}"
}

output "ssh_counting" {
  description = "SSH command to connect to the counting instance via dashboard (jump host)"
  value       = "ssh -i ${local.private_key_filename} -J ubuntu@${aws_instance.dashboard.public_ip} ubuntu@${aws_instance.counting.private_ip}"
}

output "db_endpoint" {
  description = "RDS PostgreSQL endpoint"
  value       = aws_db_instance.main.endpoint
}

output "db_password" {
  description = "RDS master password (sensitive)"
  value       = random_password.db.result
  sensitive   = true
}
