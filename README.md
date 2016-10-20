# sumaform

![Sumicform, a green hedgehog made of bricks, sumaform's mascot](help/sumicform.png)

`sumaform` is a way to quickly configure test SUSE Manager setups with clients and servers.

It got its [portmanteau](https://en.wikipedia.org/wiki/Portmanteau) name being the successor of [suminator](https://github.com/SUSE/suminator/) implemented as [Terraform](https://www.terraform.io/) modules.

## Installation

OpenSUSE Leap 42.1:
```
sudo zypper addrepo http://download.opensuse.org/repositories/home:/SilvioMoioli:/tools/openSUSE_Leap_42.1/home:SilvioMoioli:tools.repo
sudo zypper install terraform-provider-libvirt
git clone https://github.com/moio/sumaform.git
```

SUSE Linux Enterprise 12 SP1:
```
sudo zypper addrepo http://download.opensuse.org/repositories/home:/SilvioMoioli:/tools/SLE_12_SP1/home:SilvioMoioli:tools.repo
sudo zypper install terraform-provider-libvirt
git clone https://github.com/moio/sumaform.git
```

Ubuntu and Debian:
```
sudo apt install alien
wget http://download.opensuse.org/repositories/home:/SilvioMoioli:/tools/SLE_12_SP1/x86_64/terraform.rpm
sudo alien -i terraform.rpm
wget http://download.opensuse.org/repositories/home:/SilvioMoioli:/tools/SLE_12_SP1/x86_64/terraform-provider-libvirt.rpm
sudo alien -i terraform-provider-libvirt.rpm
git clone https://github.com/moio/sumaform.git
```

You will need to edit HCL ([HashiCorp Configuration Language](https://github.com/hashicorp/hcl)) files. Syntax highlighting is available in major text editors like [atom](https://atom.io/packages/language-hcl).

## Backend choice

`sumaform` can deploy virtual machines to:
 - single libvirt hosts
 - OpenStack private clouds
 - Amazon Web Services

The simplest, recommended setup is to use libvirt on your local host. That needs at least 8 GB of RAM in your machine.

If you need a lot of VMs or lack hardware you probably want to use libvirt on an external host with bridged networking.

The OpenStack backend is meant to be used in the SUSE engineering private SUSE OpenStack Cloud installation only. Make sure enough hardware resources are available first.

The Amazon Web Services backend has been developed for scalability tests and it is used in that context exclusively.

## Basic `main.tf` configuration

In `sumaform` you define a set of virtual machines you want to in a `main.tf` configuration file. Its contents vary depending on the backend you choose.

Refer to backend READMEs to get started:
 * [libvirt README](modules/libvirt/README.md)
 * [OpenStack README](modules/openstack/README.md)
 * [AWS README](modules/aws/README.md)

## Typical use

Refer to the [official guides](https://www.terraform.io/docs/index.html) for a general understanding of Terraform and full commands.

For a very quick start:
```
vim main.tf     # change your VM setup
terraform get   # populates modules
terraform plan  # show the provisioning plan
terraform apply # bring up your systems, fasten your seatbelts!
```

## Advanced use

Please see [README_ADVANCED.md](README_ADVANCED.md).

### I have a problem!

Check [TROUBLESHOOTING.md](TROUBLESHOOTING.md) first, if that does not help feel free to drop a line to moio at suse dot de!
