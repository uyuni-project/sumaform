module "server" {
  source = "../suse_manager"
  name = "${var.suse_manager_name}"
  base_configuration = "${var.base_configuration}"
  version = "3.1-nightly"
  monitored = true
  use_unreleased_updates = true
  pts = true
  pts_evil_minions = "${var.base_configuration["name_prefix"]}${var.evil_minions_name}"
  pts_locust = "${var.base_configuration["name_prefix"]}${var.locust_name}"
  pts_system_count = 200
  pts_system_prefix = "${var.base_configuration["name_prefix"]}${var.evil_minions_name}"
  channels = ["sles12-sp3-pool-x86_64", "sles12-sp3-updates-x86_64", "sle-manager-tools12-pool-x86_64-sp3", "sle-manager-tools12-updates-x86_64-sp3"]
  cloned_channels = "[{channels: [sles12-sp3-pool-x86_64, sles12-sp3-updates-x86_64, sle-manager-tools12-pool-x86_64-sp3, sle-manager-tools12-updates-x86_64-sp3], prefix: cloned-2017-q3, date: 2017-09-30}, {channels: [sles12-sp3-pool-x86_64, sles12-sp3-updates-x86_64, sle-manager-tools12-pool-x86_64-sp3, sle-manager-tools12-updates-x86_64-sp3], prefix: cloned-2017-q4, date: 2017-12-31}]"

  // Provider-specific variables
  vcpu = 8
  memory = 16384
  mac = "${var.server_mac}"
}

module "evil-minions" {
  source = "../evil_minions"
  base_configuration = "${var.base_configuration}"

  name = "${var.evil_minions_name}"
  server_configuration = "${module.server.configuration}"
  dump_file = "modules/libvirt/pts/minion-dump.mp"

  // Provider-specific variables
  vcpu = 2
  memory = 4096
  mac = "${var.evil_minions_mac}"
}

module "locust" {
  source = "../locust"
  name = "${var.locust_name}"
  base_configuration = "${var.base_configuration}"
  server_configuration = "${module.server.configuration}"
  locust_file = "modules/libvirt/pts/locustfile.py"
  slave_count = 5

  // Provider-specific variables
  memory = 2048
  mac = "${var.locust_mac}"
}

module "grafana" {
  source = "../grafana"
  name = "${var.grafana_name}"
  base_configuration = "${var.base_configuration}"
  server_configuration = "${module.server.configuration}"
  locust_configuration = "${module.locust.configuration}"
  count = "${var.grafana}"

  // Provider-specific variables
  mac = "${var.grafana_mac}"
}
