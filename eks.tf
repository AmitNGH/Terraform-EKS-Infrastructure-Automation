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
  name     = var.eks_cluster_name
  role_arn = aws_iam_role.eks_cluster_role.arn

  vpc_config {
    subnet_ids = concat([for sn in aws_subnet.private_subnet : sn.id], [for sn in aws_subnet.public_subnet : sn.id])
    security_group_ids      = [aws_security_group.eks_cluster.id, aws_security_group.eks_nodes.id]
    endpoint_private_access = true
    endpoint_public_access  = true
  }

  # Kubernetes version
  version = "1.30"

  tags = {
    Name = var.eks_cluster_name
  }
}
