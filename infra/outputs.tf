output "weather_alb_dns_name" {
  value = data.aws_alb.ingress-alb.dns_name
}
