module "dhcp_dns" {
  source = "../host"

  base_configuration            = var.base_configuration
  name                          = var.name
  quantity                      = var.base_configuration["additional_network"] != null ? var.quantity : 0

  connect_to_base_network       = false
  connect_to_additional_network = true
  roles                         = ["dhcp_dns"]
  provision                     = false

  image                         = var.image
}

# The DHCP and DNS server has no direct connection to the outside, so we must download the packages on its behalf
locals {
  add_net              = var.base_configuration["additional_network"] != null ? slice(split(".", var.base_configuration["additional_network"]), 0, 3) : []
  prefix               = join(".", local.add_net)
  reverse_prefix       = join(".", reverse(local.add_net))
  zypper               = "/usr/bin/zypper --non-interactive --gpg-auto-import-keys"
  repo                 = "http://${var.base_configuration["mirror"] != null ? var.base_configuration["mirror"] : "download.opensuse.org"}/distribution/leap/16.0/repo/oss"
}

resource "terraform_data" "standalone_provisioning" {

  count = var.base_configuration["additional_network"] != null ? var.quantity : 0

  connection {
    host                = "${local.prefix}.53"
    user                = "root"
    password            = "linux"
    timeout             = "6m"
    bastion_host        = var.hypervisor != null ? var.hypervisor.host : null
    bastion_user        = var.hypervisor != null ? var.hypervisor.user : null
    bastion_private_key = var.hypervisor != null ? var.hypervisor.private_key : null
  }

  provisioner "local-exec" {
    command = <<EOT
mkdir -p /tmp/dhcp-dns/var/cache/zypp/packages/repo
${local.zypper} --root /tmp/dhcp-dns addrepo ${local.repo} offline_repo ||:
${local.zypper} --root /tmp/dhcp-dns install --download-only kea bind
EOT
  }

  provisioner "file" {
    source      = "/tmp/dhcp-dns/var/cache/zypp/packages/offline_repo"
    destination = "/root"
  }

  provisioner "remote-exec" {
    inline = [
      "echo ${var.name} > /etc/hostname",
      "hostname ${var.name}",
      "echo 'nameserver 127.0.0.1' > /etc/resolv.conf",
      "echo 'search example.org' >> /etc/resolv.conf",
      "${local.zypper} addrepo dir:/root/offline_repo offline_repo ||:",
      "${local.zypper} install --allow-downgrade kea bind",
      "sed -i 's!DHCPD_INTERFACE=\"\"!DHCPD_INTERFACE=\"eth0\"!' /etc/sysconfig/dhcpd",
      "sed -i 's!# include \"/etc/named.conf.include\";!include \"/etc/named.conf.include\";!' /etc/named.conf",
    ]
  }

  provisioner "file" {
    content     = <<EOT
{
  "Dhcp4": {
    "interfaces-config": {
      "interfaces": [ "*" ]
    },
    "lease-database": {
      "type": "memfile",
      "persist": true
    },
    "option-data": [
      {
        "name": "domain-name",
        "data": "example.org"
      },
      {
        "name": "domain-name-servers",
        "data": "${local.prefix}.53"
      }
    ],
    "subnet4": [
      {
        "id": 1,
        "subnet": "${local.prefix}.0/24",
        "pools": [
          {
            "pool": "${local.prefix}.128 - ${local.prefix}.253"
          }
        ],
        "option-data": [
          {
            "name": "boot-file-name",
            "data": "pxelinux.0"
          }
        ],
        "next-server": "${local.prefix}.254",
        "reservations": [
${join(",\n", [ for host in var.private_hosts:
          jsonencode({
            "hw-address" = host["private_mac"],
            "ip-address" = "${local.prefix}.${host["private_ip"]}",
            "hostname"   = host["private_name"]
          })
])}
        ]
      }
    ]
  }
}
EOT
    destination = "/etc/kea/kea-dhcp4.conf"
  }

  provisioner "file" {
    content = <<EOT
zone "${local.reverse_prefix}.in-addr.arpa" {
  type master;
  file "/var/lib/named/master/db.${local.reverse_prefix}.in-addr.arpa";

  notify no;
};

zone "example.org" {
  type master;
  file "/var/lib/named/master/db.example.org";

  notify no;
};
EOT
    destination = "/etc/named.conf.include"
  }

  provisioner "file"  {
    content = <<EOT
$ORIGIN ${local.reverse_prefix}.in-addr.arpa.

@        IN SOA dhcp-dns.example.org. admin.example.org. (2045010101 8600 900 86000 500)
@        IN NS  dhcp-dns.example.org.
dhcp-dns.example.org. IN A   ${local.prefix}.53

53       IN PTR dhcp-dns.example.org.
${join("\n", [ for host in var.private_hosts:
                 format("%-8d IN PTR %s.example.org.\n",
                        host["private_ip"],
                        host["private_name"])
             ])}
EOT
    destination = "/var/lib/named/master/db.${local.reverse_prefix}.in-addr.arpa"
  }

  provisioner "file"  {
    content = <<EOT
$ORIGIN example.org.

@        IN SOA dhcp-dns admin.example.org. (2045010101 8600 900 86000 500)
@        IN NS  dhcp-dns
dhcp-dns IN A   ${local.prefix}.53

${join("\n", [ for host in var.private_hosts:
                 format("%-8s IN A   %s.%d\n",
                        host["private_name"],
                        local.prefix,
                        host["private_ip"])
             ])}
EOT
    destination = "/var/lib/named/master/db.example.org"
  }

  provisioner "remote-exec" {
    inline = [
      "systemctl enable --now kea-dhcp4",
      "systemctl enable --now named",
    ]
  }
}
