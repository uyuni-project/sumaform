/*
  This module sets up package-mirror host that also acts as a bastion in the
  public subnet.
  
  To render it usable you need to either specify a data disk snapshot that
  contains packages or to upload them from a libvirt package-mirror with the
  following command:

  rsync -av0 -e 'ssh -i <SSH KEY>.pem' /srv/mirror root@<PUBLIC DNS NAME>://srv/mirror
*/

resource "aws_instance" "instance" {
  ami = "${var.ami}"
  availability_zone = "${var.availability_zone}"
  instance_type = "t2.nano"
  key_name = "${var.key_name}"
  monitoring = false
  subnet_id = "${var.public_subnet_id}"
  vpc_security_group_ids = ["${var.public_security_group_id}"]

  tags {
    Name = "${var.name_prefix}-package-mirror"
  }
}

resource "aws_ebs_volume" "data_disk" {
    availability_zone = "${var.availability_zone}"
    size = 500 # GiB
    type = "sc1"
    snapshot_id = "${var.data_volume_snapshot_id}"
    tags {
      Name = "${var.name_prefix}-package-mirror-data-volume"
    }
}

resource "aws_volume_attachment" "data_disk_attachment" {
  device_name = "/dev/xvdf"
  volume_id = "${aws_ebs_volume.data_disk.id}"
  instance_id = "${aws_instance.instance.id}"
}

resource "null_resource" "package_mirror_salt_configuration" {
  triggers {
    instance_id = "${aws_instance.instance.id}"
  }

  connection {
    host = "${aws_instance.instance.public_dns}"
    private_key = "${var.key_file}"
  }
  
  provisioner "file" {
    source = "salt"
    destination = "/srv/salt"
  }

  provisioner "file" {
    content = <<EOF

hostname: ${replace("${aws_instance.instance.private_dns}", ".${var.region}.compute.internal", "")}
domain: ${var.region}.compute.internal
use-avahi: False
role: package-mirror
data_disk_device: xvdf

EOF

    destination = "/etc/salt/grains"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo salt-call --local state.sls terraform-resource",
      "sudo salt-call --local state.highstate"
    ]
  }
}

output "public_name" {
  value = "${aws_instance.instance.public_dns}"
}

output "private_name" {
  value = "${aws_instance.instance.private_dns}"
}
