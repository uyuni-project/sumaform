module "mirror" {
  source = "../host"

  base_configuration = "${var.base_configuration}"
  name = "mirror"
  additional_repos = "${var.additional_repos}"
  additional_packages = "${var.additional_packages}"
  ssh_key_path = "${var.ssh_key_path}"
  grains = <<EOF

role: mirror
cc_username: ${var.base_configuration["cc_username"]}
cc_password: ${var.base_configuration["cc_password"]}
data_disk_device: vda

EOF

  // Provider-specific variables
  image = "opensuse423"
  flavor = "m1.small"
  floating_ips = "${var.floating_ips}"
  extra_volume_size = 500
}
