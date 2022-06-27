locals {
  resource_name_prefix = "${var.base_configuration["name_prefix"]}${var.name}"
  provider_settings = merge({
    memory          = 1024
    vcpu            = 1
    running         = true
    mac             = null
    cpu_model       = "custom"
    },
    contains(var.roles, "server") ? { memory = 4096, vcpu = 2 } : {},
    contains(var.roles, "server") && lookup(var.base_configuration, "testsuite", false) ? { memory = 8192, vcpu = 4 } : {},
    contains(var.roles, "proxy") && lookup(var.base_configuration, "testsuite", false) ? { memory = 2048, vcpu = 2 } : {},
    contains(var.roles, "pxe_boot")? { memory = 2048} : {},
    contains(var.roles, "mirror") ? { memory = 1024 } : {},
    contains(var.roles, "build_host") ? { vcpu = 2 } : {},
    contains(var.roles, "controller") ? { memory = 2048 } : {},
    contains(var.roles, "grafana") ? { memory = 4096 } : {},
    contains(var.roles, "virthost") ? { memory = 3072, vcpu = 3 } : {},
    contains(var.roles, "jenkins") ? { memory = 16384, vcpu = 4 } : {},
    var.provider_settings,
    contains(var.roles, "virthost") ? { cpu_model = "host-passthrough" } : {},
  )
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

resource "harvester_volume" "main_disk" {
  name  = "${local.resource_name_prefix}${var.quantity > 1 ? "-${count.index + 1}" : ""}-main-disk"
  image = "${var.base_configuration["use_shared_resources"] ? "" : var.base_configuration["name_prefix"]}${var.image}"
  size  = 214748364800
  count = var.quantity
}

resource "harvester_volume" "data_disk" {
  name  = "${local.resource_name_prefix}${var.quantity > 1 ? "-${count.index + 1}" : ""}-data-disk"
  // needs to be converted to bytes
  size  = (var.additional_disk_size == null ? 0: var.additional_disk_size) * 1024 * 1024 * 1024
  count = var.additional_disk_size == null ? 0 : var.additional_disk_size > 0 ? var.quantity : 0
}

# resource "libvirt_ignition" "ignition_disk" {
#   name           = "${local.resource_name_prefix}${var.quantity > 1 ? "-${count.index + 1}" : ""}-ignition-disk"
#   pool             = var.base_configuration["pool"]
#   content          = data.template_file.ignition.rendered
#   count            = local.ignition ? var.quantity : 0
# }

resource "harvester_virtualmachine" "domain" {
  name         = "${local.resource_name_prefix}${var.quantity > 1 ? "-${count.index + 1}" : ""}"
  memory       = local.provider_settings["memory"]
  cpu          = local.provider_settings["vcpu"]
  run_strategy = local.provider_settings["running"] ? "Always" : "Halted"
  count        = var.quantity

    // base disk + additional disks if any
  dynamic "disk" {
    for_each = concat(
      length(harvester_volume.main_disk) == var.quantity ? [{"volume_name" : harvester_volume.main_disk[count.index].name}] : [],
      length(harvester_volume.data_disk) == var.quantity ? [{"volume_name" : harvester_volume.data_disk[count.index].name}] : []
    )
    content {
      name = disk.value.volume_name
      existing_volume_name = disk.value.volume_name
    }
  }

  cloudinit {
    user_data = data.template_file.user_data.rendered
    network_data = data.template_file.network_config.rendered
  }


  # coreos_ignition = length(libvirt_ignition.ignition_disk) == var.quantity ? libvirt_ignition.ignition_disk[count.index].id : null

  dynamic "network_interface" {
    for_each = slice(
      [
        {
          "network_name" = var.base_configuration["network_name"]
          "mac"          = local.provider_settings["mac"]
          "name"         = "base"
        },
        {
          "network_name" = var.base_configuration["additional_network_name"]
          "mac"          = null
          "name"         = "additional"
        },
      ],
      var.connect_to_base_network ? 0 : 1,
      var.base_configuration["additional_network"] != null && var.connect_to_additional_network ? 2 : 1,
    )
    content {
      name   = network_interface.value.name
      network_name = network_interface.value.network_name
      mac_address    = network_interface.value.mac
    }
  }

  # console {
  #   type           = "pty"
  #   target_port    = "0"
  #   target_type    = "serial"
  #   source_host    = null
  #   source_service = null
  # }

  # console {
  #   type           = "pty"
  #   target_port    = "1"
  #   target_type    = "virtio"
  #   source_host    = null
  #   source_service = null
  # }

  # graphics {
  #   type        = "spice"
  #   listen_type = "address"
  #   listen_address = "0.0.0.0"
  #   autoport    = true
  # }
}

resource "null_resource" "provisioning" {
  depends_on = [harvester_virtualmachine.domain]

  triggers = {
    main_volume_id = length(harvester_volume.main_disk) == var.quantity ? harvester_volume.main_disk[count.index].id : null
    domain_id      = length(harvester_virtualmachine.domain) == var.quantity ? harvester_virtualmachine.domain[count.index].id : null
    grains_subset = yamlencode(
      {
        domain                    = var.base_configuration["domain"]
        use_avahi                 = var.base_configuration["use_avahi"]
        timezone                  = var.base_configuration["timezone"]
        use_ntp                   = var.base_configuration["use_ntp"]
        testsuite                 = var.base_configuration["testsuite"]
        roles                     = var.roles
        use_os_released_updates   = var.use_os_released_updates
        use_os_unreleased_updates = var.use_os_unreleased_updates
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
    host     = harvester_virtualmachine.domain[count.index].network_interface[0].ip_address
    user     = "root"
    password = "linux"
  }

  provisioner "file" {
    source      = "salt"
    destination = "/root"
  }

  provisioner "remote-exec" {
    inline = local.cloud_init ? [
      "bash /root/salt/wait_for_salt.sh",
    ] : ["bash -c \"echo 'no cloud init, nothing to do'\""]
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
        use_os_unreleased_updates = var.use_os_unreleased_updates
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
        provider                      = "harvester"
      },
    var.grains))
    destination = "/etc/salt/grains"
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
  depends_on = [harvester_virtualmachine.domain, null_resource.provisioning]
  value = {
    ids       = harvester_virtualmachine.domain[*].id
    hostnames = [for value_used in harvester_virtualmachine.domain : "${value_used.name}.${var.base_configuration["domain"]}"]
    macaddrs  = [for value_used in harvester_virtualmachine.domain : value_used.network_interface[0].mac_address if length(value_used.network_interface) > 0]
    ipaddrs  = [for value_used in harvester_virtualmachine.domain : value_used.network_interface[0].ip_address if length(value_used.network_interface) > 0]
  }
}
