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

# Create the private subnets
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

# Create the public subnets
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

  map_public_ip_on_launch = true
}

# Create Internet Gateway
resource "aws_internet_gateway" "counter_gateway" {
  vpc_id = "${aws_vpc.counter_vpc.id}"

  tags = {
    Name = var.internet_gateway_name
  }
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

# Route table
resource "aws_route_table" "counter_route_table" {
  vpc_id = aws_vpc.counter_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.counter_gateway.id
  }

  tags = {
    Name = var.routing_table_name
  }

  
  # depends_on = [aws_internet_gateway.counter_gateway]
}

# Associate route table to subnet
resource "aws_route_table_association" "counter_route_table_associate" {
  count = 2
  subnet_id      = aws_subnet.public_subnet[count.index].id
  route_table_id = aws_route_table.counter_route_table.id
}

# Add NAT to route table
resource "aws_route" "nat_route_table" {
  route_table_id = aws_vpc.counter_vpc.default_route_table_id
  destination_cidr_block  = "0.0.0.0/0"
  nat_gateway_id = aws_nat_gateway.counter_nat.id
}

# # Security group for public subnet resources
# resource "aws_security_group" "public_sg" {
#   name   = "counter-public-sg"
#   vpc_id = aws_vpc.counter_vpc.id

#   tags = {
#     Name = "counter-public-sg"
#   }
# }

# # Security group traffic rules
# ## Ingress rule
# resource "aws_security_group_rule" "sg_ingress_public_443" {
#   security_group_id = aws_security_group.public_sg.id
#   type              = "ingress"
#   from_port         = 443
#   to_port           = 443
#   protocol          = "tcp"
#   cidr_blocks = ["0.0.0.0/0"]
# }

# resource "aws_security_group_rule" "sg_ingress_public_80" {
#   security_group_id = aws_security_group.public_sg.id
#   type              = "ingress"
#   from_port         = 80
#   to_port           = 80
#   protocol          = "tcp"
#   cidr_blocks = ["0.0.0.0/0"]
# }

# ## Egress rule
# resource "aws_security_group_rule" "sg_egress_public" {
#   security_group_id = aws_security_group.public_sg.id
#   type              = "egress"
#   from_port   = 0
#   to_port     = 0
#   protocol    = "-1"
#   cidr_blocks = ["0.0.0.0/0"]
# }

# # Security group for data plane
# resource "aws_security_group" "data_plane_sg" {
#   name   = "k8s-data-plane-sg"
#   vpc_id = aws_vpc.counter_vpc.id

#   tags = {
#     Name = "k8s-data-plane-sg"
#   }
# }

# # Security group traffic rules
# ## Ingress rule
# resource "aws_security_group_rule" "nodes" {
#   description              = "Allow nodes to communicate with each other"
#   security_group_id = aws_security_group.data_plane_sg.id
#   type              = "ingress"
#   from_port   = 0
#   to_port     = 65535
#   protocol    = "-1"
#   cidr_blocks = flatten([["10.0.0.0/26", "10.0.0.64/26"], ["10.0.0.128/26", "10.0.0.192/26"]])
# }

# resource "aws_security_group_rule" "nodes_inbound" {
#   description              = "Allow worker Kubelets and pods to receive communication from the cluster control plane"
#   security_group_id = aws_security_group.data_plane_sg.id
#   type              = "ingress"
#   from_port   = 1025
#   to_port     = 65535
#   protocol    = "tcp"
#   cidr_blocks = flatten([["10.0.0.0/26", "10.0.0.64/26"]])
# }

# ## Egress rule
# resource "aws_security_group_rule" "node_outbound" {
#   security_group_id = aws_security_group.data_plane_sg.id
#   type              = "egress"
#   from_port   = 0
#   to_port     = 0
#   protocol    = "-1"
#   cidr_blocks = ["0.0.0.0/0"]
# }

# # Security group for control plane
# resource "aws_security_group" "control_plane_sg" {
#   name   = "k8s-control-plane-sg"
#   vpc_id = aws_vpc.counter_vpc.id

#   tags = {
#     Name = "k8s-control-plane-sg"
#   }
# }

# # Security group traffic rules
# ## Ingress rule
# resource "aws_security_group_rule" "control_plane_inbound" {
#   security_group_id = aws_security_group.control_plane_sg.id
#   type              = "ingress"
#   from_port   = 0
#   to_port     = 65535
#   protocol          = "tcp"
#   cidr_blocks = flatten([["10.0.0.0/26", "10.0.0.64/26"], ["10.0.0.128/26", "10.0.0.192/26"]])
# }

# ## Egress rule
# resource "aws_security_group_rule" "control_plane_outbound" {
#   security_group_id = aws_security_group.control_plane_sg.id
#   type              = "egress"
#   from_port   = 0
#   to_port     = 65535
#   protocol    = "-1"
#   cidr_blocks = ["0.0.0.0/0"]
# }
