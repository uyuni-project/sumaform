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
    (var.base_configuration["additional_network"] && var.connect_to_additional_network) ? 2 : 1
  )}"]

  xml {
    xslt = "${file(
      var.pxe ?
      "${path.module}/pxe.xsl" :
      "${path.module}/noop.xsl")}"
  }
}

output "configuration" {
  value {
    id = "${libvirt_domain.domain.0.id}"
    hostname = "${var.base_configuration["name_prefix"]}${var.name}${var.count > 1 ? "-1" : ""}.${var.base_configuration["domain"]}"
    macaddr = "${libvirt_domain.domain.0.network_interface.0.mac}"
  }
}
