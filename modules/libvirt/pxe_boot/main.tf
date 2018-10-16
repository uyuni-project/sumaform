module "pxe_boot" {
  source = "../unprovisioned"

  base_configuration = "${var.base_configuration}"
  name = "${var.name}"
  count = "${var.count}"
  connect_to_base_network = false
  connect_to_additional_network = true

  // Provider-specific variables
  image = "${var.image}"
  memory = "${var.memory}"
  vcpu = "${var.vcpu}"
  running = "${var.running}"
  mac = "${var.mac}"
  pxe = true
}

output "configuration" {
  value = "${module.pxe_boot.configuration}"
}
