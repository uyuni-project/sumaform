
locals {
  images_used = var.use_shared_resources ? [] : var.images
  image_urls = {
    almalinux8o              = "${var.use_mirror_images ? "http://${var.mirror}" : "http://repo.almalinux.org"}/almalinux/8/cloud/x86_64/images/AlmaLinux-8-GenericCloud-latest.x86_64.qcow2"
    almalinux9o              = "${var.use_mirror_images ? "http://${var.mirror}" : "http://repo.almalinux.org"}/almalinux/9/cloud/x86_64/images/AlmaLinux-9-GenericCloud-latest.x86_64.qcow2"
    amazonlinux2o            = "${var.use_mirror_images ? "http://${var.mirror}" : "http://cdn.amazonlinux.com"}/os-images/2.0.20210721.2/kvm/amzn2-kvm-2.0.20210721.2-x86_64.xfs.gpt.qcow2"
    amazonlinux2023o         = "${var.use_mirror_images ? "http://${var.mirror}" : "http://cdn.amazonlinux.com"}/al2023/os-images/latest/kvm/al2023-kvm-2023.7.20250331.0-kernel-6.1-x86_64.xfs.gpt.qcow2"
    centos7                  = "${var.use_mirror_images ? "http://${var.mirror}" : "http://github.com"}/uyuni-project/sumaform-images/releases/download/4.3.0/centos7.qcow2"
    centos7o                 = "${var.use_mirror_images ? "http://${var.mirror}" : "http://cloud.centos.org"}/centos/7/images/CentOS-7-x86_64-GenericCloud.qcow2"
    centos8o                 = "${var.use_mirror_images ? "http://${var.mirror}" : "http://cloud.centos.org"}/centos/8/x86_64/images/CentOS-8-GenericCloud-8.2.2004-20200611.2.x86_64.qcow2"
    centos9o                 = "${var.use_mirror_images ? "http://${var.mirror}" : "http://cloud.centos.org"}/centos/9-stream/x86_64/images/CentOS-Stream-GenericCloud-9-20220829.0.x86_64.qcow2"
    libertylinux9o           = "${var.use_mirror_images ? "http://${var.mirror}" : "http://zenon.suse.de"}/download/sll9.1-cloud/sll9.1-cloud.img"
    openeuler2403o           = "${var.use_mirror_images ? "http://${var.mirror}" : "http://repo.openeuler.org"}/openEuler-24.03-LTS/virtual_machine_img/x86_64/openEuler-24.03-LTS-x86_64.qcow2.xz"
    oraclelinux8o            = "${var.use_mirror_images ? "http://${var.mirror}" : "http://yum.oracle.com"}/templates/OracleLinux/OL8/u6/x86_64/OL8U6_x86_64-kvm-b126.qcow"
    oraclelinux9o            = "${var.use_mirror_images ? "http://${var.mirror}" : "http://yum.oracle.com"}/templates/OracleLinux/OL9/u0/x86_64/OL9U0_x86_64-kvm-b142.qcow"
    rocky8o                  = "${var.use_mirror_images ? "http://${var.mirror}" : "http://download.rockylinux.org"}/pub/rocky/8/images/x86_64/Rocky-8-GenericCloud.latest.x86_64.qcow2"
    rocky9o                  = "${var.use_mirror_images ? "http://${var.mirror}" : "http://download.rockylinux.org"}/pub/rocky/9/images/x86_64/Rocky-9-GenericCloud.latest.x86_64.qcow2"
    opensuse155o             = "${var.use_mirror_images ? "http://${var.mirror}" : "http://download.opensuse.org"}/distribution/leap/15.5/appliances/openSUSE-Leap-15.5-Minimal-VM.x86_64-Cloud.qcow2"
    opensuse156o             = "${var.use_mirror_images ? "http://${var.mirror}" : "http://download.opensuse.org"}/distribution/leap/15.6/appliances/openSUSE-Leap-15.6-Minimal-VM.x86_64-Cloud.qcow2"
    opensuse155armo          = "${var.use_mirror_images ? "http://${var.mirror}" : "http://download.opensuse.org"}/distribution/leap/15.5/appliances/openSUSE-Leap-15.5-Minimal-VM.aarch64-Cloud.qcow2"
    opensuse156armo          = "${var.use_mirror_images ? "http://${var.mirror}" : "http://download.opensuse.org"}/distribution/leap/15.6/appliances/openSUSE-Leap-15.6-Minimal-VM.aarch64-Cloud.qcow2"
    sles15sp3o               = "${var.use_mirror_images ? "http://${var.mirror}" : "http://dist.nue.suse.com"}/install/SLE-15-SP3-JeOS-GM/SLES15-SP3-JeOS.x86_64-15.3-OpenStack-Cloud-GM.qcow2"
    sles15sp4o               = "${var.use_mirror_images ? "http://${var.mirror}" : "http://dist.nue.suse.com"}/install/SLE-15-SP4-Minimal-GM/SLES15-SP4-Minimal-VM.x86_64-OpenStack-Cloud-GM.qcow2"
    sles15sp5o               = "${var.use_mirror_images ? "http://${var.mirror}" : "http://dist.nue.suse.com"}/install/SLE-15-SP5-Minimal-GM/SLES15-SP5-Minimal-VM.x86_64-Cloud-GM.qcow2"
    sles15sp6o               = "${var.use_mirror_images ? "http://${var.mirror}" : "http://dist.nue.suse.com"}/install/SLE-15-SP6-Minimal-GM/SLES15-SP6-Minimal-VM.x86_64-Cloud-GM.qcow2"
    sles15sp7o               = "${var.use_mirror_images ? "http://${var.mirror}" : "http://dist.nue.suse.com"}/install/SLE-15-SP7-Minimal-GM/SLES15-SP7-Minimal-VM.x86_64-Cloud-GM.qcow2"
    sles12sp5o               = "${var.use_mirror_images ? "http://${var.mirror}" : "http://dist.nue.suse.com"}/install/SLE-12-SP5-JeOS-GM/SLES12-SP5-JeOS.x86_64-12.5-OpenStack-Cloud-GM.qcow2"
    ubuntu2004o              = "${var.use_mirror_images ? "http://${var.mirror}" : "http://cloud-images.ubuntu.com"}/focal/current/focal-server-cloudimg-amd64.img"
    ubuntu2204o              = "${var.use_mirror_images ? "http://${var.mirror}" : "http://cloud-images.ubuntu.com"}/jammy/current/jammy-server-cloudimg-amd64.img"
    ubuntu2404o              = "${var.use_mirror_images ? "http://${var.mirror}" : "http://cloud-images.ubuntu.com"}/noble/current/noble-server-cloudimg-amd64.img"
    debian12o                = "${var.use_mirror_images ? "http://${var.mirror}" : "http://cloud.debian.org"}/images/cloud/bookworm/latest/debian-12-genericcloud-amd64.qcow2"
    opensuse155-ci-pro       = "${var.use_mirror_images ? "http://${var.mirror}" : "http://download.opensuse.org"}/repositories/systemsmanagement:/sumaform:/images:/libvirt/images/opensuse155-ci-pr.x86_64.qcow2"
    slemicro51-ign           = "${var.use_mirror_images ? "http://${var.mirror}" : "http://download.opensuse.org"}/repositories/systemsmanagement:/sumaform:/images:/microos/images_51/SUSE-MicroOS.x86_64-sumaform.qcow2"
    slemicro52-ign           = "${var.use_mirror_images ? "http://${var.mirror}" : "http://download.opensuse.org"}/repositories/systemsmanagement:/sumaform:/images:/microos/images_52/SUSE-MicroOS.x86_64-sumaform.qcow2"
    slemicro53-ign           = "${var.use_mirror_images ? "http://${var.mirror}" : "http://download.opensuse.org"}/repositories/systemsmanagement:/sumaform:/images:/microos/images_53/SLE-Micro.x86_64-sumaform.qcow2"
    slemicro54-ign           = "${var.use_mirror_images ? "http://${var.mirror}" : "http://download.opensuse.org"}/repositories/systemsmanagement:/sumaform:/images:/microos/images_54/SLE-Micro.x86_64-sumaform.qcow2"
    slemicro55o              = "${var.use_mirror_images ? "http://${var.mirror}" : "http://download.opensuse.org"}/repositories/systemsmanagement:/sumaform:/images:/microos/images_55/SLE-Micro.x86_64-sumaform.qcow2"
    slmicro60o               = "${var.use_mirror_images ? "http://${var.mirror}" : "http://download.opensuse.org"}/repositories/systemsmanagement:/sumaform:/images:/microos/images_60/SL-Micro.x86_64-sumaform.qcow2"
    slmicro61o               = "${var.use_mirror_images ? "http://${var.mirror}" : "http://download.opensuse.org"}/repositories/systemsmanagement:/sumaform:/images:/microos/images_61/SL-Micro.x86_64-sumaform.qcow2"
    suma43VM-ign             = "${var.use_mirror_images ? "http://${var.mirror}" : "http://dist.nue.suse.com"}/ibs/Devel:/Galaxy:/Manager:/4.3/images/SUSE-Manager-Server.x86_64-KVM-x86_64.qcow2"
    leapmicro55o             = "${var.use_mirror_images ? "http://${var.mirror}" : "http://download.opensuse.org"}/distribution/leap-micro/5.5/appliances/openSUSE-Leap-Micro.x86_64-Default-qcow.qcow2"
    tumbleweedo              = "${var.use_mirror_images ? "http://${var.mirror}" : "http://download.opensuse.org"}/tumbleweed/appliances/openSUSE-Tumbleweed-Minimal-VM.x86_64-Cloud.qcow2"
  }
  compressed_images = toset(["openeuler2403o"])
  pool               = lookup(var.provider_settings, "pool", "default")
  network_name       = lookup(var.provider_settings, "network_name", "default")
  bridge             = lookup(var.provider_settings, "bridge", null)
  additional_network = lookup(var.provider_settings, "additional_network", null)
}

