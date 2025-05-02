resource "aws_eks_node_group" "eks-node" {
  for_each = toset(var.projectNames)

  cluster_name    = aws_eks_cluster.eks_cluster[each.key].name
  node_group_name = "eks-node-${each.key}"
  node_role_arn   = var.labRole
  subnet_ids      = aws_subnet.private_subnets[*].id
  instance_types  = [var.instanceType]

  scaling_config {
    desired_size = 2
    min_size     = 1
    max_size     = 2
  }

  update_config {
    max_unavailable = 1
  }

  tags = {
    "kubernetes.io/cluster/${var.projectNames}" = "owned"
    Environment = var.environment
  }

  launch_template {
    name    = aws_launch_template.eks_launch_template[each.key].name
    version = aws_launch_template.eks_launch_template[each.key].latest_version
  }

  depends_on = flatten([
    for k in var.projectNames : [
      aws_eks_cluster.eks_cluster[k],
      aws_vpc.main_vpc,
      aws_subnet.private_subnets,
      aws_security_group.sg
    ]
  ])
}

resource "aws_launch_template" "eks_launch_template" {
  for_each = toset(var.projectNames)
  name = "eks-launch-template"

  block_device_mappings {
    device_name = "/dev/xvda"
    
    ebs {
      volume_size = 50
      volume_type = "gp2"
      delete_on_termination = true
    }
  }

  network_interfaces {
    associate_public_ip_address = false
    security_groups            = [aws_security_group.sg.id]
  }

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "eks-node-${each.key}"
      "kubernetes.io/cluster/${var.projectNames}" = "owned"
    }
  }

  user_data = base64encode(<<-EOF
MIME-Version: 1.0
Content-Type: multipart/mixed; boundary="==BOUNDARY=="

--==BOUNDARY==
Content-Type: text/x-shellscript; charset="us-ascii"

#!/bin/bash
/etc/eks/bootstrap.sh ${aws_eks_cluster.eks_cluster[each.key].name} \
  --b64-cluster-ca ${aws_eks_cluster.eks_cluster[each.key].certificate_authority[0].data} \
  --apiserver-endpoint ${aws_eks_cluster.eks_cluster[each.key].endpoint}

--==BOUNDARY==--
EOF
  )
}
