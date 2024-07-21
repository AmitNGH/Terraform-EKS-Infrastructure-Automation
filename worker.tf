# EKS Workers
data "aws_iam_policy_document" "eks_node_role_policy" {
    statement {
        effect  = "Allow"
        actions = ["sts:AssumeRole"]
        principals {
            identifiers = ["ec2.amazonaws.com"]
            type = "Service"
        }
    }
}

# IAM role for worker nodes
resource "aws_iam_role" "eks_node_role" {
  name               = var.eks_node_role_name                                                      
  assume_role_policy = data.aws_iam_policy_document.eks_node_role_policy.json
}

# Attach amazon created EKSWorkerNodePolicy to eks node role
resource "aws_iam_role_policy_attachment" "eks_worker_node_policy" {
  role       = aws_iam_role.eks_node_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
}

# Attach amazon created AmazonEKS_CNI_Policy to eks node role
resource "aws_iam_role_policy_attachment" "eks_worker_cni_policy" {
  role       = aws_iam_role.eks_node_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
}

# Attach amazon created EC2ContainerRegistryReadOnly to eks node role
resource "aws_iam_role_policy_attachment" "eks_worker_node_ecr_policy" {
  role       = aws_iam_role.eks_node_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}

# Create EKS Node group
resource "aws_eks_node_group" "eks_node_group" {
  cluster_name    = aws_eks_cluster.eks_cluster.name
  node_group_name = var.eks_node_name
  node_role_arn   = aws_iam_role.eks_node_role.arn
  subnet_ids      = [for sn in aws_subnet.private_subnet : sn.id]

  scaling_config {
    desired_size = var.scaling_desired_size
    min_size     = var.scaling_min_size
    max_size     = var.scaling_max_size 
  }

  instance_types = [var.ec2_instance_type]

  depends_on = [aws_iam_role_policy_attachment.eks_node_role]
}
