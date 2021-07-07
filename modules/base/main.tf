module "base_backend" {
  source = "../backend/base"

  cc_username          = var.cc_username
  cc_password          = var.cc_password
  timezone             = var.timezone
  use_ntp              = var.use_ntp
  ssh_key_path         = var.ssh_key_path
  mirror               = var.mirror
  use_mirror_images    = var.use_mirror_images
  use_avahi            = var.use_avahi
  domain               = var.domain
  name_prefix          = var.name_prefix
  use_shared_resources = var.use_shared_resources
  testsuite            = var.testsuite
  provider_settings    = var.provider_settings
  images               = var.images
  server_registry_code = var.server_registry_code
}

output "configuration" {
  value = merge({
    cc_username          = var.cc_username
    cc_password          = var.cc_password
    timezone             = var.timezone
    use_ntp              = var.use_ntp
    ssh_key_path         = var.ssh_key_path
    mirror               = var.mirror
    use_mirror_images    = var.use_mirror_images
    use_avahi            = var.use_avahi
    domain               = var.domain
    name_prefix          = var.name_prefix
    use_shared_resources = var.use_shared_resources
    testsuite            = var.testsuite
    server_registry_code = var.server_registry_code
  }, module.base_backend.configuration)
}
