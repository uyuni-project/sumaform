module "base_backend" {
  source = "../backend/base"

  cc_username              = var.cc_username
  cc_password              = var.cc_password
  product_version          = var.product_version
  timezone                 = var.timezone
  use_ntp                  = var.use_ntp
  ssh_key_path             = var.ssh_key_path
  mirror                   = var.mirror
  use_mirror_images        = var.use_mirror_images
  use_avahi                = var.use_avahi
  domain                   = var.domain
  name_prefix              = var.name_prefix
  use_shared_resources     = var.use_shared_resources
  testsuite                = var.testsuite
  provider_settings        = var.provider_settings
  images                   = var.images
  use_eip_bastion          = var.use_eip_bastion
  is_server_paygo_instance = var.is_server_paygo_instance
}

output "configuration" {
  value = merge({
    cc_username              = var.cc_username
    cc_password              = var.cc_password
    product_version          = var.product_version
    timezone                 = var.timezone
    use_ntp                  = var.use_ntp
    ssh_key_path             = var.ssh_key_path
    mirror                   = var.mirror
    use_mirror_images        = var.use_mirror_images
    use_avahi                = var.use_avahi
    domain                   = var.domain
    name_prefix              = var.name_prefix
    use_shared_resources     = var.use_shared_resources
    testsuite                = var.testsuite
    use_eip_bastion          = var.use_eip_bastion
    salt_log_lvl_debug       = var.salt_log_lvl_debug
    # WORKAROUND
    # For some reason, the key "additional_network" from AWS module gets lost
    # Force it into existence
    additional_network       = null
    # END OF WORKAROUND
  }, module.base_backend.configuration)
}
