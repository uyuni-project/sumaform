terraform {
    required_version = "~> 0.11.7"
}

// Names are calculated as follows:
// ${var.base_configuration["name_prefix"]}${var.name}${var.count > 1 ? "-${count.index  + 1}" : ""}
// This means:
//   name_prefix + name (if count = 1)
//   name_prefix + name + "-" + index (if count > 1)

resource "libvirt_volume" "main_disk" {
  name = "${var.base_configuration["name_prefix"]}${var.name}${var.count > 1 ? "-${count.index  + 1}" : ""}-main-disk"
  base_volume_name = "${var.base_configuration["use_shared_resources"] ? "" : var.base_configuration["name_prefix"]}${var.image}"
  pool = "${var.base_configuration["pool"]}"
  count = "${var.count}"
}

resource "libvirt_domain" "domain" {
  name = "${var.base_configuration["name_prefix"]}${var.name}${var.count > 1 ? "-${count.index  + 1}" : ""}"
  memory = "${var.memory}"
  vcpu = "${var.vcpu}"
  running = "${var.running}"
  count = "${var.count}"
  qemu_agent = true

  // copy host CPU model to guest to get the vmx flag if present
  cpu {
    mode = "${var.cpu_model != "" ? "${var.cpu_model}" : "custom"}"
  }

  // base disk + additional disks if any
  disk = ["${concat(
    list(
      map("volume_id", "${element(libvirt_volume.main_disk.*.id, count.index)}")
    ),
    var.additional_disk
  )}"]

  network_interface = ["${slice(
    list(
      map("wait_for_lease", true,
          "network_name", var.base_configuration["network_name"],
          "bridge", var.base_configuration["bridge"],
          "mac", var.mac
         ),
      map("wait_for_lease", false,
          "network_id", var.base_configuration["additional_network_id"]
         )
    ),
    var.connect_to_base_network ? 0 : 1,
    ((var.base_configuration["additional_network"] != "") && var.connect_to_additional_network) ? 2 : 1
  )}"]

  connection {
    user = "root"
    password = "linux"
  }

  console {
    type        = "pty"
    target_port = "0"
    target_type = "serial"
  }

  console {
      type        = "pty"
      target_type = "virtio"
      target_port = "1"
  }

  graphics {
    type = "spice"
    listen_type = "address"
    autoport = true
  }

  provisioner "file" {
    source = "salt"
    destination = "/root"
  }

  provisioner "file" {
    content = <<EOF

hostname: ${var.base_configuration["name_prefix"]}${var.name}${var.count > 1 ? "-${count.index  + 1}" : ""}
domain: ${var.base_configuration["domain"]}
use_avahi: ${var.base_configuration["use_avahi"]}
additional_network: ${var.base_configuration["additional_network"]}
timezone: ${var.base_configuration["timezone"]}
testsuite: ${var.base_configuration["testsuite"]}
use_os_released_updates: ${var.use_os_released_updates}
use_os_unreleased_updates: ${var.use_os_unreleased_updates}
additional_repos: {${join(", ", formatlist("'%s': '%s'", keys(var.additional_repos), values(var.additional_repos)))}}
additional_packages: [${join(", ", formatlist("'%s'", var.additional_packages))}]
swap_file_size: ${var.swap_file_size}
authorized_keys: [${trimspace(file(var.base_configuration["ssh_key_path"]))},${trimspace(file(var.ssh_key_path))}]
gpg_keys: [${join(", ", formatlist("'%s'", var.gpg_keys))}]
connect_to_base_network: ${var.connect_to_base_network}
connect_to_additional_network: ${var.connect_to_additional_network}
reset_ids: true
ipv6: {${join(", ", formatlist("'%s': '%s'", keys(var.ipv6), values(var.ipv6)))}}
saltapi_tcpdump: ${var.saltapi_tcpdump}
${var.grains}

EOF

    destination = "/etc/salt/grains"
  }

  provisioner "remote-exec" {
    inline = [
      "sh /root/salt/first_deployment_highstate.sh"
    ]
  }
}

output "configuration" {
  value {
    id = "${libvirt_domain.domain.0.id}"
    hostname = "${var.base_configuration["name_prefix"]}${var.name}${var.count > 1 ? "-1" : ""}.${var.base_configuration["domain"]}"
  }
}
