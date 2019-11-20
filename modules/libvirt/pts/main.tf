module "server" {
  source             = "../suse_manager"
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
  cloned_channels    = "[{channels: [sles12-sp3-pool-x86_64, sles12-sp3-updates-x86_64, sle-manager-tools12-pool-x86_64-sp3, sle-manager-tools12-updates-x86_64-sp3], prefix: cloned-2017-q3, date: 2017-09-30}, {channels: [sles12-sp3-pool-x86_64, sles12-sp3-updates-x86_64, sle-manager-tools12-pool-x86_64-sp3, sle-manager-tools12-updates-x86_64-sp3], prefix: cloned-2017-q4, date: 2017-12-31}]"

  // Provider-specific variables
  vcpu   = 8
  memory = 16384
  mac    = var.server_mac
}

module "minion" {
  source             = "../minion"
  base_configuration = var.base_configuration

  name                 = var.minion_name
  image                = "sles12sp3"
  server_configuration = module.server.configuration
  activation_key       = "1-cloned-2017-q3"
  evil_minion_count    = var.pts_system_count

  // Provider-specific variables
  vcpu   = 2
  memory = 4096
  mac    = var.minion_mac
}

module "locust" {
  source               = "../locust"
  name                 = var.locust_name
  base_configuration   = var.base_configuration
  server_configuration = module.server.configuration
  locust_file          = "modules/libvirt/pts/locustfile.py"
  slave_quantity       = 5

  // Provider-specific variables
  memory = 1024
  mac    = var.locust_mac
}

module "grafana" {
  source               = "../grafana"
  name                 = var.grafana_name
  base_configuration   = var.base_configuration
  server_configuration = module.server.configuration
  locust_configuration = module.locust.configuration
  quantity             = var.grafana

  // Provider-specific variables
  mac = var.grafana_mac
}

