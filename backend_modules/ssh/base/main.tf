
resource "null_resource" "base" {
  triggers = {
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
    provider_settings    = yamlencode(var.provider_settings)
  }
}

output "configuration" {
  value = {
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

    additional_network = lookup(var.provider_settings, "additional_network", null)

    // only supported in ssh connection
    private_key = lookup(var.provider_settings, "private_key", null)
    certificate = lookup(var.provider_settings, "certificate", null)
    host_key    = lookup(var.provider_settings, "host_key", null)

    bastion_host        = lookup(var.provider_settings, "bastion_host", null)
    bastion_host_key    = lookup(var.provider_settings, "bastion_host_key", null)
    bastion_port        = lookup(var.provider_settings, "bastion_port", null)
    bastion_user        = lookup(var.provider_settings, "bastion_user", null)
    bastion_password    = lookup(var.provider_settings, "bastion_password", null)
    bastion_private_key = lookup(var.provider_settings, "bastion_private_key", null)
    bastion_certificate = lookup(var.provider_settings, "bastion_certificate", null)
    timeout             = lookup(var.provider_settings, "timeout", "20s")
  }
}
