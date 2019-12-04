module "virthost" {
  source = "../minion"

  base_configuration        = var.base_configuration
  name                      = var.name
  product_version           = var.product_version
  server_configuration      = var.server_configuration
  activation_key            = var.activation_key
  auto_connect_to_master    = var.auto_connect_to_master
  use_os_released_updates   = var.use_os_released_updates
  use_os_unreleased_updates = var.use_os_unreleased_updates
  apparmor                  = var.apparmor
  additional_repos          = var.additional_repos
  additional_packages       = var.additional_packages
  quantity                  = var.quantity
  gpg_keys                  = var.gpg_keys
  ssh_key_path              = var.ssh_key_path
  ipv6                      = var.ipv6
  roles                     = ["minion", "virthost"]
  additional_grains = {
    hvm_disk_image      = var.hvm_disk_image
    hvm_disk_image_hash = var.hvm_disk_image_hash
  }


  // Provider-specific variables
  image     = var.image
  memory    = var.memory
  vcpu      = var.vcpu
  running   = var.running
  mac       = var.mac
  cpu_model = "host-model"
  xslt      = file("${path.module}/sysinfos.xsl")
}

output "configuration" {
  value = module.virthost.configuration
}

