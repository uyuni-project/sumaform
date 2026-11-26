# Azure-specific configuration

## Overview

Base Module will create:

- A Resource Group
- A Virtual Network
- three subnets
  - one private, that can only access other hosts in the VPC and outbound connection to internet
  - one additional network, private too, that only allows communications between hosts inside the subnet and no outbound connections allowed
  - one public, that can also access the Internet and accepts connections from an IP whitelist
- security groups, routing tables, Internet gateways, NAT gateway as appropriate
- one `bastion` host is also created in the public network

This architecture is based on [Azure Virtual Network concepts and best practices](https://docs.microsoft.com/en-us/azure/virtual-network/concepts-and-best-practices).

A mirror is necessary for SUSE Multi-Linux Manager installations and for SLES clients (see README_ADVANCED.md).

Azure backend don't have support for pxe_boot hosts. It's implementation will be considered in future releases.

## Prerequisites

You will need:

- an azure account. You have 2 options here:
  - [Sign in via the CLI](https://docs.microsoft.com/en-us/cli/azure/authenticate-azure-cli)
  - [Use an azure service principal](https://docs.microsoft.com/en-us/azure/active-directory/develop/howto-create-service-principal-portal): In this case you will need to include the service principal in the provider configuration. More information on alternative connection methods to azure can be found here:
    - [Azure Provider](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs)
- [an SSH key pair](https://docs.microsoft.com/en-us/azure/virtual-machines/linux/mac-create-ssh-keys) valid for that account
- the name of the region you want to use.
- your subscription ID: the `azurerm` provider (4.x and later) requires it, either as `subscription_id` in the `provider "azurerm"` block or via the `ARM_SUBSCRIPTION_ID` environment variable.

## Select Azure backend to be used

Create a symbolic link to the `azure` backend module directory inside the `modules` directory: `ln -sfn ../backend_modules/azure modules/backend `

## Azure backend specific variables

Most modules have configuration settings specific to the Azure backend, those are set via the `provider_settings` map variable. They are all described below.

### Base Module

Available provider settings for the base module:

| Variable name       | Type   | Default value   | Description                                                                                                     |
|---------------------|--------|-----------------|-----------------------------------------------------------------------------------------------------------------|
| location            | string | `null`          | Azure region where infrastructure will be created                                                               |
| ssh_allowed_ips     | array  | `[]`            | Array of IP's to white list for ssh connection                                                                  |
| key_file            | string | `null`          | ssh key file                                                                                                    |
| bastion_host        | string | `null`          | bastian host use to connect machines in private network                                                         |
| additional_network  | string | `172.16.2.0/24` | A network mask for the additional network (needs to follow the pattern 172.16.X.Y/24, where X cannot be 0 or 1) |
| public_key_location | string | `null`          | Location for access public key                                                                                  |
| disk_encryption_set_id | string | `null`       | ID of a Disk Encryption Set to encrypt all disks with customer-managed keys. Disks always use platform-managed encryption when unset |
| resource_group_name | string | `null` | Name of an existing resource group to deploy into. A new `<name_prefix>resources` resource group is created when unset |

An example follows:

```hcl-terraform
...
provider_settings = {
    location            = "francecentral"
    ssh_allowed_ips   = ["1.2.3.4"]
    key_file = "/path/to/key.pem"
}
...
```

### Host modules

Following settings apply to all modules that create one or more hosts of the same kind, such as `server_containerized`, `proxy_containerized`, `grafana`, `minion`, `mirror`, `sshminion` and `virthost`:

| Variable name       | Type    | Default value                                        | Description                                                         |
|---------------------|---------|------------------------------------------------------|---------------------------------------------------------------------|
| public_key_location | string  | [from base Module](base-module)                      | Location for access public key                                      |
| key_file            | string  | [from base Module](base-module)                      | ssh key file                                                        |
| ssh_user            | string  | OS-specific SSH user (ec2-user, centos, ubuntu, etc) | ssh user to use in ssh into the machine for provisioning            |
| bastion_host        | string  | [from base Module](base-module)                      | bastion host used to connect to machines in the private network     |
| public_instance     | boolean | `false`                                              | boolean to connect host either to the private or the public network |
| volume_size         | number  | `main_disk_size` of the module                       | main volume size in GB                                              |
| disk_encryption_set_id | string | [from base Module](base-module)                   | ID of a Disk Encryption Set for the OS and data disks of this host  |
| vm_size             | string  | `Standard_B1s`([apart from specific roles](#default-provider-settings-by-role)) | [Virtual Machine series](https://azure.microsoft.com/en-us/pricing/details/virtual-machines/series/) |

An example follows:

```hcl
...
  provider_settings = {
    public_instance = true
    vm_size   = "Standard_B4ms"
  }
...
```

`server`, `proxy` and `mirror` modules have configuration settings specific for extra data volumes, those are set via the `volume_provider_settings` map variable. They are described below.

- `volume_snapshot`: name of the volume snapshot to be used as a base for the new disk (default value: `null`)

 An example follows:

 ``` hcl
 data "azurerm_snapshot" "repodisk-snapshot" {
     volume_snapshot                = "snapshot disk name"
 }
```

#### Default provider settings by role

Some roles such as `server` or `mirror` have specific defaults that override those in the table above. Those are:

| Role         | Default values                |
|--------------|-------------------------------|
| server_containerized | `{vm_size = "Standard_D8as_v5"}` (`Standard_D8ps_v5` on arm64) |
| proxy_containerized  | `{vm_size = "Standard_F2s_v2"}` (`Standard_D2pls_v5` on arm64) |
| mirror       | `{vm_size = "Standard_B1s"}`  |
| controller   | `{vm_size = "Standard_B2s"}`  |
| grafana      | `{vm_size = "Standard_B2s"}`  |
| virthost     | `{vm_size = "Standard_B1ms"}` |
| jenkins      | `{vm_size = "Standard_B4ms"}` |

## Images

Available images: `opensuse160o`, `sles12sp5o`, `sles15sp5o`, `sles15sp6o`, `sles15sp7o`, `rhel8`, `rhel9`, `ubuntu2204` and `ubuntu2404`. Using any other image fails at plan time with the list of valid ones.

- `opensuse160o` follows the latest Leap 16 minor release, as Azure only publishes that one.
- SLES images are BYOS: a mirror is needed to get their repositories.
- The default SL Micro images of `server_containerized` and `proxy_containerized` are not available on Azure. Set `image = "sles15sp7o"` for SUSE Multi-Linux Manager 5.1, 5.2 and head.
- Images with a Marketplace purchase plan (currently `opensuse160o`) require their terms to be accepted once per subscription, by an account with subscription-level rights: `az vm image terms accept --urn susellc:opensuse-leap-x86-64:gen2:latest`.

cloud-init installs `venv-salt-minion` from the client tools repositories on all images.

## Data disks

Additional disks are attached at LUN 0 (`repository_disk_size`, or the mirror disk) and LUN 1 (`database_disk_size`), and used through the `/dev/disk/azure/scsi1/lunN` symlinks created by the Azure Linux agent udev rules. VM sizes exposing disks through NVMe are not supported.

## Accessing instances

`bastion` is accessible through SSH at the public name noted in outputs.

```bash
$ tofu apply
...
Apply complete! Resources: 0 added, 0 changed, 0 destroyed.

Outputs:

bastion_host = ip

$ ssh -i key.pem root@ip
ip-YYY-YYY-YYY-YYY:~ #
```

Other hosts are accessible via SSH from the `bastion` itself.
