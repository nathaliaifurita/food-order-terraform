resource "kubernetes_deployment" "api" {
  metadata {
    name = "api-deployment"
    labels = {
      app = "api-pod"
    }
  }

  spec {
    replicas = 2

    selector {
      match_labels = {
        app = "api-pod"
      }
    }

    template {
      metadata {
        labels = {
          app = "api-pod"
        }
      }

      spec {
        container {
          name  = "api-pod-config"
          image = "vilacaro/api:v1"

          port {
            container_port = 9000
          }

          env {
            name  = "ASPNETCORE_URLS"
            value = "http://0.0.0.0:9000"
          }
        }
      }
    }
  }

  depends_on = [
    aws_eks_cluster.eks-cluster,
    aws_eks_node_group.eks-node
  ]
}

resource "kubernetes_service" "api" {
  metadata {
    name = "api-svc"
    labels = {
      app = "api-svc"
    }
  }

  spec {
    selector = {
      app = "api-pod"
    }

    port {
      port        = 80
      target_port = 9000
      node_port   = 30080
    }

    type = "LoadBalancer"
  }

  depends_on = [
    kubernetes_deployment.api
  ]
}
