output "public_ip" {
  description = "IP public của EC2."
  value       = aws_instance.dome.public_ip
}

output "app_url" {
  description = "Trang demo sau khi container hoặc service đã chạy."
  value       = "http://${aws_instance.dome.public_ip}:8080"
}

output "ssh_command" {
  description = "Lệnh SSH từ thư mục infra."
  value       = "ssh -i ${var.name}.pem ec2-user@${aws_instance.dome.public_ip}"
}

output "db_endpoint" {
  description = "Địa chỉ private của RDS. Chỉ EC2 trong VPC tới được cổng 5432."
  value       = aws_db_instance.dome.address
}

output "private_key_path" {
  description = "Private key do Terraform tạo. terraform destroy sẽ xóa file này."
  value       = local_sensitive_file.private_key.filename
}
