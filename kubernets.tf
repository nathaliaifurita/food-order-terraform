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

          # Variáveis de ambiente do banco de dados
          env {
            name  = "POSTGRES_DB"
            value = var.POSTGRES_DB
          }

          env {
            name  = "POSTGRES_USER"
            value = var.POSTGRES_USER
          }

          env {
            name  = "POSTGRES_PASSWORD"
            value = var.POSTGRES_PASSWORD
          }

          data "aws_db_instance" "rds_postgres" {
            db_instance_identifier = var.RDS_INSTANCE
          }

          # String de conexão como variável de ambiente
          env {
            name  = "ConnectionStrings__DefaultConnection"
            value = "Host=${data.aws_db_instance.rds_postgres.endpoint};Port=5432;Database=${var.POSTGRES_DB};Username=${var.POSTGRES_USER};Password=${var.POSTGRES_PASSWORD}"
          }
        }
      }
    }
  }
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

  data "aws_db_instance" "rds_postgres" {
    db_instance_identifier = var.RDS_INSTANCE
  }

  data = {
    DB_CONNECTION_STRING = "Host=${data.aws_db_instance.rds_postgres.endpoint};Port=5432;Database=${var.POSTGRES_DB};Username=${var.POSTGRES_USER};Password=${var.POSTGRES_PASSWORD}"
  }
}
