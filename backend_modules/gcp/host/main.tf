provider "google" {
  project = var.project_name
  region  = var.region_name
  zone    = var.zone_name
}

locals {
  name_prefix = var.name_prefix
}

resource "google_compute_address" "proxy" {
  name = "proxy-ipv4-address"
}

resource "google_compute_address" "server" {
  name = "server-ipv4-address"
}

resource "google_compute_image" "suma-server-42" {
  name = "suma-server-42"

  raw_disk {
    source = "https://storage.googleapis.com/suse-manager-images/SUSE-Manager-Server-BYOS.x86_64-0.9.0-GCE-Build2.16.tar.gz"
  }
}

resource "google_compute_image" "suma-proxy-42" {
  name = "suma-proxy-42"

  raw_disk {
    source = "https://storage.googleapis.com/suse-manager-images/SUSE-Manager-Proxy-BYOS.x86_64-0.9.0-GCE-Build2.20.tar.gz"
  }
}

#resource "time_sleep" "wait_20_seconds" {
#  depends_on = [google_compute_image.suma-proxy-42]
#  create_duration = "20s"
#}

resource "google_compute_instance" "suma-proxy-42-instance" {
  name         = "suma-proxy-42-instance"
  machine_type = var.machine_size
 depends_on = [ google_compute_image.suma-proxy-42 ]

  boot_disk {
    initialize_params {
      image = "suma-proxy-42"
    }
  }

  network_interface {
    # A default network is created for all GCP projects
    network = google_compute_network.vpc_network.self_link
    access_config {
       nat_ip = google_compute_address.proxy.address
    }
  }
}

resource "google_compute_instance" "suma-server-42-instance" {
  name         = "suma-server-42-instance"
  machine_type = var.machine_size
 depends_on = [ google_compute_image.suma-server-42 ]

  boot_disk {
    initialize_params {
      image = "suma-server-42"
    }
  }

  network_interface {
    # A default network is created for all GCP projects
    network = google_compute_network.vpc_network.self_link
    access_config {
       nat_ip = google_compute_address.server.address
    }
  }
}

resource "google_compute_network" "vpc_network" {
  name                    = "terraform-network"
  auto_create_subnetworks = "true"
}
