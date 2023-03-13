locals {
  resource_name_prefix = "${var.base_configuration["name_prefix"]}${var.name}"
  manufacturer = lookup(var.provider_settings, "manufacturer", "Intel")
  product      = lookup(var.provider_settings, "product", "Genuine")
  x86_64_v2_images = ["almalinux9o", "libertylinux9o", "oraclelinux9o", "rocky9o"]
  provider_settings = merge({
    memory          = 1024
    vcpu            = 1
    running         = true
    mac             = null
    cpu_model       = "custom"
    xslt            = null
    },
    contains(local.x86_64_v2_images, var.image) ? { cpu_model = "host-model", xslt = file("${path.module}/cpu_features.xsl") } : {},
    contains(var.roles, "server") ? { memory = 4096, vcpu = 2 } : {},
    contains(var.roles, "server_containerized") ? { memory = 4096, vcpu = 2 } : {},
    contains(var.roles, "server") && lookup(var.base_configuration, "testsuite", false) ? { memory = 8192, vcpu = 4 } : {},
    contains(var.roles, "server_containerized") && lookup(var.base_configuration, "testsuite", false) ? { memory = 8192, vcpu = 4 } : {},
    contains(var.roles, "proxy") && lookup(var.base_configuration, "testsuite", false) ? { memory = 2048, vcpu = 2 } : {},
    contains(var.roles, "pxe_boot")? { memory = 2048} : {},
    contains(var.roles, "mirror") ? { memory = 1024 } : {},
    contains(var.roles, "build_host") ? { vcpu = 2 } : {},
    contains(var.roles, "controller") ? { memory = 2048 } : {},
    contains(var.roles, "grafana") ? { memory = 4096 } : {},
    contains(var.roles, "virthost") ? { memory = 4096, vcpu = 3 } : {},
    contains(var.roles, "jenkins") ? { memory = 16384, vcpu = 4 } : {},
    var.provider_settings,
    contains(var.roles, "virthost") ? { cpu_model = "host-passthrough", xslt = file("${path.module}/virthost.xsl") } : {},
    contains(var.roles, "pxe_boot") ? { xslt = templatefile("${path.module}/pxe_boot.xsl", { manufacturer = local.manufacturer, product = local.product }) } : {})
  cloud_init = length(regexall("o$", var.image)) > 0
  ignition = length(regexall("-ign$", var.image)) > 0
}

data "template_file" "user_data" {
  template = file("${path.module}/user_data.yaml")
  vars = {
    image               = var.image
    use_mirror_images   = var.base_configuration["use_mirror_images"]
    mirror              = var.base_configuration["mirror"]
    install_salt_bundle = var.install_salt_bundle
  }
}

data "template_file" "network_config" {
  template = file("${path.module}/network_config.yaml")
  vars = {
    image = var.image
  }
}

data "template_file" "ignition" {
  template = file("${path.module}/config.ign")
}

resource "libvirt_volume" "main_disk" {
  name             = "${local.resource_name_prefix}${var.quantity > 1 ? "-${count.index + 1}" : ""}-main-disk"
  base_volume_name = "${var.base_configuration["use_shared_resources"] ? "" : var.base_configuration["name_prefix"]}${var.image}"
  pool             = var.base_configuration["pool"]
  size             = 214748364800
  count            = var.quantity
}

resource "libvirt_volume" "data_disk" {
  name  = "${local.resource_name_prefix}${var.quantity > 1 ? "-${count.index + 1}" : ""}-data-disk"
  // needs to be converted to bytes
  size  = (var.additional_disk_size == null? 0: var.additional_disk_size) * 1024 * 1024 * 1024
  pool  = lookup(var.volume_provider_settings, "pool", var.base_configuration["pool"])
  count = var.additional_disk_size == null? 0 : var.additional_disk_size > 0 ? var.quantity : 0
}

resource "libvirt_cloudinit_disk" "cloudinit_disk" {
  name           = "${local.resource_name_prefix}${var.quantity > 1 ? "-${count.index + 1}" : ""}-cloudinit-disk"
  user_data      = data.template_file.user_data.rendered
  network_config = data.template_file.network_config.rendered
  pool             = var.base_configuration["pool"]
  count            = local.cloud_init ? var.quantity : 0
}

resource "libvirt_ignition" "ignition_disk" {
  name           = "${local.resource_name_prefix}${var.quantity > 1 ? "-${count.index + 1}" : ""}-ignition-disk"
  pool             = var.base_configuration["pool"]
  content          = data.template_file.ignition.rendered
  count            = local.ignition ? var.quantity : 0
}

