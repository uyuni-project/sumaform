![sumaform logo](help/sumaform-logo-color.svg)

`sumaform` is a way to quickly configure test Uyuni and SUSE Manager infrastructures with clients and servers.

[![Travis CI build status](https://travis-ci.org/uyuni-project/sumaform.svg?branch=master)](https://travis-ci.org/uyuni-project/sumaform)
[![Join the chat at https://gitter.im/sumaform/Lobby](https://badges.gitter.im/sumaform/Lobby.svg)](https://gitter.im/sumaform/Lobby?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge&utm_content=badge)


## Installation

openSUSE and SUSE Linux Enterprise Server:
```
# Uncomment one of the following lines depending on your distro

#sudo zypper addrepo https://download.opensuse.org/repositories/systemsmanagement:/sumaform/openSUSE_Tumbleweed/systemsmanagement:sumaform.repo
#sudo zypper addrepo https://download.opensuse.org/repositories/systemsmanagement:/sumaform/openSUSE_Leap_15.1/systemsmanagement:sumaform.repo
#sudo zypper addrepo https://download.opensuse.org/repositories/systemsmanagement:/sumaform/SLE_12_SP4/systemsmanagement:sumaform.repo
#sudo zypper addrepo https://download.opensuse.org/repositories/systemsmanagement:/sumaform/SLE_15_SP1/systemsmanagement:sumaform.repo

sudo zypper install terraform-provider-libvirt git-core
git clone https://github.com/uyuni-project/sumaform.git
```

Ubuntu and Debian:
```
sudo apt install alien
wget https://download.opensuse.org/repositories/systemsmanagement:/sumaform/SLE_15_SP1/x86_64/terraform.rpm
sudo alien -i terraform.rpm
wget https://download.opensuse.org/repositories/systemsmanagement:/sumaform/SLE_15_SP1/x86_64/terraform-provider-libvirt.rpm
sudo alien -i terraform-provider-libvirt.rpm
git clone https://github.com/uyuni-project/sumaform.git
```

NOTE: to deploy development versions of SUSE Manager you will have to have [SUSE's internal CA certificates](http://ca.suse.de/) installed on your system.

You will need to edit HCL ([HashiCorp Configuration Language](https://github.com/hashicorp/hcl)) files. Syntax highlighting is available in major text editors like [atom](https://atom.io/packages/language-hcl).

## Backend choice

`sumaform` can deploy virtual machines to:
 - single libvirt hosts
 - Amazon Web Services
 - null backend

The simplest, recommended setup is to use libvirt on your local host. That needs at least 8 GB of RAM in your machine.
If you need a lot of VMs or lack hardware you probably want using an external libvirt host with bridged networking is also possible.

The Amazon Web Services backend is currently under maintainance and is not immediately usable as-is. We plan to restore it soon.

The null backend can be useful in a wide variety of scenarios, for example:
 - Test configurations before going live in another supported backend
 - Cases in which the virtual infrastructure is outside of the Terraform user's control
 - Cover architectures that will maybe never be covered by any other Terraform plugin

## Basic `main.tf` configuration

In `sumaform` you define a set of virtual machines in a `main.tf` configuration file, then run Terraform to have them deployed. Contents of the file vary slightly depending on the backend you choose.

To choose the backend in use one should create a symbolic link to a `backend_module` module. Refer to specific READMEs to get started:
 * [libvirt README](backend_modules/libvirt/README.md)
 * [AWS README](backend_modules/aws/README.md)
 * [AZURE README](backend_modules/azure/README.md)
 * [SSH README](backend_modules/ssh/README.md)
 * [NULL README](backend_modules/null/README.md)

## Typical use

Refer to the [official guides](https://www.terraform.io/docs/index.html) for a general understanding of Terraform and full commands.

For a very quick start:
```
vim main.tf     # change your VM setup
terraform init  # populate modules
terraform apply # prepare and apply a plan to create your systems (after manual confirmation)
```

## Advanced use

 - To run the Cucumber testsuite for Uyuni or SUSE Manager, see [README_TESTING.md](README_TESTING.md)
 - For any other use, please see [README_ADVANCED.md](README_ADVANCED.md)

### I have a problem!

Check [TROUBLESHOOTING.md](TROUBLESHOOTING.md) first, if that does not help feel free to [join the Gitter chat](https://gitter.im/sumaform/Lobby) or directly drop a line to moio at suse dot de!
