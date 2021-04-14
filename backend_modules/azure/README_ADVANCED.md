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
| public_security_group_id             | string  | `null`        | public security group id                                     |
| private_security_group_id            | string  | `null`        | private security group id                                    |
| private_additional_security_group_id | string  | `null`        | private additional security group id                         |
| bastion_host                         | string  | `null`        | bastion machine hostname (to access machines in private network) |

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
    public_security_group_id             = ...
    private_security_group_id            = ...
    private_additional_security_group_id = ...
    bastion_host                         = ...
  }
}
```
