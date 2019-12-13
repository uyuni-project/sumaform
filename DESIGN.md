# Design of sumaform

## Goal
Automating deployment and configuration of virtualized SUSE Manager installations for testing, debugging and development.

Security is explicitly not a goal, convenience is.

## Idea
sumaform is:
 * [Terraform](https://www.terraform.io/) modules composed of two types: backend modules (tied to a provider) and backend-independent modules (logical modules like `server` or `minion`)
 With those modules, we can define a virtual infrastructure (VMs, networks, firewalls, disks, etc.) and apply it to different backend types.
 * base disk images: they contain bare-bones OSs to bootstrap VMs above
 * [Salt](https://saltstack.com/) states: they define all software configuration on top of bare-bones OSs: SUSE Manager servers, clients, proxies, etc.

Intent is to keep those three components well separated in their purpose.

## Requirements for base disk images

Basic Virtual Machine images must:
 - have a `root` user in `root` group and password `linux`
 - expect a network interface and assume its addreess is provided via DHCP
 - contain an SSH server listening on port 22, allow plain password authentication
 - contain `salt-minion` or an equivalent package
 - contain any other package needed for the target virtualization infrastructure (eg. `qemu-ga` or equivalent package for libvirt)
 - be immutable (not need to be upgraded). Ideally, they should be based on the initial release repo of the target OS (ie. without any updates). Upgrades will be taken care of by Salt states when needed, at the needed version
 - be as minimal as possible, ideally [JeOS](https://www.suse.com/products/server/jeos)
