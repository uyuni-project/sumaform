terraform {
  required_version = "1.0.10"
  required_providers {
    null = {
      source  = "hashicorp/null"
      version = ">= 2.1.0"
    }
    libvirt = {
      source = "uyuni-project/libvirt"
      version = "0.6.11-1"
    }
  }
}