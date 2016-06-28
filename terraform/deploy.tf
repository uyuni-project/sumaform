variable "count" {
  default = 2
}
resource "openstack_compute_instance_v2" "web" {
  count = "${var.count}"
  name = "${format("web-%02d", count.index+1)}"
  image_name = "test-sumaform-sp11"
  flavor_id = "2"
  security_groups = ["default"]
  network {
     uuid = "8cce38fd-443f-4b87-8ea5-ad2dc184064f"
  }
}
