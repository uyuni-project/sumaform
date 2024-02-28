![sumaform logo](help/sumaform-logo-color.svg)

`sumaform` is a way to quickly configure test Uyuni and SUSE Manager infrastructures with clients and servers.

[![CI validation tests](https://github.com/uyuni-project/sumaform/actions/workflows/ci-validation.yml/badge.svg?branch=master)](https://github.com/uyuni-project/sumaform/actions/workflows/ci-validation.yml)
[![Join the chat at https://gitter.im/sumaform/Lobby](https://badges.gitter.im/sumaform/Lobby.svg)](https://gitter.im/sumaform/Lobby?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge&utm_content=badge)

## Installation

**Terraform version**: 1.0.10

**Libvirt provider version**: 0.6.3

NOTE: to deploy development versions of SUSE Manager you will have to have [SUSE's internal CA certificates](http://ca.suse.de/) installed on your system.

You will need to edit HCL ([HashiCorp Configuration Language](https://github.com/hashicorp/hcl)) files. Syntax highlighting is available in major text editors like [atom](https://atom.io/packages/language-hcl).

### Prerequisites for openSUSE and SUSE Linux Enterprise Server

Execute the following on openSUSE and SUSE Linux Enterprise Server:

```bash
# Uncomment one of the following lines depending on your distro

#sudo zypper addrepo http://download.opensuse.org/repositories/systemsmanagement:/sumaform/openSUSE_Tumbleweed/systemsmanagement:sumaform.repo
#sudo zypper addrepo http://download.opensuse.org/repositories/systemsmanagement:/sumaform/openSUSE_Leap_15.2/systemsmanagement:sumaform.repo
#sudo zypper addrepo http://download.opensuse.org/repositories/systemsmanagement:/sumaform/openSUSE_Leap_15.3/systemsmanagement:sumaform.repo
#sudo zypper addrepo http://download.opensuse.org/repositories/systemsmanagement:/sumaform/SLE_12_SP5/systemsmanagement:sumaform.repo
#sudo zypper addrepo http://download.opensuse.org/repositories/systemsmanagement:/sumaform/SLE_15_SP3/systemsmanagement:sumaform.repo

sudo zypper install git-core
sudo zypper install --from systemsmanagement_sumaform terraform terraform-provider-libvirt
git clone https://github.com/uyuni-project/sumaform.git
```

### Prerequisites for Ubuntu and Debian

Execute the following commands:

```bash
sudo apt install alien
wget http://download.opensuse.org/repositories/systemsmanagement:/sumaform/SLE_15_SP1/x86_64/terraform.rpm
sudo alien -i terraform.rpm
wget http://download.opensuse.org/repositories/systemsmanagement:/sumaform/SLE_15_SP1/x86_64/terraform-provider-libvirt.rpm
sudo alien -i terraform-provider-libvirt.rpm
git clone https://github.com/uyuni-project/sumaform.git
```

## Backend choice

### Backends explained

`sumaform` can deploy virtual machines to:

- single libvirt hosts
- Amazon Web Services
- null backend

**The simplest, recommended setup is to use libvirt on your local host.** That needs at least 8 GB of RAM in your machine.
If you need a lot of VMs or lack hardware you probably want to use an external libvirt host with bridged networking.

The Amazon Web Services backend is currently under maintenance and is not immediately usable as-is. We plan to restore it soon.

The null backend can be useful in a wide variety of scenarios, for example:

- Test configurations before going live in another supported backend
- Cases in which the virtual infrastructure is outside of the Terraform user's control
- Cover architectures that will maybe never be covered by any other Terraform plugin

See [TROUBLESHOOTING.md](TROUBLESHOOTING.md) for more information about configuring the backend.
Each backend has a README file with further configuration instructions.

To choose the backend in use one should create a symbolic link to a `backend_module` module.

```bash
ln -s ../backend_modules/<BACKEND>/ modules/backend
```

### Preparing for the libvirt backend

To use the libvirt provider, install and enable libvirt before you attempt to run the terraform deployment.
The `virt-manager` package is recommended because it configures default resources that the terraform deployment uses, e.g. the `default` virtual network.

```bash
# Download and install libvirt and virt-manager, for example:
sudo zypper install libvirt virt-manager
# On Ubuntu/Debian:
sudo apt install virt-manager qemu-kvm libvirt-daemon-system

# Start libvirt
sudo systemctl start libvirtd

# Optionally, enable libvirt so that it starts at boot time
sudo systemctl enable libvirtd
```

Create a symbolic link to the `libvirt` backend module:

```bash
ln -s ../backend_modules/libvirt/ modules/backend
```

Copy the libvirt example file and adjust it:

```bash
cp main.tf.libvirt.example main.tf
```

## Basic `main.tf` configuration

In `sumaform` you define a set of virtual machines in a `main.tf` configuration file, then run Terraform to have them deployed. Contents of the file vary slightly depending on the backend you choose.

Refer to the backend-specific READMEs to get started:

- [libvirt README](backend_modules/libvirt/README.md)
- [AWS README](backend_modules/aws/README.md)
- [AZURE README](backend_modules/azure/README.md)
- [SSH README](backend_modules/ssh/README.md)
- [NULL README](backend_modules/null/README.md)

## Typical use

Refer to the [official guides](https://www.terraform.io/docs/index.html) for a general understanding of Terraform and full commands.

For a very quick start:

```bash
vim main.tf     # change your VM setup
terraform init  # populate modules
terraform validate # check if the configuration is valid
terraform apply # prepare and apply a plan to create your systems (after manual confirmation)
```

### Common Variables

**cc_username/cc_password**: Credentials for the [SUSE Customer Center](https://scc.suse.com/).
Set these credentials if you are deploying SUMA, or synchronizing SUMA repositories.
They can be omitted when deploying Uyuni.

**images**: In the `base` module, the `images` variable specifies the images that you want to download and use in your installation, for example:

```bash
# main.tf file contents
module "base" {
  source = "./modules/base"

  images = [
    "centos7o",
    "almalinux8o",
    "opensuse154o",
    "opensuse155o",
    "sles15sp4o",
    "sles15sp5o",
    "sles12sp5o",
    "ubuntu2004o",
    "ubuntu2204o"
  ]
# ...
}
```

## Advanced use

- To run the Cucumber testsuite for Uyuni or SUSE Manager, see [README_TESTING.md](README_TESTING.md)
- For any other use, please see [README_ADVANCED.md](README_ADVANCED.md)

## I have a problem!

Check [TROUBLESHOOTING.md](TROUBLESHOOTING.md) first, if that does not help feel free to [join the Gitter chat](https://gitter.im/sumaform/Lobby)!
