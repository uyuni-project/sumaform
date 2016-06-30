module "images" {
  source = "./libvirt_images"
}

module "package_mirror" {
  source = "./libvirt_package_mirror"
  image = "${module.images.sles12sp1}"
  libvirt_data_pool = "data"
}

module "suma21pg" {
  source = "./libvirt_host"
  name = "suma21pg"
  image = "${module.images.sles11sp3}"
  version = "2.1-nightly"
  database = "postgres"
  role = "suse-manager-server"
  package-mirror = "${module.package_mirror.hostname}"
}

module "clisles12" {
  source = "./libvirt_host"
  name = "clisles12"
  image = "${module.images.sles12}"
  role = "client"
  package-mirror = "${module.package_mirror.hostname}"
  server = "${module.suma21pg.hostname}"
}

/*module "suma_openstack" {
  source = "./openstack_host"
  name = "suma21pg"
  image = "sumaform-sles11sp3"
  version = "2.1-nightly"
  database = "postgres"
  role = "suse-manager-server"
}*/
