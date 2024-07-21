# Create RDS for persistent storage
resource "aws_db_instance" "counter_mysql" {
  allocated_storage    = 20
  engine               = "mysql"
  engine_version       = "8.0"
  instance_class       = "db.t3.micro"
  db_name              = "counterdb"
  username             = "amit"
  password             = "password"
  skip_final_snapshot  = true
  vpc_security_group_ids = [aws_security_group.counter_rds.id]
  db_subnet_group_name   = aws_db_subnet_group.private_subnets.name
}

resource "aws_security_group" "counter_rds" {
  vpc_id = aws_vpc.counter_vpc.id

  ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/24"] # Adjust according to your VPC CIDR
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "rds-security-group"
  }
}

resource "aws_db_subnet_group" "private_subnets" {
  name       = "amit-counter-db-subnet-group"

  subnet_ids = [for sn in aws_subnet.private_subnet : sn.id]

  tags = {
    Name = "amit-counter-db-subnet-group"
  }
}