module "postgres" {
  source = "../host"

  base_configuration = "${var.base_configuration}"
  name = "${var.name}"
  additional_repos = "${var.additional_repos}"
  additional_packages = "${var.additional_packages}"
  ssh_key_path = "${var.ssh_key_path}"
  grains = <<EOF

mirror: ${var.base_configuration["mirror"]}
role: postgres
for_development_only: True

EOF

  // Provider-specific variables
  image = "sles12sp1"
  flavor = "${var.flavor}"
  root_volume_size = "${var.root_volume_size}"
}

output "configuration" {
  value = "${module.postgres.configuration}"
}
