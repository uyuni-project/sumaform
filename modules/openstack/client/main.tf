module "client" {
  source = "../host"

  base_configuration = "${var.base_configuration}"
  name = "${var.name}"
  count = "${var.count}"
  additional_repos = "${var.additional_repos}"
  additional_packages = "${var.additional_packages}"
  gpg_keys = "${var.gpg_keys}"
  ssh_key_path = "${var.ssh_key_path}"
  grains = <<EOF

version: ${var.version}
mirror: ${var.base_configuration["mirror"]}
server: ${var.server_configuration["hostname"]}
role: client
for_development_only: ${var.for_development_only}
testsuite: ${var.base_configuration["testsuite"]}
use_unreleased_updates: ${var.use_unreleased_updates}

EOF

  // Provider-specific variables
  image = "${var.image}"
  flavor = "${var.flavor}"
  root_volume_size = "${var.root_volume_size}"
  floating_ips = "${var.floating_ips}"
}

output "configuration" {
  value = "${module.client.configuration}"
}
