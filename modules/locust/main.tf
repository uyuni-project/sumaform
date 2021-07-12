module "locust" {
  source             = "../host"
  base_configuration = var.base_configuration
  name               = var.name
  ssh_key_path       = var.ssh_key_path
  roles              = ["locust"]
  grains = {
    mirror             = var.base_configuration["mirror"]
    server             = var.server_configuration["hostname"]
    locust_file        = base64encode(file(var.locust_file))
    server_username    = var.server_configuration["username"]
    server_password    = var.server_configuration["password"]
    locust_master_host = null
    locust_slave_count = var.slave_quantity
  }

  image   = "opensuse152"
  provider_settings = var.provider_settings
}

module "locust-slave" {
  source             = "../host"
  base_configuration = var.base_configuration
  name               = "${var.name}-slave"
  quantity           = var.slave_quantity
  ssh_key_path       = var.ssh_key_path
  roles              = ["locust"]
  grains = {
    mirror             = var.base_configuration["mirror"]
    server             = var.server_configuration["hostname"]
    locust_file        = base64encode(file(var.locust_file))
    server_username    = var.server_configuration["username"]
    server_password    = var.server_configuration["password"]
    locust_master_host = length(module.locust.configuration["hostnames"]) > 0 ? module.locust.configuration["hostnames"][0] : null
  }

  image   = "opensuse152"
  provider_settings = var.provider_settings
}

output "configuration" {
  value = {
    id       = length(module.locust.configuration["ids"]) > 0 ? module.locust.configuration["ids"][0] : null
    hostname = length(module.locust.configuration["hostnames"]) > 0 ? module.locust.configuration["hostnames"][0] : null
  }
}
