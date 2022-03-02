# Design of sumaform

## Goal

Automating deployment and configuration of virtualized SUSE Manager installations for testing, debugging and development.

Security is explicitly not a goal, convenience is.

## Idea

sumaform is:

- [Terraform](https://www.terraform.io/) modules of two types:
  - "backend" modules, provider-specific. Those define basic infrastructure components such as hosts and disks
  - "backend-independent" modules (logical components like `suse_manager` or `minion`), that do not vary depending on the chosen backend
- `cloud-init` configuration files (for OSs which have an official disk image on supported providers)
- base disk images: bare-bones OSs to bootstrap VMs (for OSs which do not have an official disk image, or for historical reasons)
- [Salt](https://saltstack.com/) states: they define all software configuration on top of bare-bones OSs: SUSE Manager servers, clients, proxies, etc.

Intent is to keep those three components well separated in their purpose.

## Base disk images

Historically, an important part of sumaform was descriptors of base disk images for the supported OSs.

As of March 2020, support was added to use so-called "official" images from distributions/vendors which publish them. For those, `cloud-init` configuration files are integrated into Terraform modules in order to implement minimal configuration to bootstrap Salt states, which take care of the bulk of the complexity in configuration.

It is expected all newly supported OSs to make use of "official" images, thus base disk images are at this point considered deprecated.

## Requirements for base disk images

Basic Virtual Machine images must:

- have a `root` user in `root` group and password `linux`
- expect a network interface and assume its address is provided via DHCP
- contain an SSH server listening on port 22, allow plain password authentication
- contain `salt-minion` or an equivalent package
- contain any other package needed for the target virtualization infrastructure (eg. `qemu-ga` or equivalent package for libvirt)
- be immutable (not need to be upgraded). Ideally, they should be based on the initial release repo of the target OS (ie. without any updates). Upgrades will be taken care of by Salt states when needed, at the needed version
- be as minimal as possible, ideally [JeOS](https://www.suse.com/products/server/jeos)
