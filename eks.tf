resource "aws_eks_cluster" "eks_cluster" {
  name     = "${var.project_name}-${terraform.workspace}-eks-cluster-${random_id.name.hex}"
  role_arn = aws_iam_role.eks_role.arn

  enabled_cluster_log_types = ["api", "audit", "authenticator", "controllerManager", "scheduler"]

  vpc_config {
    subnet_ids = [
      aws_subnet.vpc_public_subnet_1.id,
      aws_subnet.vpc_public_subnet_2.id,
      aws_subnet.vpc_private_subnet_1.id,
      aws_subnet.vpc_private_subnet_2.id
    ]
    endpoint_private_access = true
    endpoint_public_access  = false
    security_group_ids      = [aws_security_group.eks_bastion_host_sg.id]
  }

  # Ensure that IAM Role permissions are created before and deleted after EKS Cluster handling.
  # Otherwise, EKS will not be able to properly delete EKS managed EC2 infrastructure such as Security Groups.
  depends_on = [
    aws_iam_role_policy_attachment.eks_policy_AmazonEKSClusterPolicy,
    # aws_iam_role_policy_attachment.example-AmazonEKSVPCResourceController,
  ]
}

resource "aws_eks_addon" "eks_vpc_cni" {
  cluster_name = aws_eks_cluster.eks_cluster.name
  addon_name   = "vpc-cni"

  depends_on = [
    aws_eks_node_group.node_group
  ]

}

resource "aws_eks_addon" "eks_vpc_core_dns" {
  cluster_name = aws_eks_cluster.eks_cluster.name
  addon_name   = "coredns"

  depends_on = [
    aws_eks_node_group.node_group
  ]

}

resource "aws_eks_addon" "eks_vpc_kube_proxy" {
  cluster_name = aws_eks_cluster.eks_cluster.name
  addon_name   = "kube-proxy"

  depends_on = [
    aws_eks_node_group.node_group
  ]

}

# resource "aws_eks_fargate_profile" "fargate_profile" {
#   cluster_name           = aws_eks_cluster.eks_cluster.name
#   fargate_profile_name   = "${var.project_name}-${terraform.workspace}-fargate-profile-${random_id.name.hex}"
#   pod_execution_role_arn = aws_iam_role.fargate_role.arn
#   subnet_ids             = [aws_subnet.vpc_private_subnet_1.id, aws_subnet.vpc_private_subnet_2.id]

#   selector {
#     namespace = "default"
#   }
# }

# --- Node Groups ---

resource "aws_eks_node_group" "node_group" {
  cluster_name    = aws_eks_cluster.eks_cluster.name
  node_group_name = "${var.project_name}-${terraform.workspace}-node-group-${random_id.name.hex}"
  node_role_arn   = aws_iam_role.node_group_role.arn
  subnet_ids      = [aws_subnet.vpc_private_subnet_1.id, aws_subnet.vpc_private_subnet_2.id]

  scaling_config {
    desired_size = 2
    max_size     = 3
    min_size     = 1
  }

  update_config {
    max_unavailable = 1
  }

  # Ensure that IAM Role permissions are created before and deleted after EKS Node Group handling.
  # Otherwise, EKS will not be able to properly delete EC2 Instances and Elastic Network Interfaces.
  depends_on = [
    aws_iam_role_policy_attachment.node-group-policy-AmazonEKSWorkerNodePolicy,
    aws_iam_role_policy_attachment.node-group-policy-AmazonEKS_CNI_Policy,
    aws_iam_role_policy_attachment.node-group-policy-AmazonEC2ContainerRegistryReadOnly,
    # aws_eks_addon.eks_vpc_core_dns
  ]

  lifecycle {
    ignore_changes = [scaling_config[0].desired_size]
  }

}
