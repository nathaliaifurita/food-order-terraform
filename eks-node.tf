resource "aws_eks_node_group" "eks-node" {
  count = length(var.projectNames)

  cluster_name    = aws_eks_cluster.eks_cluster[count.index].name
  node_group_name = "eks-node-${var.projectNames[count.index]}"
  node_role_arn   = var.labRole
  subnet_ids      = [for subnet in aws_subnet.private_subnets : subnet.id]
  instance_types  = [var.instanceType]

  scaling_config {
    desired_size = 2
    min_size     = 1
    max_size     = 2
  }

  update_config {
    max_unavailable = 1
  }

  tags = merge(
    {
      Environment = var.environment
    },
    {
      for name in var.projectNames : "kubernetes.io/cluster/${name}" => "owned"
    }
  ) 

  launch_template {
    name    = aws_launch_template.eks_launch_template[count.index].name
    version = aws_launch_template.eks_launch_template[count.index].latest_version
  }

  depends_on = [
    aws_eks_cluster.eks_cluster["eks-cardapio"],
    aws_eks_cluster.eks_cluster["eks-pedido"],
    aws_eks_cluster.eks_cluster["eks-usuario"],
    aws_eks_cluster.eks_cluster["eks-pagamento"],
    aws_eks_cluster.eks_cluster["eks-auth"],
    aws_vpc.main,
    aws_subnet.private_subnets,
    aws_security_group.sg
  ]
}

resource "aws_launch_template" "eks_launch_template" {
  count = length(var.projectNames)

  name = "eks-launch-${var.projectNames[count.index]}" # ← Nome único por projeto

  block_device_mappings {
    device_name = "/dev/xvda"
    ebs {
      volume_size           = 50
      volume_type           = "gp2"
      delete_on_termination = true
    }
  }

  network_interfaces {
    associate_public_ip_address = false
    security_groups              = [aws_security_group.sg.id]
  }

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name                                = "eks-node-${var.projectNames[count.index]}"
      "kubernetes.io/cluster/${var.projectNames[count.index]}" = "owned"
    }
  }

  user_data = base64encode(<<-EOF
MIME-Version: 1.0
Content-Type: multipart/mixed; boundary="==BOUNDARY=="

--==BOUNDARY==
Content-Type: text/x-shellscript; charset="us-ascii"

#!/bin/bash
/etc/eks/bootstrap.sh ${aws_eks_cluster.eks_cluster[count.index].name} \
  --b64-cluster-ca ${aws_eks_cluster.eks_cluster[count.index].certificate_authority[0].data} \
  --apiserver-endpoint ${aws_eks_cluster.eks_cluster[count.index].endpoint}

--==BOUNDARY==--
EOF
  )
}
