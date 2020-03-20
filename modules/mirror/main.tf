
module "mirror" {
  source = "../host"

  base_configuration  = var.base_configuration
  name                = "mirror"
  additional_repos    = var.additional_repos
  additional_packages = var.additional_packages
  swap_file_size      = var.swap_file_size
  ssh_key_path        = var.ssh_key_path
  roles               = ["mirror"]

  grains = {
    cc_username       = var.base_configuration["cc_username"]
    cc_password       = var.base_configuration["cc_password"]
    ubuntu_distros    = var.ubuntu_distros
    use_mirror_images = var.base_configuration["use_mirror_images"]
    data_disk_fstype  = var.data_disk_fstype
  }

  image = "opensuse151"

  provider_settings        = var.provider_settings
  additional_disk_size     = var.repository_disk_size
  volume_provider_settings = var.volume_provider_settings
}

output "configuration" {
  value = module.mirror.configuration
}
