![sumaform logo](help/sumaform-logo-color.svg)

`sumaform` is a way to quickly configure test SUSE Manager setups with clients and servers.

It got its [portmanteau](https://en.wikipedia.org/wiki/Portmanteau) name being the successor of [suminator](https://github.com/SUSE/suminator/) implemented as [Terraform](https://www.terraform.io/) modules.

[![Travis CI build status](https://travis-ci.org/moio/sumaform.svg?branch=master)](https://travis-ci.org/moio/sumaform)
[![Join the chat at https://gitter.im/sumaform/Lobby](https://badges.gitter.im/sumaform/Lobby.svg)](https://gitter.im/sumaform/Lobby?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge&utm_content=badge)


## Installation

openSUSE and SUSE Linux Enterprise Server:
```
# Uncomment one of the following lines depending on your distro

#sudo zypper addrepo https://download.opensuse.org/repositories/systemsmanagement:/sumaform/openSUSE_Leap_15.0/systemsmanagement:sumaform.repo
#sudo zypper addrepo https://download.opensuse.org/repositories/systemsmanagement:/sumaform/SLE_12_SP3/systemsmanagement:sumaform.repo

sudo zypper install terraform-provider-libvirt git-core
git clone https://github.com/moio/sumaform.git
```

Ubuntu and Debian:
```
sudo apt install alien
wget https://download.opensuse.org/repositories/systemsmanagement:/sumaform/SLE_12_SP3/x86_64/terraform.rpm
sudo alien -i terraform.rpm
wget https://download.opensuse.org/repositories/systemsmanagement:/sumaform/SLE_12_SP3/x86_64/terraform-provider-libvirt.rpm
sudo alien -i terraform-provider-libvirt.rpm
git clone https://github.com/moio/sumaform.git
```

NOTE: be sure to have [SUSE's CA certificates](http://ca.suse.de/) installed on your system.

You will need to edit HCL ([HashiCorp Configuration Language](https://github.com/hashicorp/hcl)) files. Syntax highlighting is available in major text editors like [atom](https://atom.io/packages/language-hcl).

## Backend choice

`sumaform` can deploy virtual machines to:
 - single libvirt hosts
 - OpenStack Cloud
 - Amazon Web Services

The simplest, recommended setup is to use libvirt on your local host. That needs at least 8 GB of RAM in your machine.
If you need a lot of VMs or lack hardware you probably want using an external libvirt host with bridged networking is also possible.

The Amazon Web Services backend has been developed for scalability tests of SUSE Manager and it is only currently used in that context.

## Basic `main.tf` configuration

In `sumaform` you define a set of virtual machines in a `main.tf` configuration file, then run Terraform to have them deployed. Contents of the file vary slightly depending on the backend you choose.

Refer to specific READMEs to get started:
 * [libvirt README](modules/libvirt/README.md)
 * [OpenStack README](modules/openstack/README.md)
 * [AWS README](modules/aws/README.md)

## Typical use

Refer to the [official guides](https://www.terraform.io/docs/index.html) for a general understanding of Terraform and full commands.

For a very quick start:
```
vim main.tf     # change your VM setup
terraform init  # populates modules
terraform plan  # show the provisioning plan
terraform apply # bring up your systems, fasten your seatbelts!
```

## Advanced use

Please see [README_ADVANCED.md](README_ADVANCED.md).

### I have a problem!

Check [TROUBLESHOOTING.md](TROUBLESHOOTING.md) first, if that does not help feel free to [join the Gitter chat](https://gitter.im/sumaform/Lobby) or directly drop a line to moio at suse dot de!
