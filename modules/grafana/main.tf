module "grafana" {
  source = "../host"

  base_configuration = var.base_configuration
  name               = var.name
  quantity           = var.quantity
  ssh_key_path       = var.ssh_key_path
  roles              = ["grafana"]
  grains = {
    mirror          = var.base_configuration["mirror"]
    server          = var.server_configuration["hostname"]
    locust          = var.locust_configuration["hostname"]
    product_version = "3.2-nightly"
  }

  image   = "sles12sp2"
  provider_settings = var.provider_settings
}

output "configuration" {
  value = module.grafana.configuration
}

