variable "count" {
  default = 2
}

  count = "${var.count}"
  name = "${format("web-%02d", count.index+1)}"
resource "openstack_compute_instance_v2" "sumaform-test" {
  name = "sumaform-test"
  image_name = "test-sumaform-sp11"
  flavor_id = "2"
  security_groups = ["default"]
  network {
     uuid = "8cce38fd-443f-4b87-8ea5-ad2dc184064f"
  }

  provisioner "file" {
    source = "salt"
    destination = "/root"
  }

  provisioner "remote-exec" {
    inline = [
      "echo \"${template_file.grains.rendered}\" >> /etc/salt/grains",
      "salt-call --force-color --file-root /root/salt --local state.sls terraform-support",
      "salt-call --force-color --file-root /root/salt --local state.highstate"
    ]
  }
}

resource "template_file" "grains" {
  template = "${file("grains")}"

  vars {
    hostname = "suma21pg"
    avahi-domain = "${var.avahi-domain}"
    version = "2.1-nightly"
    database = "postgres"
    role = "suse-manager-server"
  }
}