resource "libvirt_domain" "domain" {
  name       = "${local.resource_name_prefix}${var.quantity > 1 ? "-${count.index + 1}" : ""}"
  memory     = local.provider_settings["memory"]
  vcpu       = local.provider_settings["vcpu"]
  running    = local.provider_settings["running"]
  count      = var.quantity
  qemu_agent = true

  // copy host CPU model to guest to get the vmx flag if present
  cpu = {
    mode = local.provider_settings["cpu_model"]
  }

  // base disk + additional disks if any
  dynamic "disk" {
    for_each = concat(
      length(libvirt_volume.main_disk) == var.quantity ? [{"volume_id" : libvirt_volume.main_disk[count.index].id}] : [],
      length(libvirt_volume.data_disk) == var.quantity ? [{"volume_id" : libvirt_volume.data_disk[count.index].id}] : []
    )
    content {
      volume_id = disk.value.volume_id
    }
  }

  cloudinit = length(libvirt_cloudinit_disk.cloudinit_disk) == var.quantity ? libvirt_cloudinit_disk.cloudinit_disk[count.index].id : null
  coreos_ignition = length(libvirt_ignition.ignition_disk) == var.quantity ? libvirt_ignition.ignition_disk[count.index].id : null

  dynamic "network_interface" {
    for_each = slice(
      [
        {
          "wait_for_lease" = true
          "network_name"   = var.base_configuration["network_name"]
          "network_id"     = null
          "bridge"         = var.base_configuration["bridge"]
          "mac"            = local.provider_settings["mac"]
        },
        {
          "wait_for_lease" = false
          "network_name"   = null
          "network_id"     = var.base_configuration["additional_network_id"]
          "bridge"         = null
          "mac"            = null
        },
      ],
      var.connect_to_base_network ? 0 : 1,
      var.base_configuration["additional_network"] != null && var.connect_to_additional_network ? 2 : 1,
    )
    content {
      wait_for_lease = network_interface.value.wait_for_lease
      network_id     = network_interface.value.network_id
      network_name   = network_interface.value.network_name
      bridge         = network_interface.value.bridge
      mac            = network_interface.value.mac
    }
  }

  console {
    type           = "pty"
    target_port    = "0"
    target_type    = "serial"
    source_host    = null
    source_service = null
  }

  console {
    type           = "pty"
    target_port    = "1"
    target_type    = "virtio"
    source_host    = null
    source_service = null
  }

  graphics {
    type        = "spice"
    listen_type = "address"
    listen_address = "0.0.0.0"
    autoport    = true
  }

  xml {
    xslt = local.provider_settings["xslt"]
  }
}

resource "null_resource" "provisioning" {
  depends_on = [libvirt_domain.domain]

  triggers = {
    main_volume_id = length(libvirt_volume.main_disk) == var.quantity ? libvirt_volume.main_disk[count.index].id : null
    domain_id      = length(libvirt_domain.domain) == var.quantity ? libvirt_domain.domain[count.index].id : null
    grains_subset = yamlencode(
      {
        domain                    = var.base_configuration["domain"]
        use_avahi                 = var.base_configuration["use_avahi"]
        timezone                  = var.base_configuration["timezone"]
        use_ntp                   = var.base_configuration["use_ntp"]
        testsuite                 = var.base_configuration["testsuite"]
        roles                     = var.roles
        use_os_released_updates   = var.use_os_released_updates
        install_salt_bundle       = var.install_salt_bundle
        additional_repos          = var.additional_repos
        additional_repos_only     = var.additional_repos_only
        additional_certs          = var.additional_certs
        additional_packages       = var.additional_packages
        swap_file_size            = var.swap_file_size
        authorized_keys           = var.ssh_key_path
        gpg_keys                  = var.gpg_keys
        ipv6                      = var.ipv6
    })
  }

  count = var.provision ? var.quantity : 0

  connection {
    host     = libvirt_domain.domain[count.index].network_interface[0].addresses[0]
    user     = "root"
    password = "linux"
  }

  provisioner "file" {
    source      = "salt"
    destination = "/root"
  }

  provisioner "file" {
    content = yamlencode(merge(
      {
        hostname                  = "${local.resource_name_prefix}${var.quantity > 1 ? "-${count.index + 1}" : ""}"
        domain                    = var.base_configuration["domain"]
        use_avahi                 = var.base_configuration["use_avahi"]
        additional_network        = var.base_configuration["additional_network"]
        timezone                  = var.base_configuration["timezone"]
        use_ntp                   = var.base_configuration["use_ntp"]
        testsuite                 = var.base_configuration["testsuite"]
        roles                     = var.roles
        use_os_released_updates   = var.use_os_released_updates
        install_salt_bundle       = var.install_salt_bundle
        additional_repos          = var.additional_repos
        additional_repos_only     = var.additional_repos_only
        additional_certs          = var.additional_certs
        additional_packages       = var.additional_packages
        swap_file_size            = var.swap_file_size
        authorized_keys = concat(
          var.base_configuration["ssh_key_path"] != null ? [trimspace(file(var.base_configuration["ssh_key_path"]))] : [],
          var.ssh_key_path != null ? [trimspace(file(var.ssh_key_path))] : [],
        )
        gpg_keys                      = var.gpg_keys
        connect_to_base_network       = var.connect_to_base_network
        connect_to_additional_network = var.connect_to_additional_network
        reset_ids                     = true
        ipv6                          = var.ipv6
        data_disk_device              = contains(var.roles, "server") || contains(var.roles, "proxy") || contains(var.roles, "mirror") || contains(var.roles, "jenkins") ? "vdb" : null
        provider                      = "libvirt"
      },
    var.grains))
    destination = "/tmp/grains"
  }

  provisioner "remote-exec" {
    inline = [
      "bash /root/salt/wait_for_salt.sh",
    ]
  }

  provisioner "remote-exec" {
    inline = [
      "bash /root/salt/first_deployment_highstate.sh",
    ]
  }

  provisioner "remote-exec" {
    inline = [
      "bash /root/salt/post_provisioning_cleanup.sh",
    ]
  }
}

output "configuration" {
  depends_on = [libvirt_domain.domain, null_resource.provisioning]
  value = {
    ids       = libvirt_domain.domain[*].id
    hostnames = [for value_used in libvirt_domain.domain : "${value_used.name}.${var.base_configuration["domain"]}"]
    macaddrs  = [for value_used in libvirt_domain.domain : value_used.network_interface[0].mac if length(value_used.network_interface) > 0]
    ipaddrs  = [for value_used in libvirt_domain.domain : value_used.network_interface[0].addresses if length(value_used.network_interface) > 0]
  }
}
