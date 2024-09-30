module "virthost" {
  source = "../minion"

  base_configuration        = var.base_configuration
  name                      = var.name
  product_version           = var.product_version
  server_configuration      = var.server_configuration
  activation_key            = var.activation_key
  auto_connect_to_master    = var.auto_connect_to_master
  use_os_released_updates   = var.use_os_released_updates
  install_salt_bundle       = var.install_salt_bundle
  additional_repos          = var.additional_repos
  additional_repos_only     = var.additional_repos_only
  additional_packages       = var.additional_packages
  quantity                  = var.quantity
  gpg_keys                  = var.gpg_keys
  ssh_key_path              = var.ssh_key_path
  ipv6                      = var.ipv6
  roles                     = ["minion", "virthost"]
  additional_grains = merge({
    hvm_disk_image      = var.hvm_disk_image
    sles_registration_code = var.sles_registration_code
  },var.additional_grains)

  image     = var.image
  provider_settings =var.provider_settings
}

output "configuration" {
  value = module.virthost.configuration
}
