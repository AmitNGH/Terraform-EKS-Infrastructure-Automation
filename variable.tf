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
    default = "counter-eks-cluster"
    description = "EKS Cluster name"
}

variable "eks_cluster_role_name" {
    type = string
    default = "counter-eks-cluster-role"
    description = "EKS Cluster role name"
}

variable "kubernetes_version" {
    type = string
    default = "1.30"
    description = "Kubernetes version"
}

## Worker
variable "eks_node_name" {
    type = string
    default = "counter-eks-node-group"
    description = "EKS worker name"
}

variable "eks_node_role_name" {
    type = string
    default = "counter-eks-node-role"
    description = "EKS worker role name"
}

# Scaling
variable "scaling_desired_size" {
    type = number
    default = 2
    description = "Scaling Desired size"
}

variable "scaling_min_size" {
    type = number
    default = 1
    description = "Scaling minimun size"
}

variable "scaling_max_size" {
    type = number
    default = 5
    description = "Scaling maximum size"
}

# Instance type
variable "ec2_instance_type" {
    type = string
    default = "t3.small"
    description = "Nodes instance type"
}

## RDS
variable "db_identifier" {
    type = string
    default = "counter-service-db"
    description = "Database allocated storage"
}

variable "db_allocated_storage" {
    type = number
    default = 20
    description = "Database allocated storage"
}

variable "db_engine" {
    type = string
    default = "mysql"
    description = "Database engine"
}

variable "db_version" {
    type = string
    default = "8.0"
    description = "Database engine version"
}

variable "db_instance_type" {
    type = string
    default = "db.t3.micro"
    description = "RDS instance type"
}

variable "db_name" {
    type = string
    default = "counterdb"
    description = "Database name"
}

variable "db_username" {
    type = string
    default = "amit"
    description = "Database username"
}

variable "db_password" {
    type = string
    description = "Database password"
}

variable "db_security_group_name" {
      type = string
      default = "counter-mysql-sg"
      description = "DB security group name"
}

variable "db_subnet_group_name" {
      type = string
      default = "counter-db-subnet-group"
      description = "DB subnet group name"
}