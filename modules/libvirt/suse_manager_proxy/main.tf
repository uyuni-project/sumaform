variable "images" {
  default = {
    "3.2-released"   = "sles12sp4"
    "3.2-nightly"    = "sles12sp4"
    "4.0-released"   = "sles15sp1"
    "4.0-nightly"    = "sles15sp1"
    "head"           = "sles15sp1"
    "uyuni-master"   = "opensuse151"
    "uyuni-released" = "opensuse151"
  }
}

resource "libvirt_volume" "server_data_disk" {
  name  = "${var.base_configuration["name_prefix"]}${var.name}-server-data-disk"
  size  = "${var.repository_disk_size}"
  pool  = "${var.data_pool}"
  count = "${var.repository_disk_size > 0 ? 1 : 0}"
}

module "suse_manager_proxy" {
  source = "../host"

  base_configuration            = var.base_configuration
  name                          = var.name
  quantity                      = var.quantity
  use_os_released_updates       = var.use_os_released_updates
  use_os_unreleased_updates     = var.use_os_unreleased_updates
  additional_repos              = var.additional_repos
  additional_packages           = var.additional_packages
  swap_file_size                = var.swap_file_size
  ssh_key_path                  = var.ssh_key_path
  gpg_keys                      = var.gpg_keys
  ipv6                          = var.ipv6
  connect_to_base_network       = true
  connect_to_additional_network = true
  roles                         = ["suse_manager_proxy"]
  grains                        = <<EOF

product_version: ${var.product_version}
mirror: ${var.base_configuration["mirror"]}
server: ${var.server_configuration["hostname"]}
minion: ${var.minion}
auto_connect_to_master: ${var.auto_connect_to_master}
auto_register: ${var.auto_register}
download_private_ssl_key: ${var.download_private_ssl_key}
auto_configure: ${var.auto_configure}
server_username: ${var.server_configuration["username"]}
server_password: ${var.server_configuration["password"]}
generate_bootstrap_script: ${var.generate_bootstrap_script}
publish_private_ssl_key: ${var.publish_private_ssl_key}
apparmor: ${var.apparmor}
repository_disk_size: ${var.repository_disk_size}

EOF


  // Provider-specific variables
  image           = var.image == "default" ? var.images[var.product_version] : var.image
  memory          = var.memory
  vcpu            = var.vcpu
  running         = var.running
  mac             = var.mac
  additional_disk = var.repository_disk_size > 0 ? [{ volume_id = libvirt_volume.server_data_disk[0].id }] : []
}

output "configuration" {
  value = {
    ids              = module.suse_manager_proxy.configuration["ids"]
    hostname        = module.suse_manager_proxy.configuration["hostname"]
    product_version = var.product_version
    username        = var.server_configuration["username"]
    password        = var.server_configuration["password"]
  }
}
