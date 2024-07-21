# EKS Workers

data "aws_iam_policy_document" "eks_worker_role_policy" {
    statement {
        effect = "Allow"
        actions = ["sts:AssumeRole"]
        principals {
            identifiers = ["ec2.amazonaws.com"]
            type = "Service"
        }
    }
}

# IAM role for worker nodes
resource "aws_iam_role" "eks_worker_role" {
  name = "amit-counter-eks-worker-role"                                     # variable?                                 
  assume_role_policy = "${data.aws_iam_policy_document.eks_worker_role_policy.json}"
}

# Attach IAM policy to EKS Worker role
resource "aws_iam_role_policy_attachment" "eks_worker_node_policy" {
  role       = aws_iam_role.eks_worker_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
}

resource "aws_iam_role_policy_attachment" "eks_worker_cni_policy" {
  role       = aws_iam_role.eks_worker_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
}

resource "aws_iam_role_policy_attachment" "eks_worker_node_ecr_policy" {
  role       = aws_iam_role.eks_worker_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}

resource "aws_eks_node_group" "eks_node_group" {
  cluster_name    = aws_eks_cluster.eks_cluster.name
  node_group_name = "amit-counter-eks-node-group"                               # variable?
  node_role_arn   = aws_iam_role.eks_worker_role.arn
  subnet_ids      = [for sn in aws_subnet.private_subnet : sn.id]

  scaling_config {
    desired_size = 1 # scaling 
    max_size     = 2                                                            # variable?
    min_size     = 1
  }

  capacity_type  = "ON_DEMAND"  ###### TODO: Check what it does
  instance_types = ["t3.small"] # EC2 worker node type                            # variable?

#   remote_access {
#     ec2_ssh_key = var.key_name
#   }

  depends_on = [
    aws_iam_role_policy_attachment.eks_worker_node_policy,
    aws_iam_role_policy_attachment.eks_worker_cni_policy,
    aws_iam_role_policy_attachment.eks_worker_node_ecr_policy,
  ]
}
