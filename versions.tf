terraform {
  required_version = "~> 1.5.5"
  
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.25.0"
    }
    cloudinit = {
      source  = "hashicorp/cloudinit"
      version = "~> 2.3.2"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.11.0"
    }
    http = {
      source  = "hashicorp/http"
      version = "~> 3.4.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.23.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.5.1"
    }
    time = {
      source  = "hashicorp/time"
      version = "~> 0.9.1"
    }
    tls = {
      source  = "hashicorp/tls"
      version = "~> 4.0.4"
    }
  }
}
