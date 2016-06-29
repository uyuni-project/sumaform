variable "count" {
  default = 2
}

resource "openstack_compute_floatingip_v2" "floatip_1" {
  region = ""
  pool = "floating"
}
resource "openstack_compute_instance_v2" "sumaform-test" {
  name = "sumaform-test"
  image_name = "test-sumaform-sp11"
  flavor_name = "m1.xlarge"
  security_groups = ["default"]
  region = ""
  network {
     uuid = "8cce38fd-443f-4b87-8ea5-ad2dc184064f"
  }

  network {
    name = "my_second_network"
    floating_ip = "${openstack_compute_floatingip_v2.floatip_1.address}"
    # Terraform will use this network for provisioning
    access_network = true
  }
  connection {
    user = "root"
    password = "vagrant"
    #host = "${openstack_compute_instance_v2.sumaform-test.network.0.floating_ip}"
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
