# Advanced configuration

## Re-use of existing network infrastructure resources

One can deploy to existing pre-created infrastructure which should follow the pattern defined for the network. See README.md for more information.
To use it, a set of properties should be set on sumaform base module.

| Variable name                        | Type    | Default value | Description                                                      |
|--------------------------------------|---------|---------------|------------------------------------------------------------------|
| create_network                       | boolean | `true`        | flag indicate if a new infrastructure should be created          |
| public_subnet_id                     | string  | `null`        | public subnet id                                             |
| private_subnet_id                    | string  | `null`        | private subnet id                                            |
| private_additional_subnet_id         | string  | `null`        | private additional subnet id                                 |
| bastion_host                         | string  | `null`        | bastion machine hostname (to access machines in private network) |
| resource_group_name                  | string  | `null`        | existing resource group for the hosts, see below             |

Hosts (VMs, network interfaces, public IPs and disks) are created in a new `<name_prefix>resources` resource group, or in the one named by `resource_group_name`, which can also be the network's own.
The existing network must be in the same subscription and region (`location`) as the hosts, and the account running OpenTofu needs permission to join its subnets (`Microsoft.Network/virtualNetworks/subnets/join/action`).

Example:
```hcl
module "base" {
  source = "./modules/base"
  ...
  provider_settings = {
    create_network                       = false
    public_subnet_id                     = ...
    private_subnet_id                    = ...
    private_additional_subnet_id         = ...
    bastion_host                         = ...
  }
}
```
