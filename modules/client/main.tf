module "client" {
  source = "../host"

  base_configuration            = var.base_configuration
  name                          = var.name
  quantity                      = var.quantity
  use_os_released_updates       = var.use_os_released_updates
  use_os_unreleased_updates     = var.use_os_unreleased_updates
  install_salt_bundle           = var.install_salt_bundle
  install_salt_minion           = var.install_salt_minion
  additional_repos              = var.additional_repos
  additional_repos_only         = var.additional_repos_only
  additional_packages           = var.additional_packages
  gpg_keys                      = var.gpg_keys
  swap_file_size                = var.swap_file_size
  ssh_key_path                  = var.ssh_key_path
  ipv6                          = var.ipv6
  connect_to_base_network       = true
  connect_to_additional_network = true
  roles                         = ["client"]
  disable_firewall              = var.disable_firewall
  grains = {
    product_version = var.product_version
    mirror          = var.base_configuration["mirror"]
    server          = var.server_configuration["hostname"]
    auto_register   = var.auto_register
  }

  image             = var.image
  provider_settings = var.provider_settings
}

output "configuration" {
  value = module.client.configuration
}

