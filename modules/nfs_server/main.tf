module "nfs_server" {
  source = "../host"

  base_configuration       = var.base_configuration
  name                     = var.name
  use_os_released_updates  = var.use_os_released_updates
  install_salt_bundle      = var.install_salt_bundle
  additional_repos         = var.additional_repos
  additional_repos_only    = var.additional_repos_only
  additional_packages      = var.additional_packages
  swap_file_size           = var.swap_file_size
  ssh_key_path             = var.ssh_key_path
  roles                    = ["nfs_server"]
  image                    = var.image
  provider_settings        = var.provider_settings
  volume_provider_settings = var.volume_provider_settings
  additional_disk_size     = var.data_disk_size

  grains = {
    export_path    = var.export_path
    allowed_cidr   = var.allowed_cidr
    export_options = var.export_options
    data_disk_size = var.data_disk_size
  }
}

output "configuration" {
  value = module.nfs_server.configuration
}
