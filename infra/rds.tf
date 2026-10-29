resource "random_password" "db" {
  length  = 20
  special = false
}

resource "aws_subnet" "db" {
  vpc_id                  = aws_vpc.dome.id
  cidr_block              = "10.20.2.0/24"
  availability_zone       = data.aws_availability_zones.available.names[1]
  map_public_ip_on_launch = false

  tags = {
    Name = "${var.name}-db"
  }
}

resource "aws_db_subnet_group" "dome" {
  name       = var.name
  subnet_ids = [aws_subnet.public.id, aws_subnet.db.id]

  tags = {
    Name = var.name
  }
}

resource "aws_security_group" "db" {
  name        = "${var.name}-db"
  description = "PostgreSQL from the demo EC2 only"
  vpc_id      = aws_vpc.dome.id

  tags = {
    Name = "${var.name}-db"
  }
}

resource "aws_vpc_security_group_ingress_rule" "postgres" {
  security_group_id            = aws_security_group.db.id
  description                  = "PostgreSQL from EC2"
  ip_protocol                  = "tcp"
  from_port                    = 5432
  to_port                      = 5432
  referenced_security_group_id = aws_security_group.dome.id
}

resource "aws_db_instance" "dome" {
  identifier        = var.name
  engine            = "postgres"
  engine_version    = "16"
  instance_class    = var.db_instance_class
  allocated_storage = 20
  storage_type      = "gp2"
  storage_encrypted = true

  db_name  = "dome"
  username = "dome"
  password = random_password.db.result

  db_subnet_group_name   = aws_db_subnet_group.dome.name
  vpc_security_group_ids = [aws_security_group.db.id]
  publicly_accessible    = false
  multi_az               = false

  backup_retention_period = 0
  skip_final_snapshot     = true
  deletion_protection     = false
  apply_immediately       = true

  performance_insights_enabled = false
  monitoring_interval          = 0

  tags = {
    Name = var.name
  }
}
