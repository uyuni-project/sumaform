module "registry" {
  source = "../host"

  base_configuration            = var.base_configuration
  name                          = var.name
  quantity                      = var.quantity
  use_os_released_updates       = var.use_os_released_updates
  additional_repos              = var.additional_repos
  additional_repos_only         = var.additional_repos_only
  additional_packages           = var.additional_packages
  swap_file_size                = var.swap_file_size
  ssh_key_path                  = var.ssh_key_path
  gpg_keys                      = var.gpg_keys
  ipv6                          = var.ipv6
  connect_to_base_network       = var.connect_to_base_network
  connect_to_additional_network = var.connect_to_additional_network
  roles                         = ["registry"]
  disable_firewall              = var.disable_firewall
  grains = {
    mirror                    = var.base_configuration["mirror"]
  }

  image                    = "opensuse153o"
  provider_settings        = var.provider_settings
}

output "configuration" {
  value = {
    id              = length(module.registry.configuration["ids"]) > 0 ? module.registry.configuration["ids"][0] : null
    hostname        = length(module.registry.configuration["hostnames"]) > 0 ? module.registry.configuration["hostnames"][0] : null
  }
}
