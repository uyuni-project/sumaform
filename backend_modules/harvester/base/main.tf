
locals {
  images_used = var.use_shared_resources ? [] : var.images
  image_urls = {
    almalinux8o     = "${var.use_mirror_images ? "http://${var.mirror}" : "https://repo.almalinux.org"}/almalinux/8/cloud/x86_64/images/AlmaLinux-8-GenericCloud-latest.x86_64.qcow2"
    centos6o        = "${var.use_mirror_images ? "http://${var.mirror}" : "https://cloud.centos.org"}/centos/6/images/CentOS-6-x86_64-GenericCloud.qcow2"
    centos7         = "${var.use_mirror_images ? "http://${var.mirror}" : "https://github.com"}/uyuni-project/sumaform-images/releases/download/4.3.0/centos7.qcow2"
    centos7o        = "${var.use_mirror_images ? "http://${var.mirror}" : "https://cloud.centos.org"}/centos/7/images/CentOS-7-x86_64-GenericCloud.qcow2"
    centos8o        = "${var.use_mirror_images ? "http://${var.mirror}" : "https://cloud.centos.org"}/centos/8/x86_64/images/CentOS-8-GenericCloud-8.2.2004-20200611.2.x86_64.qcow2"
    amazonlinux2o   = "${var.use_mirror_images ? "http://${var.mirror}" : "https://cdn.amazonlinux.com"}/os-images/2.0.20210721.2/kvm/amzn2-kvm-2.0.20210721.2-x86_64.xfs.gpt.qcow2"
    opensuse152o    = "${var.use_mirror_images ? "http://${var.mirror}" : "https://download.opensuse.org"}/distribution/leap/15.2/appliances/openSUSE-Leap-15.2-JeOS.x86_64-OpenStack-Cloud.qcow2"
    opensuse153o    = "${var.use_mirror_images ? "http://${var.mirror}" : "https://download.opensuse.org"}/distribution/leap/15.3/appliances/openSUSE-Leap-15.3-JeOS.x86_64-OpenStack-Cloud.qcow2"
    opensuse153armo = "${var.use_mirror_images ? "http://${var.mirror}" : "https://download.opensuse.org"}/distribution/leap/15.3/appliances/openSUSE-Leap-15.3-ARM-JeOS-efi.aarch64.qcow2"
    sles15          = "${var.use_mirror_images ? "http://${var.mirror}" : "http://download.suse.de"}/ibs/Devel:/Galaxy:/Terraform:/Images/images/sles15.x86_64.qcow2"
    sles15o         = "${var.use_mirror_images ? "http://${var.mirror}" : "http://download.suse.de"}/install/SLE-15-JeOS-GM/SLES15-JeOS.x86_64-15.0-OpenStack-Cloud-GM.qcow2"
    sles15sp1       = "${var.use_mirror_images ? "http://${var.mirror}" : "http://download.suse.de"}/ibs/Devel:/Galaxy:/Terraform:/Images/images/sles15sp1.x86_64.qcow2"
    sles15sp1o      = "${var.use_mirror_images ? "http://${var.mirror}" : "http://download.suse.de"}/install/SLE-15-SP1-JeOS-QU4/SLES15-SP1-JeOS.x86_64-15.1-OpenStack-Cloud-QU4.qcow2"
    sles15sp2       = "${var.use_mirror_images ? "http://${var.mirror}" : "http://download.suse.de"}/ibs/Devel:/Galaxy:/Terraform:/Images/images/sles15sp2.x86_64.qcow2"
    sles15sp2o      = "${var.use_mirror_images ? "http://${var.mirror}" : "http://download.suse.de"}/install/SLE-15-SP2-JeOS-GM/SLES15-SP2-JeOS.x86_64-15.2-OpenStack-Cloud-GM.qcow2"
    sles15sp3o      = "${var.use_mirror_images ? "http://${var.mirror}" : "http://download.suse.de"}/install/SLE-15-SP3-JeOS-GM/SLES15-SP3-JeOS.x86_64-15.3-OpenStack-Cloud-GM.qcow2"
    sles15sp4o      = "${var.use_mirror_images ? "http://${var.mirror}" : "http://download.suse.de"}/install/SLE-15-SP4-JeOS-Beta3-202201/SLES15-SP4-JeOS.x86_64-15.4-OpenStack-Cloud-Beta3-202201.qcow2"
    sles11sp4       = "${var.use_mirror_images ? "http://${var.mirror}" : "http://download.suse.de"}/ibs/Devel:/Galaxy:/Terraform:/Images/images/sles11sp4.x86_64.qcow2"
    sles12sp3       = "${var.use_mirror_images ? "http://${var.mirror}" : "http://download.suse.de"}/ibs/Devel:/Galaxy:/Terraform:/Images/images/sles12sp3.x86_64.qcow2"
    sles12sp4       = "${var.use_mirror_images ? "http://${var.mirror}" : "http://download.suse.de"}/ibs/Devel:/Galaxy:/Terraform:/Images/images/sles12sp4.x86_64.qcow2"
    sles12sp4o      = "${var.use_mirror_images ? "http://${var.mirror}" : "http://download.suse.de"}/install/SLE-12-SP4-JeOS-GM/SLES12-SP4-JeOS.x86_64-12.4-OpenStack-Cloud-GM.qcow2"
    sles12sp5o      = "${var.use_mirror_images ? "http://${var.mirror}" : "http://download.suse.de"}/install/SLE-12-SP5-JeOS-GM/SLES12-SP5-JeOS.x86_64-12.5-OpenStack-Cloud-GM.qcow2"
    ubuntu1604o     = "${var.use_mirror_images ? "http://${var.mirror}" : "https://cloud-images.ubuntu.com"}/xenial/current/xenial-server-cloudimg-amd64-disk1.img"
    ubuntu1804      = "${var.use_mirror_images ? "http://${var.mirror}" : "https://github.com"}/uyuni-project/sumaform-images/releases/download/4.4.0/ubuntu1804.qcow2"
    ubuntu1804o     = "${var.use_mirror_images ? "http://${var.mirror}" : "https://cloud-images.ubuntu.com"}/bionic/current/bionic-server-cloudimg-amd64.img"
    ubuntu2004o     = "${var.use_mirror_images ? "http://${var.mirror}" : "https://cloud-images.ubuntu.com"}/focal/current/focal-server-cloudimg-amd64.img"
    debian9o        = "${var.use_mirror_images ? "http://${var.mirror}" : "https://cloud.debian.org"}/images/cloud/OpenStack/current-9/debian-9-openstack-amd64.qcow2"
    debian10o       = "${var.use_mirror_images ? "http://${var.mirror}" : "https://cloud.debian.org"}/images/cloud/OpenStack/current-10/debian-10-openstack-amd64.qcow2"
    debian11o       = "${var.use_mirror_images ? "http://${var.mirror}" : "https://cloud.debian.org"}/cdimage/cloud/bullseye/latest/debian-11-genericcloud-amd64.qcow2"
    opensuse152-ci-pr        = "${var.use_mirror_images ? "http://${var.mirror}" : "https://download.opensuse.org"}/repositories/systemsmanagement:/sumaform:/images:/libvirt/images/opensuse152-ci-pr.x86_64.qcow2"
    opensuse153-ci-pr        = "http://minima-mirror.mgr.prv.suse.net/repositories/systemsmanagement:/sumaform:/images:/libvirt/images/opensuse153-ci-pr.x86_64.qcow2"
    opensuse153-ci-pr-client = "${var.use_mirror_images ? "http://${var.mirror}" : "https://download.opensuse.org"}/repositories/systemsmanagement:/sumaform:/images:/libvirt/images/opensuse153-ci-pr-client.x86_64.qcow2"
    slemicro51-ign  = "${var.use_mirror_images ? "http://${var.mirror}" : "http://download.opensuse.org"}/repositories/systemsmanagement:/sumaform:/images:/microos/images_51/SUSE-MicroOS.x86_64-sumaform.qcow2"
    slemicro51o-ign = "${var.use_mirror_images ? "http://${var.mirror}" : "http://download.suse.de"}/install/SLE-Micro-5.1-GM/SUSE-MicroOS.x86_64-5.1.0-Default-GM.raw.xz"
  }
  network_name       = lookup(var.provider_settings, "network_name", "default")
  bridge             = lookup(var.provider_settings, "bridge", null)
  additional_network = lookup(var.provider_settings, "additional_network", null)
  namespace          = lookup(var.provider_settings, "namespace", "default")
}

resource "harvester_image" "images" {
  for_each = local.images_used

  name         = "${var.name_prefix}${each.value}"
  display_name = "${var.name_prefix}${each.value}"
  namespace    = local.namespace
  source_type  = "download"
  url          = local.image_urls[each.value]
}

resource "harvester_network" "additional_network" {
  count     = local.additional_network == null ? 0 : 1
  name      = "${var.name_prefix}private"
  namespace = local.namespace

  route_mode    = "manual"
  route_cidr    = local.additional_network
  route_gateway = cidrhost(local.additional_network, 1)
  vlan_id = 4000
}

output "configuration" {
  depends_on = [
    harvester_image.images,
    harvester_network.additional_network,
  ]
  value = {
    additional_network      = local.additional_network
    additional_network_name = join(",", harvester_network.additional_network.*.name)

    network_name = local.network_name
  }
}
