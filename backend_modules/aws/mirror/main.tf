/*
  This module sets up a mirror host that also acts as a bastion in the
  public subnet.

  To render it usable you need to either specify a data disk snapshot that
  contains packages or to upload them from a libvirt mirror with the
  following commands:

  scp key.pem root@mirror.tf.local://root/key.pem
  ssh root@mirror.tf.local
  zypper in rsync
  rsync -av0 --delete -e 'ssh -i key.pem' /srv/mirror/ root@<PUBLIC DNS NAME>://srv/mirror/

  Once the disk is populated you should take a snapshot of the data volume and add
  "<PREFIX>-mirror-data-volume-snapshot" as the Name tag, then you can remove
  the data_volume_snapshot_id line in main.tf and this module will automatically
  look up the ID in subsequent runs of `terraform apply`.
*/

terraform {
    required_version = "~> 0.12.9"
}

resource "aws_instance" "instance" {
  ami = "${var.ami}"
  availability_zone = "${var.availability_zone}"
  instance_type = "t2.small"
  key_name = "${var.key_name}"
  monitoring = "${var.monitoring}"
  subnet_id = "${var.public_subnet_id}"
  vpc_security_group_ids = ["${var.public_security_group_id}"]

  tags {
    Name = "${var.name_prefix}-mirror"
  }
}

resource "aws_ebs_volume" "data_disk" {
    availability_zone = "${var.availability_zone}"
    size = 500 # GiB
    type = "sc1"
    snapshot_id = "${var.data_volume_snapshot_id}"
    tags {
      Name = "${var.name_prefix}-mirror-data-volume"
    }
}

resource "aws_volume_attachment" "data_disk_attachment" {
  device_name = "/dev/xvdf"
  volume_id = "${aws_ebs_volume.data_disk.id}"
  instance_id = "${aws_instance.instance.id}"
}

resource "null_resource" "mirror_salt_configuration" {
  triggers {
    instance_id = "${aws_instance.instance.id}"
  }

  connection {
    host = "${aws_instance.instance.public_dns}"
    private_key = "${file(var.key_file)}"
  }

  provisioner "file" {
    source = "salt"
    destination = "/root"
  }

  provisioner "file" {
    content = <<EOF

hostname: ${replace("${aws_instance.instance.private_dns}", ".${var.region == "us-east-1" ? "ec2.internal" : "${var.region}.compute.internal"}", "")}
domain: ${var.region == "us-east-1" ? "ec2.internal" : "${var.region}.compute.internal"}
use_avahi: False
roles: [mirror]
cc_username: ${var.cc_username}
cc_password: ${var.cc_password}
data_disk_device: xvdf
timezone: ${var.timezone}
authorized_keys: null
additional_repos: {${join(", ", formatlist("'%s': '%s'", keys(var.additional_repos), values(var.additional_repos)))}}
additional_packages: [${join(", ", formatlist("'%s'", var.additional_packages))}]
reset_ids: true
ubuntu_distros: [${join(", ", formatlist("'%s'", var.ubuntu_distros))}]

EOF

    destination = "/etc/salt/grains"
  }

  provisioner "remote-exec" {
    inline = [
      "sh /root/salt/first_deployment_highstate.sh"
    ]
  }
}

output "public_name" {
  value = "${aws_instance.instance.public_dns}"
}

output "private_name" {
  value = "${aws_instance.instance.private_dns}"
}