resource "null_resource" "decompressed_images" {
  for_each = setintersection(local.compressed_images, local.images_used)

  provisioner "local-exec" {
    command = <<EOT
      if [ ! -f "decompressed_images/${each.value}.qcow2" ]; then
        mkdir -p decompressed_images
        echo "Downloading and decompressing ${each.value}..."
        curl -sS -L -o "decompressed_images/${each.value}.qcow2.xz" "${local.image_urls[each.value]}"
        xz -d "decompressed_images/${each.value}.qcow2.xz"
      else
        echo "${each.value}.qcow2 is already present in decompressed_images/ directory"
      fi
    EOT
  }
}

resource "libvirt_volume" "volumes" {
  for_each = local.images_used

  name   = "${var.name_prefix}${each.value}"
  source = contains(local.compressed_images, each.value) ? "decompressed_images/${each.value}.qcow2" : local.image_urls[each.value]
  pool   = local.pool

  depends_on = [
    null_resource.decompressed_images
  ]
}

resource "null_resource" "cleanup_decompressed_images" {
  provisioner "local-exec" {
    when = destroy
    command = "[ -d decompressed_images ] && rm -r decompressed_images/ || true"
  }
}

resource "libvirt_network" "additional_network" {
  count     = local.additional_network == null ? 0 : 1
  name      = "${var.name_prefix}private"
  mode      = "none"
  addresses = [local.additional_network]
  dns {
    enabled = "false"
  }
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

    pool                = local.pool
    network_name        = local.bridge == null ? local.network_name : null
    bridge              = local.bridge
    bastion_host        = lookup(var.provider_settings, "bastion_host", null)
    bastion_host_key    = lookup(var.provider_settings, "bastion_host_key", null)
    bastion_port        = lookup(var.provider_settings, "bastion_port", null)
    bastion_user        = lookup(var.provider_settings, "bastion_user", null)
    bastion_password    = lookup(var.provider_settings, "bastion_password", null)
    bastion_private_key = lookup(var.provider_settings, "bastion_private_key", null)
    bastion_certificate = lookup(var.provider_settings, "bastion_certificate", null)
  }
}
