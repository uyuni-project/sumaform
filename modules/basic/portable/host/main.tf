module "aws_host" {
  source = "../../aws/host"

  # base_configuration            = var.base_configuration
  name                          = var.name
  # roles                         = var.roles
  # use_os_released_updates       = var.use_os_released_updates
  # use_os_unreleased_updates     = var.use_os_unreleased_updates
  # additional_repos              = var.additional_repos
  # additional_repos_only         = var.additional_repos_only
  # additional_certs              = var.additional_certs
  # additional_packages           = var.additional_packages
  # grains                        = var.grains
  # swap_file_size                = var.swap_file_size
  # ssh_key_path                  = var.ssh_key_path
  # gpg_keys                      = var.gpg_keys
  # ipv6                          = var.ipv6
  # connect_to_base_network       = var.connect_to_base_network
  # connect_to_additional_network = var.connect_to_additional_network
  # image                         = var.image
  quantity                      = var.provider_name == "aws" ? var.quantity : 0
  provider_settings             = var.provider_settings
}

module "libvirt_host" {
  source = "../../libvirt/host"

  base_configuration            = var.base_configuration
  name                          = var.name
  roles                         = var.roles
  use_os_released_updates       = var.use_os_released_updates
  use_os_unreleased_updates     = var.use_os_unreleased_updates
  additional_repos              = var.additional_repos
  additional_repos_only         = var.additional_repos_only
  additional_certs              = var.additional_certs
  additional_packages           = var.additional_packages
  grains                        = var.grains
  swap_file_size                = var.swap_file_size
  ssh_key_path                  = var.ssh_key_path
  gpg_keys                      = var.gpg_keys
  ipv6                          = var.ipv6
  connect_to_base_network       = var.connect_to_base_network
  connect_to_additional_network = var.connect_to_additional_network
  image                         = var.image
  quantity                      = var.provider_name == "libvirt" ? var.quantity : 0
  provider_settings             = var.provider_settings
}

output "configuration" {
  value = module.libvirt_host.configuration
}
