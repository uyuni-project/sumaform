provider "openstack" {
  version = "~> 1.2"
  auth_url  = "${var.openstack_auth_url}"
  user_name = "${var.openstack_user}"
  password = "${var.openstack_password}"
  domain_name = "${var.openstack_domain_name}"
  tenant_id = "${var.openstack_tenant_id}"
  tenant_name = "${var.openstack_tenant_name}"
}
