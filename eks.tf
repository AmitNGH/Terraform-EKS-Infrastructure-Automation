# Define IAM role policy for EKS role
data "aws_iam_policy_document" "eks_role_policy" {
    statement {
        effect = "Allow"
        actions = ["sts:AssumeRole"]
        principals {
            identifiers = ["eks.amazonaws.com"]
            type = "Service"
        }
    }
}

# Create IAM role for EKS cluster
resource "aws_iam_role" "eks_cluster_role" {
    name = "amit-counter-eks-cluster-role"
    assume_role_policy = "${data.aws_iam_policy_document.eks_role_policy.json}"
}

# Attach IAM policy to EKS role
resource "aws_iam_role_policy_attachment" "eks_cluster_policy" {
    role = aws_iam_role.eks_cluster_role.name
    policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
}

resource "aws_iam_role_policy_attachment" "eks_service_policy" {
  role       = aws_iam_role.eks_cluster_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSServicePolicy"
}

# Create EKS Cluster
resource "aws_eks_cluster" "eks_cluster" {
  name     = var.eks_cluster_name                                        # variable?
  role_arn = aws_iam_role.eks_cluster_role.arn

  vpc_config {
    subnet_ids = concat([for sn in aws_subnet.private_subnet : sn.id], [for sn in aws_subnet.public_subnet : sn.id])
    # security_group_ids      = [aws_security_group.eks_cluster.id, aws_security_group.eks_nodes.id]
    endpoint_private_access = true
    endpoint_public_access  = true
  }

  # Kubernetes version
  version = "1.30"

  tags = {
    Name = var.eks_cluster_name
  }

  depends_on = [aws_iam_role_policy_attachment.eks_cluster_policy, aws_vpc.counter_vpc]
}

# resource "aws_security_group" "eks_cluster_sg" {
#   name        = "amit-counter-eks-cluster-sg"   
#   description = "Cluster communication with worker nodes"
#   vpc_id      = aws_vpc.counter_vpc.id

#   tags = {
#     Name = "amit-counter-eks-cluster-sg" 
#   }
# }

# resource "aws_security_group_rule" "cluster_inbound" {
#   description              = "Allow worker nodes to communicate with the cluster API Server"
#   from_port                = 443
#   protocol                 = "tcp"
#   security_group_id        = aws_security_group.eks_cluster.id
#   source_security_group_id = aws_security_group.eks_nodes.id
#   to_port                  = 443
#   type                     = "ingress"
# }

# resource "aws_security_group_rule" "cluster_outbound" {
#   description              = "Allow cluster API Server to communicate with the worker nodes"
#   from_port                = 1024
#   protocol                 = "tcp"
#   security_group_id        = aws_security_group.eks_cluster.id
#   source_security_group_id = aws_security_group.eks_nodes.id
#   to_port                  = 65535
#   type                     = "egress"
# }