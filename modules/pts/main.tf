module "server" {
  source             = "../server"
  name               = var.suse_manager_name
  base_configuration = var.base_configuration
  product_version    = "3.2-nightly"
  image              = "sles12sp3"
  auto_accept        = false
  monitored          = true
  pts                = true
  pts_minion         = "${var.base_configuration["name_prefix"]}${var.minion_name}"
  pts_locust         = "${var.base_configuration["name_prefix"]}${var.locust_name}"
  pts_system_count   = "${var.pts_system_count} + 1"
  pts_system_prefix  = "${var.base_configuration["name_prefix"]}${var.minion_name}"
  channels           = ["sles12-sp3-pool-x86_64", "sles12-sp3-updates-x86_64", "sle-manager-tools12-pool-x86_64-sp3", "sle-manager-tools12-updates-x86_64-sp3"]
  wait_for_reposync  = true
  cloned_channels = [
    { channels = ["sles12-sp3-pool-x86_64", "sles12-sp3-updates-x86_64", "sle-manager-tools12-pool-x86_64-sp3", "sle-manager-tools12-updates-x86_64-sp3"],
      prefix   = "cloned-2017-q3",
      date     = "2017-09-30"
    },
    { channels = ["sles12-sp3-pool-x86_64", "sles12-sp3-updates-x86_64", "sle-manager-tools12-pool-x86_64-sp3", "sle-manager-tools12-updates-x86_64-sp3"],
      prefix   = "cloned-2017-q4",
      date     = "2017-12-31"
    }
  ]
  provider_settings = var.server_provider_settings
}

module "minion" {
  source             = "../minion"
  base_configuration = var.base_configuration

  name                 = var.minion_name
  image                = "sles12sp3"
  server_configuration = module.server.configuration
  activation_key       = "1-cloned-2017-q3"
  evil_minion_count    = var.pts_system_count
  provider_settings    = var.minion_provider_settings
  roles                = ["minion", "pts_minion"]
}

module "locust" {
  source               = "../locust"
  name                 = var.locust_name
  base_configuration   = var.base_configuration
  server_configuration = module.server.configuration
  locust_file          = "${path.module}/locustfile.py"
  slave_quantity       = 5
  provider_settings    = var.locust_provider_settings
}

module "grafana" {
  source               = "../grafana"
  name                 = var.grafana_name
  base_configuration   = var.base_configuration
  server_configuration = module.server.configuration
  locust_configuration = module.locust.configuration
  quantity             = var.grafana
  provider_settings    = var.grafana_provider_settings
}
