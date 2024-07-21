# VPC Setup
resource "aws_vpc" "counter_vpc" {
  cidr_block       = var.vpc_cidr_block
  enable_dns_support = true
  enable_dns_hostnames = true

  tags = {
    Name = var.vpc_name
    "kubernetes.io/cluster/${var.eks_cluster_name}" = "shared"
  }
}

# Create private subnets
resource "aws_subnet" "private_subnet" {
  count = 2
  vpc_id = aws_vpc.counter_vpc.id
  cidr_block = element(var.private_subnet_cidr, count.index)
  availability_zone = element(var.subnet_azs, count.index)

  tags = {
    Name = var.private_subnet_name
    "kubernetes.io/cluster/${var.eks_cluster_name}" = "shared"
    "kubernetes.io/role/internal-elb" = 1
  }
}

# Create public subnets
resource "aws_subnet" "public_subnet" {
  count = 2
  vpc_id            = "${aws_vpc.counter_vpc.id}"
  cidr_block = element(var.public_subnet_cidr, count.index)
  availability_zone = element(var.subnet_azs, count.index)

  tags = {
    Name = var.public_subnet_name
    "kubernetes.io/cluster/${var.eks_cluster_name}" = "shared"
    "kubernetes.io/role/elb" = 1
  }
}

# Create Internet Gateway
resource "aws_internet_gateway" "counter_gateway" {
  vpc_id = aws_vpc.counter_vpc.id

  tags = {
    Name = var.internet_gateway_name
  }
}

# Route table for Internet Gateway
resource "aws_route_table" "counter_route_table" {
  vpc_id = aws_vpc.counter_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.counter_gateway.id
  }

  tags = {
    Name = var.routing_table_name
  }
}

# Associate route table to subnet
resource "aws_route_table_association" "counter_route_table_associate" {
  count = 2
  subnet_id      = aws_subnet.public_subnet[count.index].id
  route_table_id = aws_route_table.counter_route_table.id
}


# Create Elastic IP
resource "aws_eip" "nat_eip" {
  domain = "vpc"

  tags = {
    Name = var.elastic_ip_name
  }
}

# Create NAT Gateway
resource "aws_nat_gateway" "counter_nat" {
  allocation_id = aws_eip.nat_eip.id
  subnet_id     = aws_subnet.public_subnet[0].id

  tags = {
    Name = var.nat_gateway_name
  }
}

# Add NAT to route table
resource "aws_route" "nat_route_table" {
  route_table_id = aws_vpc.counter_vpc.default_route_table_id
  destination_cidr_block  = "0.0.0.0/0"
  nat_gateway_id = aws_nat_gateway.counter_nat.id
}

resource "aws_default_security_group" "default" {
  vpc_id = aws_vpc.counter_vpc.id
}

resource "aws_security_group" "eks_nodes" {
  name   = "k8s-counter-sg"
  vpc_id = aws_vpc.counter_vpc.id

  tags = {
    Name = "k8s-data-plane-sg"
  }
}

resource "aws_security_group_rule" "counter_sg_worker_80" {
  security_group_id = aws_security_group.eks_nodes.id
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  cidr_blocks = [var.vpc_cidr_block]
}

resource "aws_security_group_rule" "eks_worker_ingress_443" {
  type              = "ingress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  security_group_id = aws_security_group.eks_nodes.id
  source_security_group_id = aws_security_group.eks_cluster.id
}

resource "aws_security_group_rule" "eks_worker_ingress_10250" {
  type              = "ingress"
  from_port         = 10250
  to_port           = 10250
  protocol          = "tcp"
  security_group_id = aws_security_group.eks_nodes.id
  source_security_group_id = aws_security_group.eks_cluster.id
}
resource "aws_security_group" "eks_cluster" {
  name        = "amit-counter-eks_cluster_sg"   
  vpc_id      = aws_vpc.counter_vpc.id

  tags = {
    Name = "amit-counter-eks-nodes-sg" 
  }
}

resource "aws_security_group_rule" "eks_control_plane_ingress_443" {
  type              = "ingress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  security_group_id = aws_security_group.eks_cluster.id
  source_security_group_id = aws_security_group.eks_nodes.id
}

resource "aws_security_group_rule" "eks_control_plane_ingress_10250" {
  type              = "ingress"
  from_port         = 10250
  to_port           = 10250
  protocol          = "tcp"
  security_group_id = aws_security_group.eks_cluster.id
  source_security_group_id = aws_security_group.eks_nodes.id
}