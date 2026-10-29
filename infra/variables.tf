variable "aws_region" {
  description = "Region cho stack demo. Xóa bằng terraform destroy trong thư mục này."
  type        = string
  default     = "ap-southeast-1"
}

variable "name" {
  description = "Tiền tố tên resource. Cả stack dùng chung tên này."
  type        = string
  default     = "dome-demo"
}

variable "instance_type" {
  description = "Loại EC2. t3.micro đủ để chạy container ASP.NET đã build sẵn."
  type        = string
  default     = "t3.micro"
}

variable "ssh_cidr" {
  description = "Dải IP được SSH vào cổng 22. Nên đổi thành IP của bạn, ví dụ 203.0.113.10/32."
  type        = string
  default     = "0.0.0.0/0"
}

variable "app_cidr" {
  description = "Dải IP được mở trang demo ở cổng 8080."
  type        = string
  default     = "0.0.0.0/0"
}

variable "db_instance_class" {
  description = "RDS một AZ, nhỏ nhất. db.t4g.micro nằm trong free tier nếu tài khoản còn hạn."
  type        = string
  default     = "db.t4g.micro"
}

variable "repo_url" {
  description = "Repo Git public. User-data clone repo này rồi chạy deploy/docker-up.sh."
  type        = string
  default     = "https://github.com/sowndv02/demo-ec2.git"
}
