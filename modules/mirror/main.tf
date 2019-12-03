
module "data_disk" {
  source = "../backend/volume"
  volume_name = "${var.base_configuration["name_prefix"]}mirror-data-disk"
  volume_size = 1099511627776 # 1 TiB
  volume_provider_settings = var.volume_provider_settings
  quantity = 1
}

module "mirror" {
  source = "../backend/host"

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
    data_disk_device  = "vdb"
    ubuntu_distros    = var.ubuntu_distros
    use_mirror_images = var.base_configuration["use_mirror_images"]
  }



  image   = "opensuse151"

  provider_settings = merge(
  var.provider_settings,
  {
   additional_disk = length(module.data_disk.configuration.ids) > 0 ? [{ volume_id = module.data_disk.configuration.ids[0] }] : []
  })
}
