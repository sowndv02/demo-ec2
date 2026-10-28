data "aws_availability_zones" "available" {
  state = "available"

  filter {
    name   = "opt-in-status"
    values = ["opt-in-not-required"]
  }
}

data "aws_ssm_parameter" "al2023" {
  name = "/aws/service/ami-amazon-linux-latest/al2023-ami-kernel-default-x86_64"
}

resource "aws_vpc" "dome" {
  cidr_block           = "10.20.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = var.name
  }
}

resource "aws_internet_gateway" "dome" {
  vpc_id = aws_vpc.dome.id

  tags = {
    Name = var.name
  }
}

resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.dome.id
  cidr_block              = "10.20.1.0/24"
  availability_zone       = data.aws_availability_zones.available.names[0]
  map_public_ip_on_launch = true

  tags = {
    Name = "${var.name}-public"
  }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.dome.id

  tags = {
    Name = "${var.name}-public"
  }
}

resource "aws_route" "public_internet" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.dome.id
}

resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}

resource "aws_security_group" "dome" {
  name        = var.name
  description = "SSH and Dome app port"
  vpc_id      = aws_vpc.dome.id

  tags = {
    Name = var.name
  }
}

resource "aws_vpc_security_group_ingress_rule" "ssh" {
  security_group_id = aws_security_group.dome.id
  description       = "SSH"
  ip_protocol       = "tcp"
  from_port         = 22
  to_port           = 22
  cidr_ipv4         = var.ssh_cidr
}

resource "aws_vpc_security_group_ingress_rule" "app" {
  security_group_id = aws_security_group.dome.id
  description       = "Dome HTTP"
  ip_protocol       = "tcp"
  from_port         = 8080
  to_port           = 8080
  cidr_ipv4         = var.app_cidr
}

resource "aws_vpc_security_group_egress_rule" "all" {
  security_group_id = aws_security_group.dome.id
  description       = "All outbound"
  ip_protocol       = "-1"
  cidr_ipv4         = "0.0.0.0/0"
}

resource "tls_private_key" "dome" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "dome" {
  key_name   = var.name
  public_key = tls_private_key.dome.public_key_openssh

  tags = {
    Name = var.name
  }
}

resource "local_sensitive_file" "private_key" {
  filename        = "${path.module}/${var.name}.pem"
  content         = tls_private_key.dome.private_key_pem
  file_permission = "0400"
}

resource "aws_instance" "dome" {
  ami                         = data.aws_ssm_parameter.al2023.value
  instance_type               = var.instance_type
  subnet_id                   = aws_subnet.public.id
  vpc_security_group_ids      = [aws_security_group.dome.id]
  key_name                    = aws_key_pair.dome.key_name
  associate_public_ip_address = true
  user_data = templatefile("${path.module}/user-data.sh", {
    repo_url = var.repo_url
  })
  user_data_replace_on_change = true

  metadata_options {
    http_endpoint = "enabled"
    http_tokens   = "required"
  }

  tags = {
    Name = var.name
  }

  depends_on = [aws_route.public_internet]

  lifecycle {
    ignore_changes = [ami]
  }
}
