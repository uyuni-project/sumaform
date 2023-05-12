terraform {
  required_version = "1.5.4"
  required_providers {
    null = {
      source  = "hashicorp/null"
      version = ">= 2.1.0"
    }
    libvirt = {
      source = "dmacvicar/libvirt"
      version = "0.7.1"
    }
  }
}
