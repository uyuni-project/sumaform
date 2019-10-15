// Names are calculated as follows:
// ${var.base_configuration["name_prefix"]}${var.name}${var.quantity > 1 ? "-${count.index  + 1}" : ""}
// This means:
//   name_prefix + name (if quantity = 1)
//   name_prefix + name + "-" + index (if quantity > 1)

resource "libvirt_volume" "main_disk" {
  name             = "${var.base_configuration["name_prefix"]}${var.name}${var.quantity > 1 ? "-${count.index + 1}" : ""}-main-disk"
  base_volume_name = "${var.base_configuration["use_shared_resources"] ? "" : var.base_configuration["name_prefix"]}${var.image}"
  pool             = var.base_configuration["pool"]
  count            = var.quantity
}

resource "libvirt_domain" "domain" {
  name       = "${var.base_configuration["name_prefix"]}${var.name}${var.quantity > 1 ? "-${count.index + 1}" : ""}"
  memory     = var.memory
  vcpu       = var.vcpu
  running    = var.running
  count      = var.quantity
  qemu_agent = true

  // base disk + additional disks if any
  dynamic "disk" {
    for_each = concat(
      [
        {
          "volume_id" = element(libvirt_volume.main_disk.*.id, count.index)
        },
      ],
      var.additional_disk,
    )
    content {
      volume_id = disk.value["volume_id"]
    }
  }

  dynamic "network_interface" {
    for_each = [
      {
        "wait_for_lease" = false
        "network_id"     = var.base_configuration["additional_network_id"]
      },
    ]
    content {
      wait_for_lease = network_interface.value["wait_for_lease"]
      network_id     = network_interface.value["network_id"]
    }
  }

  xml {
    xslt = file("${path.module}/pxe.xsl")
  }
}

output "configuration" {
  value = {
    id       = libvirt_domain.domain[0].id
    hostname = "${var.base_configuration["name_prefix"]}${var.name}${var.quantity > 1 ? "-1" : ""}.${var.base_configuration["domain"]}"
    macaddr  = libvirt_domain.domain[0].network_interface[0].mac
  }
}
