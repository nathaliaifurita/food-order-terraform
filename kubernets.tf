resource "time_sleep" "wait_for_kubernetes" {
  depends_on = [
    aws_eks_cluster.eks-cluster,
    aws_eks_node_group.eks-node
  ]

  create_duration = "30s"
}

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
    time_sleep.wait_for_kubernetes,
    kubernetes_config_map.db_config
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
    kubernetes_deployment.api,
    time_sleep.wait_for_kubernetes
  ]
}

resource "kubernetes_config_map" "db_config" {
  depends_on = [
    time_sleep.wait_for_kubernetes,
    data.aws_eks_cluster.cluster,
    data.aws_eks_cluster_auth.cluster
  ]

  metadata {
    name = "db-config"
  }

  data = {
    DB_CONNECTION_STRING = "Host=${var.POSTGRES_HOST};Port=5432;Database=${var.POSTGRES_DB};Username=${var.POSTGRES_USER};Password=${var.POSTGRES_PASSWORD}"
  }
}
