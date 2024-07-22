# Create RDS for persistent storage
resource "aws_db_instance" "mysql" {
  identifier           = var.db_identifier
  allocated_storage    = var.db_allocated_storage
  engine               = var.db_engine
  engine_version       = var.db_version
  instance_class       = var.db_instance_type
  db_name              = var.db_name
  username             = var.db_username
  password             = var.db_password
  skip_final_snapshot  = true
  vpc_security_group_ids = [aws_security_group.rds.id]
  db_subnet_group_name   = aws_db_subnet_group.private_subnets.name

  tags = {
    Name = var.db_identifier
  }
}

resource "aws_security_group" "rds" {
  name = var.db_security_group_name
  vpc_id = aws_vpc.vpc.id

  ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr_block]
  }

  tags = {
    Name = var.db_security_group_name
  }
}

resource "aws_db_subnet_group" "private_subnets" {
  name       = var.db_subnet_group_name
  subnet_ids = [for sn in aws_subnet.private_subnet : sn.id]

  tags = {
    Name = var.db_subnet_group_name
  }
}