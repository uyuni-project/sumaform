# Feilong-specific configuration

## Overview

Base Module currrently does not create any resources, but is used to define shared variables.

Host Module currently creates for each host:

- a set of cloud-init parameters, that will be stored into a local file in `/tmp` directory; this file will then be uploaded by Feilong at VM deployment time
- a z/VM guest virtual machine.


## Prerequisites

You will need:

- a s/390 mainframe running z/VM inside one of its LPARs
- a Feilong connector, running on a Linux system inside a z/VM guest in that LPAR
- to have a pair of openSSH keys created for user `zvmsdk` on that Linux system
- to grant the Feilong connector SSH access to your local workstation so it can download files

The Feilong connector can either be deployed standalone, following these [instructions](https://cloudlib4zvm.readthedocs.io/en/latest/quickstart.html#installation), or be part of a larger [IBM Cloud Infrastructure Center](https://www.ibm.com/products/cloud-infrastructure-center) (CIC). 

You can grant access to the Feilong connector to your local account by adding the public key of `zvmsdk` user into your `~/.ssh/autorized_keys` file.

An usage example follows:

```hcl-terraform
...
provider "feilong" {
  connector = "feilong.example.org"
  local_user = "johndoe@test.example.org"
}
...
```


## Select Feilong backend to be used

If you want a pure s/390 deployment, create a symbolic link to the `feilong` backend module directory inside the `modules` directory: `ln -sfn ../backend_modules/feilong modules/backend`.

If you rather want to mix it with e.g. the libvirt module, just call directly from your `main.tf` file the `base` and `host` backend modules.


## Feilong backend specific variables

Most modules have configuration settings specific to the Feilong backend, those are set via the `provider_settings` map variable. They are all described below.

### Base Module

| Variable name            | Type   | Default value   | Description                                                                                                             |
|--------------------------|--------|-----------------|-------------------------------------------------------------------------------------------------------------------------|
| key_file                 | string | `~/.ssh/id_ed25519` | path to private SSH key file used for provisioning                                                                      |

### Host Module

| Variable name            | Type   | Default value   | Description                                                                                                             |
|--------------------------|--------|-----------------|-------------------------------------------------------------------------------------------------------------------------|
| userid                   | string | `null`          | system name for z/VM (8 characters maximum, all caps)                                                                   |
| memory                   | string | `2G`            | amount of VM "storage", as an integer followed by an unit: B, K, M, G                                                   |
| vcpu                     | number | `1`             | number of virtual CPUs assigned to the VM                                                                               |
| mac                      | string | `null`          | MAC address as 6 hexadecimal digits separed by colons; beware the first 3 bytes might be replaced by Feilong's default  |
| ssh_user                 | string | `root`          | system user to connect to via SSH for provisioning                                                                      |

An example follows:

```hcl-terraform
...
provider_settings = {
  userid   = "S15SP3"
  mac      = "02:3a:fc:44:55:66"
  ssh_user = "sles"
}
...
```
