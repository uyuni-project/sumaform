// Names are calculated as follows:
// ${var.base_configuration["name_prefix"]}${var.name}${element(list("", "-${count.index  + 1}"), signum(var.count - 1))}
// This means:
//   name_prefix + name (if count = 1)
//   name_prefix + name + "-" + index (if count > 1)

resource "libvirt_volume" "main_disk" {
  name = "${var.base_configuration["name_prefix"]}${var.name}${element(list("", "-${count.index  + 1}"), signum(var.count - 1))}-main-disk"
  base_volume_name = "${var.base_configuration["name_prefix"]}${var.image}"
  pool = "${var.base_configuration["pool"]}"
  count = "${var.count}"
}

resource "libvirt_domain" "domain" {
  name = "${var.base_configuration["name_prefix"]}${var.name}${element(list("", "-${count.index  + 1}"), signum(var.count - 1))}"
  memory = "${var.memory}"
  vcpu = "${var.vcpu}"
  running = "${var.running}"
  count = "${var.count}"

  // base disk + additional disks if any
  disk = ["${concat(
    list(
      map("volume_id", "${element(libvirt_volume.main_disk.*.id, count.index)}")
    ),
    var.additional_disk
  )}"]

  network_interface {
    wait_for_lease = true
    network_name = "${var.base_configuration["network_name"]}"
    bridge = "${var.base_configuration["bridge"]}"
    mac = "${var.mac}"
  }

  connection {
    user = "root"
    password = "linux"
  }

  provisioner "file" {
    source = "salt"
    destination = "/srv"
  }

  provisioner "file" {
    content = <<EOF

hostname: ${var.base_configuration["name_prefix"]}${var.name}${element(list("", "-${count.index  + 1}"), signum(var.count - 1))}
domain: ${var.base_configuration["domain"]}
use-avahi: ${var.base_configuration["use_avahi"]}
${length(var.extra_repos) > 0 ? "extra_repos:" : ""}
${length(var.extra_repos) > 0 ? join("\n", formatlist("  %s: %s", keys(var.extra_repos), values(var.extra_repos))) : ""}
${length(var.extra_pkgs) > 0 ? "extra_pkgs:" : ""}
${length(var.extra_pkgs) > 0 ? join("\n", formatlist("  - %s", var.extra_pkgs)) : ""}
${var.grains}

EOF

    destination = "/etc/salt/grains"
  }

  provisioner "remote-exec" {
    inline = [
      "test -e /etc/fstab || touch /etc/fstab",
      "salt-call --force-color --local --output=quiet state.sls default,terraform-resource",
      "salt-call --force-color --local state.highstate"
    ]
  }
}

output "configuration" {
  // HACK: work around https://github.com/hashicorp/terraform/issues/9549
  value = "${
    map(
      "id", "${libvirt_domain.domain.0.id}",
      "hostname", "${var.base_configuration["name_prefix"]}${var.name}${element(list("", "-1"), signum(var.count - 1))}.${var.base_configuration["domain"]}"
    )
  }"
}
