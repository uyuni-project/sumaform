module "images" {
  source = "./libvirt_images"
}

module "suma21pg" {
  source = "./libvirt_host"
  name = "suma21pg"
  image = "${module.images.sles11sp3}"
  version = "2.1-nightly"
  database = "postgres"
  role = "suse-manager-server"
  memory = 1024
  vcpu = 2
}
