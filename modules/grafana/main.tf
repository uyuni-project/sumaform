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
    product_version = var.product_version
  }

  image   = var.image
  provider_settings = var.provider_settings
}

output "configuration" {
  value = module.grafana.configuration
}

