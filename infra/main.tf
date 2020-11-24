resource kubernetes_deployment "weather_deployment" {
  metadata {
    name = "best-weather-api"
    labels = {
      App = "best-weather-api"
    }
  }

  spec {
    replicas = 2
    selector {
      match_labels = {
        App = "best-weather-api"
      }
    }
    template {
      metadata {
        labels = {
          App = "best-weather-api"
        }
      }
      spec {
        container {
          image = "dfranciswoolies/ciarecruitment-bestapiever:247904"
          name = "example"

          port {
            container_port = 80
          }
          env {
            name = "APIKEY"
            value_from {
              secret_key_ref {
                name = "apikey-secret"
                key = "apikey"
              }
            }
          }
          resources {
            limits {
              cpu = "0.5"
              memory = "512Mi"
            }
            requests {
              cpu = "250m"
              memory = "50Mi"
            }
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "weather_service" {
  metadata {
    name = "weather-service"
    annotations = {
      "service.beta.kubernetes.io/aws-load-balancer-type": "nlb"
    }
  }

  spec {
    selector = {
      App = kubernetes_deployment.weather_deployment.spec.0.template.0.metadata[0].labels.App
    }
    port {
      port = 80
      target_port = 80
    }

    type = "ClusterIP"
  }
}

resource "kubernetes_secret" "apikey" {
  metadata {
    name = "apikey-secret"
  }

  data = {
    apikey = var.apikey
  }

}


