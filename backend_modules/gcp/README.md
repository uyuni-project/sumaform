# GCE - specific configuration

In terraform main.tf file:

provider "google" {
  project = "your-project"
  region  = "your-region"
  zone    = "your-zone"
}

This module is still WIP.
TO DO:
- add clients
- find a way to mirror/connect suma server to suse's internal (download.suse.de) resources (VPN?)