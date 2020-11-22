terraform {
  required_providers {
    kubernetes = {
      source = "hashicorp/kubernetes"
    }
  }
  required_version = ">= 0.12.26"
  backend "s3"{
    bucket                 = "weather-terraform-s3-state"
    region                 = "ap-southeast-2"
    key                    = "backend.tfstate"
    dynamodb_table         = "weather-terraform-locks"
  }
}
