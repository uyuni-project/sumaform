
locals {
  images_used = var.use_shared_resources ? [] : var.images
  image_urls = {
    centos7     = "${var.use_mirror_images ? "http://${var.mirror}" : "https://github.com"}/moio/sumaform-images/releases/download/4.3.0/centos7.qcow2"
    opensuse150 = "${var.use_mirror_images ? "http://${var.mirror}" : "https://download.opensuse.org"}/repositories/systemsmanagement:/sumaform:/images:/libvirt/images/opensuse150.x86_64.qcow2"
    opensuse151 = "https://download.opensuse.org/repositories/systemsmanagement:/sumaform:/images:/libvirt/images/opensuse151.x86_64.qcow2"
    sles15      = "${var.use_mirror_images ? "http://${var.mirror}" : "http://download.suse.de"}/ibs/Devel:/Galaxy:/Terraform:/Images/images/sles15.x86_64.qcow2"
    sles15sp1   = "${var.use_mirror_images ? "http://${var.mirror}" : "http://download.suse.de"}/ibs/Devel:/Galaxy:/Terraform:/Images/images/sles15sp1.x86_64.qcow2"
    sles15sp2   = "${var.use_mirror_images ? "http://${var.mirror}" : "http://download.suse.de"}/ibs/Devel:/Galaxy:/Terraform:/Images/images/sles15sp2.x86_64.qcow2"
    sles11sp4   = "${var.use_mirror_images ? "http://${var.mirror}" : "http://download.suse.de"}/ibs/Devel:/Galaxy:/Terraform:/Images/images/sles11sp4.x86_64.qcow2"
    sles12      = "${var.use_mirror_images ? "http://${var.mirror}" : "http://download.suse.de"}/ibs/Devel:/Galaxy:/Terraform:/Images/images/sles12.x86_64.qcow2"
    sles12sp1   = "${var.use_mirror_images ? "http://${var.mirror}" : "http://download.suse.de"}/ibs/Devel:/Galaxy:/Terraform:/Images/images/sles12sp1.x86_64.qcow2"
    sles12sp2   = "${var.use_mirror_images ? "http://${var.mirror}" : "http://download.suse.de"}/ibs/Devel:/Galaxy:/Terraform:/Images/images/sles12sp2.x86_64.qcow2"
    sles12sp3   = "${var.use_mirror_images ? "http://${var.mirror}" : "http://download.suse.de"}/ibs/Devel:/Galaxy:/Terraform:/Images/images/sles12sp3.x86_64.qcow2"
    sles12sp4   = "${var.use_mirror_images ? "http://${var.mirror}" : "http://download.suse.de"}/ibs/Devel:/Galaxy:/Terraform:/Images/images/sles12sp4.x86_64.qcow2"
    ubuntu1804  = "${var.use_mirror_images ? "http://${var.mirror}" : "https://github.com"}/moio/sumaform-images/releases/download/4.4.0/ubuntu1804.qcow2"
  }
  pool               = lookup(var.provider_settings, "pool", "default")
  network_name       = lookup(var.provider_settings, "network_name", "default")
  bridge             = lookup(var.provider_settings, "bridge", null)
  additional_network = lookup(var.provider_settings, "additional_network", null)
}

resource "libvirt_volume" "volumes" {
  for_each = local.images_used

  name   = "${var.name_prefix}${each.value}"
  source = local.image_urls[each.value]
  pool   = local.pool
}

resource "libvirt_network" "additional_network" {
  count     = local.additional_network == null ? 0 : 1
  name      = "${var.name_prefix}private"
  mode      = "none"
  addresses = [local.additional_network]
  dhcp {
    enabled = "false"
  }
  autostart = "true"
}

output "configuration" {
  depends_on = [
    libvirt_volume.volumes,
    libvirt_network.additional_network,
  ]
  value = {
    cc_username           = var.cc_username
    cc_password           = var.cc_password
    timezone              = var.timezone
    ssh_key_path          = var.ssh_key_path
    mirror                = var.mirror
    use_mirror_images     = var.use_mirror_images
    use_avahi             = var.use_avahi
    domain                = var.domain
    name_prefix           = var.name_prefix
    use_shared_resources  = var.use_shared_resources
    testsuite             = var.testsuite
    additional_network    = local.additional_network
    additional_network_id = join(",", libvirt_network.additional_network.*.id)

    pool         = local.pool
    network_name = local.bridge == null ? local.network_name : null
    bridge       = local.bridge
  }
}
