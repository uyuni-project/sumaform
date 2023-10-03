module "salt_testenv" {
  source = "../host"

  base_configuration            = var.base_configuration
  use_os_released_updates       = var.use_os_released_updates
  name                          = var.name
  additional_repos              = var.additional_repos
  additional_repos_only         = var.additional_repos_only
  additional_packages           = var.additional_packages
  swap_file_size                = var.swap_file_size
  ssh_key_path                  = var.ssh_key_path
  image                         = var.image
  provider_settings             = var.provider_settings
  install_salt_bundle           = true

  roles                         = ["salt_testenv"]
}

output "configuration" {
  value = module.salt_testenv.configuration
}
