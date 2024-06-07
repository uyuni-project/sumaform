terraform {
  required_version = "1.0.10"
  required_providers {
    null = {
      source  = "hashicorp/null"
      version = ">= 2.1.0"
    }
    aws  = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
  }
}
