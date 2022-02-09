
module "jenkins" {
  source = "../host"

  base_configuration      = var.base_configuration
  name                    = "jenkins"
  use_os_released_updates = var.use_os_released_updates
  additional_repos        = var.additional_repos
  additional_repos_only         = var.additional_repos_only
  additional_packages     = var.additional_packages
  swap_file_size          = var.swap_file_size
  ssh_key_path            = var.ssh_key_path
  roles                   = ["jenkins"]

  grains = {
    mirror                  = var.base_configuration["mirror"]
    data_disk_fstype        = var.data_disk_fstype
  }

  image = var.image

  provider_settings        = var.provider_settings
  additional_disk_size     = var.data_disk_size
  volume_provider_settings = var.volume_provider_settings
}

output "configuration" {
  value = module.jenkins.configuration
}
