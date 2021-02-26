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

A mirror is necessary for SUSE Manager installations and for SLES clients (see README_ADVANCED.md).
In Uyuni deployments with free OSs a mirror is not mandatory, but will still to speed up machine provisioning.

Azure backend don't have support for pxe_boot hosts. It's implementation will be considered in future releases.

## Prerequisites

You will need:
 - an azure account. You have 2 options here:
    - [Sign in via the CLI](https://docs.microsoft.com/en-us/cli/azure/authenticate-azure-cli)
    - [Use an azure service principal](https://docs.microsoft.com/en-us/azure/active-directory/develop/howto-create-service-principal-portal): In this case you will need to include the service principal in the provider configuration. More information on alternative connection methods to azure can be found here:
       - [Azure Provider](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs)
- [an SSH key pair](https://docs.microsoft.com/en-us/azure/virtual-machines/linux/mac-create-ssh-keys) valid for that account
- the name of the region and availability zone you want to use.

## Select Azure backend to be used

Create a symbolic link to the `azure` backend module directory inside the `modules` directory: `ln -sfn ../backend_modules/azure modules/backend `

## Azure backend specific variables

Most modules have configuration settings specific to the Azure backend, those are set via the `provider_settings` map variable. They are all described below.

### Base Module
Available provider settings for the base module:

| Variable name      | Type   | Default value   | Description                                                                                                    |
|--------------------|--------|-----------------|----------------------------------------------------------------------------------------------------------------|
| region             | string | `null`          | Azure region where infrastructure will be created                                                                |
| ssh_allowed_ips    | array  | `[]`            | Array of IP's to white list for ssh connection                                                                 |
| key_name           | string | `null`          | ssh key name in Azure                                                                                            |
| key_file           | string | `null`          | ssh key file                                                                                                   |
| bastion_host       | string | `null`          | bastian host use to connect machines in private network                                                        |
| additional_network | string | `172.16.2.0/24` | A network mask for the additional network (needs to follow the pattern 172.16.X.Y/24, where X cannot be 0 or 1) |

An example follows:
```hcl-terraform
...
provider_settings = {
    location            = "francecentral"
    ssh_allowed_ips   = ["1.2.3.4"]
    key_name = "my-key"
    key_file = "/path/to/key.pem"
}
...
```

### Host modules

Following settings apply to all modules that create one or more hosts of the same kind, such as `suse_manager`, `suse_manager_proxy`, `client`, `grafana`, `minion`, `mirror`, `sshminion` and `virthost`:

| Variable name   | Type     | Default value                                                    | Description                                                         |
|-----------------|----------|------------------------------------------------------------------|---------------------------------------------------------------------|
| key_name        | string   | [from base Module](base-module)                                  | ssh key name in Azure                                                 |
| key_file        | string   | [from base Module](base-module)                                  | ssh key file                                                        |
| ssh_user        | string   | OS-specific SSH user (ec2-user, centos, ubuntu, etc)          | ssh user to use in ssh into the machine for provisioning            |
| bastion_host    | string   | [from base Module](base-module)                                  | bastion host used to connect to machines in the private network             |
| public_instance | boolean  | `false`                                                          | boolean to connect host either to the private or the public network                    |
| volume_size     | number   | `50`                                                             | main volume size in GB                                              |
| vm_size         | string   | `Standard_B4ms`([apart from specific roles](Default-values-by-role))  | [Virtual Machine series](https://azure.microsoft.com/en-us/pricing/details/virtual-machines/series/)  |

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

 * `name`: name of the volume snapshot to be used as a base for the new disk (default value: `null`)
 * `resource_group_name`: resource group where the snapshot disk can be found (default value: `null`)

 An example follows:
 ``` hcl
 data "azurerm_snapshot" "repodisk-snapshot" {
     name                = "snapshot disk name"
     resource_group_name = "resource group for snapshot disk"
 }
```

#### Default provider settings by role

Some roles such as `server` or `mirror` have specific defaults that override those in the table above. Those are:

| Role         | Default values                |
|--------------|-------------------------------|
| server       | `{vm_size = "Standard_B4ms"}` |
| mirror       | `{vm_size = "Standard_B1s"}`  |
| controller   | `{vm_size = "Standard_B2s"}`  |
| grafana      | `{vm_size = "Standard_B2s"}`  |
| virthost     | `{vm_size = "Standard_B1ms"}` |
| pts_minion   | `{vm_size = "Standard_B2s"}`  |

## Accessing instances

`bastion` is accessible through SSH at the public name noted in outputs.

```
$ terraform apply
...
Apply complete! Resources: 0 added, 0 changed, 0 destroyed.

Outputs:

bastion_host = ip

$ ssh -i key.pem root@ip
ip-YYY-YYY-YYY-YYY:~ #
```

Other hosts are accessible via SSH from the `bastion` itself.
