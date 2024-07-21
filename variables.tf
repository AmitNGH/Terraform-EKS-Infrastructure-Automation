## Region
variable "region" {
    type = string
    default = "eu-north-1"
    description = "Region to create environment"
}

## VPC
variable "vpc_name" {
    type = string
    default = "amit-counter-vpc"
    description = "Name of the VPC"
}

variable "vpc_cidr_block" {
    type = string
    default = "10.0.0.0/24"
    description = "CIDR block for the VPC"
}

# Private subnets
variable "private_subnet_cidr" {
    type = list(string)
    default = ["10.0.0.0/26", "10.0.0.64/26"]
    description = "CIDR block range for the private subnet"
}

variable "private_subnet_name" {
    type = string
    default = "amit-counter-private-subnet"
    description = "Private subnet name"
}

# Public subnets
variable "public_subnet_cidr" {
    type = list(string)
    default = ["10.0.0.128/26", "10.0.0.192/26"]
    description = "CIDR block range for the public subnet"
}

variable "public_subnet_name" {
    type = string
    default = "amit-counter-public-subnet"
    description = "Public subnet name"
}

variable "subnet_azs" {
    type = list(string)
    default = ["eu-north-1a", "eu-north-1b"]
    description = "Availibity zones to create the subnets"
}

# Internet Gateway
variable "internet_gateway_name" {
    type = string
    default = "amit-counter-internet-gateway"
    description = "Internet Gateway name"
}

# Elastic IP
variable "elastic_ip_name" {
    type = string
    default = "amit-counter-elastic-ip"
    description = "Elastic IP name"
}

# NAT Gateway
variable "nat_gateway_name" {
    type = string
    default = "amit-counter-nat-gateway"
    description = "NAT Gateway name"
}

# Route Table
variable "routing_table_name" {
  type = string
    default = "amit-counter-route-table"
    description = "Route Table name"
}

# Nodes Security
variable "eks_nodes_sg_name" {
  type = string
    default = "counter-eks-nodes-sg"
    description = "EKS nodes security group name"
}

# Cluster Security
variable "eks_cluster_sg_name" {
  type = string
    default = "counter-eks-cluster-sg"
    description = "EKS cluster security group name"
}




## EKS
variable "eks_cluster_name" {
  type = string
    default = "amit-counter-eks-cluster"
    description = "EKS Cluster name"
}