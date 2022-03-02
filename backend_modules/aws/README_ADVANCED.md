# Advanced configuration

## mirror

The `mirror` host serves all repos and packages used by other instances.
It will be used exclusively by other VMs to download SUSE content - that means your SUSE Manager servers, clients, minions and proxies will be "fully disconnected", not requiring Internet access to operate.

Note that `mirror` must be populated before any host can be deployed. By default, its cache is refreshed nightly via `cron`, as configured in `/etc/cron.daily`. You can also schedule a one-time refresh by running manually some of the scripts that reside in `/usr/local/bin` directory.
The `mirror` host's data volume can be created from a pre-populated snapshot, which allows it to be operational without lengthy channel synchronization.

### mirror setup

When creating mirror machine one have two possibilities:

* Creating with empty data disk (if no snapshot is available):

```hcl
module "mirror" {
  source = "./modules/mirror"

  base_configuration = module.base.configuration

  provider_settings = {
    public_instance = true
  }
}
```

* Creating using a data disk snapshot:

```hcl
data "aws_ebs_snapshot" "data_disk_snapshot" {
  most_recent = true

  filter {
    name   = "tag:Name"
    values = ["mirror-data-volume-snapshot"]
  }
}

module "mirror" {
  source = "./modules/mirror"

  base_configuration = module.base.configuration
  provider_settings = {
    public_instance = true
  }
  volume_provider_settings = {
    volume_snapshot_id = data.aws_ebs_snapshot.data_disk_snapshot.id
  }
}
```

**Sync mirror data (this will take some time):**

   If you are using released versions only or creating a mirror disk from scratch:

   1. `ssh root@<MIRROR_HOST>`
   1. `sudo minima.sh` (or any other mirroring script in `/usr/local/bin`)

If you need access to SUSE internal nightly builds or `Devel:` packages, you will first of all need a fully set up and synced libvirt based mirror on a machine in the engineering network.
Once you have it you can transfer development packages to your AWS mirror via rsync, for example via the commands below:

   1. `scp <YOUR_AWS_KEY> root@<LOCAL_MIRROR_HOST>://root/key.pem`
   2. `ssh root@<MIRROR_HOST>`
   3. `zypper in rsync`
   4. `rsync -av0 --delete -e 'ssh -i key.pem -o "proxycommand ssh -W %h:%p -i key.pem ec2-user@<BASTION_MACHINE_PUBLIC_DNS>"' /srv/mirror/ ec2-user@<MIRROR_PRIVATE_DNS>://srv/mirror/`

#### Creating data disk snapshot

We have two options to perform this task: using AWS console or with terraform resource.

##### AWS console

1. Login to the AWS console
2. Select `EC2` on Services list
3. On left-side menu select `Volumes` under `Elastic Block Store` menu option
4. Right click on the data volume and select `Create Snapshot`

##### Terraform resource

1. Create a disk snapshot (this will take some time)

    ```hcl
    data "aws_ebs_volume" "data_disk_id" {
      most_recent = true

      filter {
        name   = "tag:Name"
        values = ["${module.base.configuration["name_prefix"]}mirror-data-volume"]
      }
    }

    resource "aws_ebs_snapshot" "mirror_data_snapshot" {
      volume_id = data.aws_ebs_volume.data_disk_id.id
      timeouts {
        create = "60m"
        delete = "60m"
      }
      tags = {
        Name = "mirror-data-volume-snapshot"
      }
    }
    ```

2. In case you want to destroy/delete the mirror instance but keep the snapshot
    1. remove snapshot resource from terraform state: `terraform state rm aws_ebs_snapshot.mirror_data_snapshot`
    2. If you now run `terraform destroy` the snapshot will be preserved.
    However, running `terraform apply` again will create a new snapshot.

#### Force the re-creation of a data disk snapshot

To remove the older snapshot and create a new one, taint its resource via `terraform taint aws_ebs_snapshot.mirror_data_snapshot`.

## Re-use of existing network infrastructure resources

One can deploy to existing pre-created infrastructure (VPC, networks, bastion) which should follow the pattern defined for the network. See README.md for more information.
To use it, a set of properties should be set on sumaform base module.

| Variable name                        | Type    | Default value | Description                                                      |
|--------------------------------------|---------|---------------|------------------------------------------------------------------|
| create_network                       | boolean | `true`        | flag indicate if a new infrastructure should be created          |
| public_subnet_id                     | string  | `null`        | aws public subnet id                                             |
| private_subnet_id                    | string  | `null`        | aws private subnet id                                            |
| private_additional_subnet_id         | string  | `null`        | aws private additional subnet id                                 |
| public_security_group_id             | string  | `null`        | aws public security group id                                     |
| private_security_group_id            | string  | `null`        | aws private security group id                                    |
| private_additional_security_group_id | string  | `null`        | aws private additional security group id                         |
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

## How to use specific a AMI

It is possible to use a custom image instead of letting sumaform lookup the most appropriate image.

Example:

```hcl
module "server" {
  source = "./modules/server"
  base_configuration = module.base.configuration
  name            = "server"
  image           = "AMI-123456789"
}
```
