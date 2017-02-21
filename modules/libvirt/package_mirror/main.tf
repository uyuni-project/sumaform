resource "libvirt_volume" "data_disk" {
  name = "${var.base_configuration["name_prefix"]}terraform_package_mirror_data_disk"
  size = 1099511627776 # 1 TiB
  pool = "${var.data_pool}"
  lifecycle {
    prevent_destroy = true
  }
}

module "package_mirror" {
  source = "../host"
  base_configuration = "${var.base_configuration}"
  name = "package-mirror"
  image = "opensuse422"
  memory = 512
  vcpu = 1
  running = "${var.running}"
  mac = "${var.mac}"
  extra_repos = "${var.extra_repos}"

  additional_disk {
    volume_id = "${libvirt_volume.data_disk.id}"
  }

  grains = <<EOF

role: package-mirror
cc_username: ${var.base_configuration["cc_username"]}
cc_password: ${var.base_configuration["cc_password"]}
data_disk_device: vdb

EOF
}
