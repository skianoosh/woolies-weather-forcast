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


provider "helm" {
  kubernetes {
    host = data.aws_eks_cluster.cluster.endpoint
    cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority.0.data)
    token = data.aws_eks_cluster_auth.cluster.token
    load_config_file = false
  }
}


resource "helm_release" "alb-ingress-controller" {
  name = "alb-ingress-controller"
  chart = "aws-load-balancer-controller"
  namespace = "kube-system"
  repository = "https://aws.github.io/eks-charts"
  set {
    name = "clusterName"
    value = "weather-api-cluster"
  }

}


resource "kubernetes_ingress" "weather_ingress" {
  metadata {
    name = "weather-ingress"
    annotations = {
      "kubernetes.io/ingress.class": "alb"
      "alb.ingress.kubernetes.io/scheme" : "internet-facing"
      "alb.ingress.kubernetes.io/listen-ports" = "[{\"HTTP\": 80}]"
      "alb.ingress.kubernetes.io/target-type" = "ip"
    }
  }
  depends_on = [kubernetes_service.weather_service]

  spec {
    backend {
      service_name = "weather-service"
      service_port = 80
    }

    rule {
      http {
        path {
          backend {
            service_name = "weather-service"
            service_port = 80
          }

          path = "/*"
        }

      }
    }
  }
}

data "aws_alb" "ingress-alb" {

  tags = {
    "elbv2.k8s.aws/cluster" = "weather-api-cluster"
  }
}
