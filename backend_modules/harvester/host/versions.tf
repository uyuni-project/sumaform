terraform {
  required_version = "1.1.5"
  required_providers {
    null = {
      source  = "hashicorp/null"
      version = ">= 2.1.0"
    }
    harvester = {
      source = "harvester/harvester"
      version = "0.4.0"
    }
  }
}
