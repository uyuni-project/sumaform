provider "openstack" {
  tenant_name = "${var.openstack_tenant_name}"
  auth_url  = "${var.openstack_auth_url}"
  insecure = "true"
}
