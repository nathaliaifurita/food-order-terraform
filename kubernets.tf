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

          env {
            name = "ConnectionStrings__DefaultConnection"
            value_from {
              config_map_key_ref {
                name = "db-config"
                key  = "DB_CONNECTION_STRING"
              }
            }
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

resource "kubernetes_config_map" "db_config" {
  metadata {
    name = "db-config"
  }

  data = {
    DB_CONNECTION_STRING = "Host=${data.aws_db_instance.rds.endpoint};Port=5432;Database=${var.db_name};Username=${var.db_username};Password=${var.db_password}"
  }

  depends_on = [
    aws_eks_cluster.eks-cluster
  ]
}
