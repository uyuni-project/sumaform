
locals {
  images_used = var.use_shared_resources ? [] : var.images
  image_urls = {
    centos6o     = "${var.use_mirror_images ? "http://${var.mirror}" : "https://cloud.centos.org"}/centos/6/images/CentOS-6-x86_64-GenericCloud.qcow2"
    centos7      = "${var.use_mirror_images ? "http://${var.mirror}" : "https://github.com"}/moio/sumaform-images/releases/download/4.3.0/centos7.qcow2"
    centos7o     = "${var.use_mirror_images ? "http://${var.mirror}" : "https://cloud.centos.org"}/centos/7/images/CentOS-7-x86_64-GenericCloud.qcow2"
    centos8o     = "${var.use_mirror_images ? "http://${var.mirror}" : "https://cloud.centos.org"}/centos/8/x86_64/images/CentOS-8-GenericCloud-8.2.2004-20200611.2.x86_64.qcow2"
    opensuse150  = "${var.use_mirror_images ? "http://${var.mirror}" : "https://download.opensuse.org"}/repositories/systemsmanagement:/sumaform:/images:/libvirt/images/opensuse150.x86_64.qcow2"
    opensuse150o = "${var.use_mirror_images ? "http://${var.mirror}" : "https://download.opensuse.org"}/distribution/leap/15.0/jeos/openSUSE-Leap-15.0-JeOS.x86_64-15.0.1-OpenStack-Cloud-Snapshot21.14.qcow2"
    opensuse151  = "${var.use_mirror_images ? "http://${var.mirror}" : "https://download.opensuse.org"}/repositories/systemsmanagement:/sumaform:/images:/libvirt/images/opensuse151.x86_64.qcow2"
    opensuse151o = "${var.use_mirror_images ? "http://${var.mirror}" : "https://download.opensuse.org"}/distribution/leap/15.1/jeos/openSUSE-Leap-15.1-JeOS.x86_64-15.1.0-OpenStack-Cloud-Current.qcow2"
    opensuse152o = "${var.use_mirror_images ? "http://${var.mirror}" : "https://download.opensuse.org"}/distribution/leap/15.2/appliances/openSUSE-Leap-15.2-JeOS.x86_64-OpenStack-Cloud.qcow2"
    sles15       = "${var.use_mirror_images ? "http://${var.mirror}" : "http://download.suse.de"}/ibs/Devel:/Galaxy:/Terraform:/Images/images/sles15.x86_64.qcow2"
    sles15o      = "${var.use_mirror_images ? "http://${var.mirror}" : "http://download.suse.de"}/install/SLE-15-JeOS-GM/SLES15-JeOS.x86_64-15.0-OpenStack-Cloud-GM.qcow2"
    sles15sp1    = "${var.use_mirror_images ? "http://${var.mirror}" : "http://download.suse.de"}/ibs/Devel:/Galaxy:/Terraform:/Images/images/sles15sp1.x86_64.qcow2"
    sles15sp1o   = "${var.use_mirror_images ? "http://${var.mirror}" : "https://download.suse.de"}/install/SLE-15-SP1-JeOS-QU4/SLES15-SP1-JeOS.x86_64-15.1-OpenStack-Cloud-QU4.qcow2"
    sles15sp2    = "${var.use_mirror_images ? "http://${var.mirror}" : "http://download.suse.de"}/ibs/Devel:/Galaxy:/Terraform:/Images/images/sles15sp2.x86_64.qcow2"
    sles15sp2o   = "${var.use_mirror_images ? "http://${var.mirror}" : "https://download.suse.de"}/install/SLE-15-SP2-JeOS-GM/SLES15-SP2-JeOS.x86_64-15.2-OpenStack-Cloud-GM.qcow2"
    sles15sp3o   = "${var.use_mirror_images ? "http://${var.mirror}" : "https://download.suse.de"}/install/SLE-15-SP3-JeOS-PublicBeta/SLES15-SP3-JeOS.x86_64-15.3-OpenStack-Cloud-PublicBeta.qcow2"
    sles11sp4    = "${var.use_mirror_images ? "http://${var.mirror}" : "http://download.suse.de"}/ibs/Devel:/Galaxy:/Terraform:/Images/images/sles11sp4.x86_64.qcow2"
    sles12       = "${var.use_mirror_images ? "http://${var.mirror}" : "http://download.suse.de"}/ibs/Devel:/Galaxy:/Terraform:/Images/images/sles12.x86_64.qcow2"
    sles12sp1    = "${var.use_mirror_images ? "http://${var.mirror}" : "http://download.suse.de"}/ibs/Devel:/Galaxy:/Terraform:/Images/images/sles12sp1.x86_64.qcow2"
    sles12sp2    = "${var.use_mirror_images ? "http://${var.mirror}" : "http://download.suse.de"}/ibs/Devel:/Galaxy:/Terraform:/Images/images/sles12sp2.x86_64.qcow2"
    sles12sp3    = "${var.use_mirror_images ? "http://${var.mirror}" : "http://download.suse.de"}/ibs/Devel:/Galaxy:/Terraform:/Images/images/sles12sp3.x86_64.qcow2"
    sles12sp4    = "${var.use_mirror_images ? "http://${var.mirror}" : "http://download.suse.de"}/ibs/Devel:/Galaxy:/Terraform:/Images/images/sles12sp4.x86_64.qcow2"
    sles12sp4o   = "${var.use_mirror_images ? "http://${var.mirror}" : "http://download.suse.de"}/install/SLE-12-SP4-JeOS-GM/SLES12-SP4-JeOS.x86_64-12.4-OpenStack-Cloud-GM.qcow2"
    sles12sp5o   = "${var.use_mirror_images ? "http://${var.mirror}" : "https://download.suse.de"}/install/SLE-12-SP5-JeOS-GM/SLES12-SP5-JeOS.x86_64-12.5-OpenStack-Cloud-GM.qcow2"
    ubuntu1604o  = "${var.use_mirror_images ? "http://${var.mirror}" : "https://cloud-images.ubuntu.com"}/xenial/current/xenial-server-cloudimg-amd64-disk1.img"
    ubuntu1804   = "${var.use_mirror_images ? "http://${var.mirror}" : "https://github.com"}/moio/sumaform-images/releases/download/4.4.0/ubuntu1804.qcow2"
    ubuntu1804o  = "${var.use_mirror_images ? "http://${var.mirror}" : "https://cloud-images.ubuntu.com"}/bionic/current/bionic-server-cloudimg-amd64.img"
    ubuntu2004o  = "${var.use_mirror_images ? "http://${var.mirror}" : "https://cloud-images.ubuntu.com"}/focal/current/focal-server-cloudimg-amd64.img"
    debian9o     = "${var.use_mirror_images ? "http://${var.mirror}" : "https://cloud.debian.org"}/images/cloud/OpenStack/current-9/debian-9-openstack-amd64.qcow2"
    debian10o    = "${var.use_mirror_images ? "http://${var.mirror}" : "https://cloud.debian.org"}/images/cloud/OpenStack/current-10/debian-10-openstack-amd64.qcow2"
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
    additional_network    = local.additional_network
    additional_network_id = join(",", libvirt_network.additional_network.*.id)

    pool         = local.pool
    network_name = local.bridge == null ? local.network_name : null
    bridge       = local.bridge
  }
}
