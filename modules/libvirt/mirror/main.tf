resource "libvirt_volume" "data_disk" {
  name = "${var.base_configuration["name_prefix"]}mirror-data-disk"
  size = 1099511627776 # 1 TiB
  pool = "${var.data_pool}"
  lifecycle {
    prevent_destroy = true
  }
}

module "mirror" {
  source = "../host"
  base_configuration = "${var.base_configuration}"
  name = "mirror"
  image = "opensuse422"
  memory = 512
  vcpu = 1
  running = "${var.running}"
  mac = "${var.mac}"
  additional_repos = "${var.additional_repos}"
  additional_packages = "${var.additional_packages}"

  additional_disk = [{
    volume_id = "${libvirt_volume.data_disk.id}"
  }]

  ssh_key_path = "${var.ssh_key_path}"
  grains = <<EOF

role: mirror
cc_username: ${var.base_configuration["cc_username"]}
cc_password: ${var.base_configuration["cc_password"]}
data_disk_device: vdb

EOF
}
