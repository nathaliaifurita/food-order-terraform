//resource "kubernetes_deployment" "api" {
//  metadata {
//    name = "api-deployment"
//    labels = {
//      app = "api-pod"
//    }
//  }
//
//  spec {
//    replicas = 2
//
//    selector {
//      match_labels = {
//        app = "api-pod"
//      }
//    }
//
//    template {
//      metadata {
//        labels = {
//          app = "api-pod"
//        }
//      }
//
//      spec {
//        container {
//          name  = "api-pod-config"
//          image = "vilacaro/api:v4.3"
//
//          port {
//            container_port = 9000
//          }
//
//          env {
//            name  = "ASPNETCORE_URLS"
//            value = "http://0.0.0.0:9000"
//          }
//
//          env {
//            name = "ConnectionStrings__DefaultConnection"
//            value_from {
//              config_map_key_ref {
//                name = "db-config"
//                key  = "DB_CONNECTION_STRING"
//              }
//            }
//          }          
//        }
//      }
//    }
//  }
//}
//
//resource "kubernetes_service" "api" {
//  metadata {
//    name = "api-svc"
//    labels = {
//      app = "api-svc"
//    }
//  }
//
//  spec {
//    selector = {
//      app = "api-pod"
//    }
//
//    port {
//      port        = 80
//      target_port = 9000
//      node_port   = 30080
//    }
//
//    type = "LoadBalancer"
//  }
//
//  depends_on = [
//    kubernetes_deployment.api
//  ]
//}
//
//# ConfigMap para as configurações do banco de dados
//resource "kubernetes_config_map" "db_config" {
//  metadata {
//    name = "db-config"
//  }
//
//  data = {
//    DB_CONNECTION_STRING = "Host=food-order-db.cpqtqlmpyljc.us-east-1.rds.amazonaws.com;Port=5432;Database=foodorderdb;Username=postgres;Password=postgres"
//  }
//}