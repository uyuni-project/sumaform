module "suma_openstack" {
  source = "./openstack_host"
  name = "suma21pg"
  image = "test-sumaform-sp11"
  version = "2.1-nightly"
  database = "postgres"
  role = "suse-manager-server"
}
