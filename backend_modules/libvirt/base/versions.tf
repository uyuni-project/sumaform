terraform {
  required_version = "1.0.10"
  required_providers {
    libvirt = {
      source = "uyuni-project/libvirt"
      version = "0.6.11-1"
    }
  }
}
