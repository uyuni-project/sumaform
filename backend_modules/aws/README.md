# AWS-specific configuration

## Overview

Base Module will create:

- a VPC
- three subnets
  - one private, that can only access other hosts in the VPC and outbound connection to internet
  - one additional network, private too, that only allows communications between hosts inside the subnet and no outbound connections allowed
  - one public, that can also access the Internet and accepts connections from an IP whitelist
- security groups, routing tables, Internet gateways, NAT gateway as appropriate
- one `bastion` host is also created in the public network

This architecture is based on [AWS VPC with Public and Private Subnets](https://docs.aws.amazon.com/vpc/latest/userguide/VPC_Scenario2.html).

A mirror is necessary for SUSE Manager installations and for SLES clients (see README_ADVANCED.md).
In Uyuni deployments with free OSs a mirror is not mandatory, but will still to speed up machine provisioning.

AWS backend don't have support for pxe_boot hosts. Its implementation will be considered in future releases.

## Prerequisites

You will need:

- an AWS account, specifically an Access Key ID and a Secret Access Key
- [an SSH key pair](http://docs.aws.amazon.com/AWSEC2/latest/UserGuide/ec2-key-pairs.html#having-ec2-create-your-key-pair) valid for that account
- the name of the region and availability zone you want to use.

## Select AWS backend to be used

Create a symbolic link to the `aws` backend module directory inside the `modules` directory: `ln -sfn ../backend_modules/aws modules/backend`

## AWS backend specific variables

Most modules have configuration settings specific to the AWS backend, those are set via the `provider_settings` map variable. They are all described below.

### Base Module

Available provider settings for the base module:

| Variable name            | Type   | Default value   | Description                                                                                                             |
|--------------------------|--------|-----------------|-------------------------------------------------------------------------------------------------------------------------|
| region                   | string | `null`          | AWS region where infrastructure will be created                                                                         |
| availability_zone        | string | `null`          | AWS availability zone inside region                                                                                     |
| ssh_allowed_ips          | array  | `[]`            | Array of IP's to white list for ssh connection                                                                          |
| key_name                 | string | `null`          | ssh key name in AWS                                                                                                     |
| key_file                 | string | `null`          | ssh key file                                                                                                            |
| bastion_host             | string | `null`          | bastian host use to connect machines in private network                                                                 |
| additional_network       | string | `172.16.2.0/24` | A network mask for the additional network (needs to follow the pattern 172.16.X.Y/24, where X cannot be 0 or 1)         |
| server_registration_code | string | `null`          | SUMA SCC server registration code to use SCC repositories and disable internal repositories                             |
| proxy_registration_code  | string | `null`          | SUMA SCC proxy registration code to use SCC repositories and disable internal repositories                              |
| sles_registration_code   | string | `null`          | SLE registration code to use SCC repositories and disable internal repositories ( use for minion, sshminion and client) |
| bastion_image            | string | `opensuse156o`  | Image name to be used when deploying the bastion host                                                                   |

An example follows:

```hcl-terraform
...
provider_settings = {
    region            = "eu-west-3"
    availability_zone = "eu-west-3a"
    ssh_allowed_ips   = ["1.2.3.4"]
    key_name = "my-aws-key"
    key_file = "/path/to/key.pem"
}
...
```

### Supported `image` values

The supported AWS `image` values are defined in `backend_modules/aws/base/main.tf` in the `ami_info` map.

Unless overridden there, the default SSH user is `ec2-user`. Current exceptions are:

- `rocky8`, `rocky10`: `rocky`
- `ubuntu2204`, `ubuntu2404`: `ubuntu`

Supported values:

- openSUSE and SUSE:
  `tumbleweedo`, `opensuse156o`, `opensuse160o`, `sles12sp5`, `sles12sp5-paygo`, `sles15sp4o`, `sles15sp5o`, `sles15sp6o`, `sles15sp7o`, `sles15sp5-paygo`, `sles15sp6-paygo`, `sles15sp7-paygo`, `sles160-paygo`, `slesforsap15sp5-paygo`
- RHEL-like and Ubuntu:
  `rocky8`, `rocky10`, `rhel8`, `rhel9`, `ubuntu2204`, `ubuntu2404`
- Multi-Linux Manager marketplace images:
  `smlm-server-51-x86_64-ltd-paygo`, `smlm-server-51-arm64-ltd-paygo`, `smlm-proxy-51-x86_64-byos`, `smlm-proxy-51-arm64-byos`

Caveats:

- `tumbleweedo` is looked up only in `eu-central-1`.
- The `*-arm64-*` Multi-Linux Manager images require an arm64-compatible EC2 instance type.
- Not every `ami_info` entry follows the same bootstrap path in `backend_modules/aws/host/user_data.yaml`; some images rely on different provisioning behavior such as combustion.
- For custom AMIs or raw `ami-*` IDs, see `README_ADVANCED.md`.

### Host modules

Following settings apply to all modules that create one or more hosts of the same kind, such as `suse_manager`, `suse_manager_proxy`, `client`, `grafana`, `minion`, `mirror`, `sshminion` and `virthost`:

| Variable name   | Type     | Default value                                                    | Description                                                         |
|-----------------|----------|------------------------------------------------------------------|---------------------------------------------------------------------|
| key_name        | string   | [from base Module](base-module)                                  | ssh key name in AWS                                                 |
| key_file        | string   | [from base Module](base-module)                                  | ssh key file                                                        |
| ssh_user        | string   | OS-specific SSH user (ec2-user, centos, ubuntu, etc)          | ssh user to use in ssh into the machine for provisioning            |
| bastion_host    | string   | [from base Module](base-module)                                  | bastion host used to connect to machines in the private network             |
| public_instance | boolean  | `false`                                                          | boolean to connect host either to the private or the public network                    |
| volume_size     | number   | `50`                                                             | main volume size in GB                                              |
| instance_type   | string   | `t3.micro`([apart from specific roles](Default-values-by-role))  | [AWS instance type](https://aws.amazon.com/pt/ec2/instance-types/)  |

An example follows:

```hcl
...
  provider_settings = {
    public_instance = true
    instance_type   = "t3.small"
  }
...
```

`server`, `proxy` and `mirror` modules have configuration settings specific for extra data volumes, those are set via the `volume_provider_settings` map variable. They are described below.

- `volume_snapshot_id`: data volume snapshot id to be used as base for the new disk (default value: `null`)
- `type`: volume type that should be used (default value `sc1`). See the list at the [AWS EBS Volume Type documentation page](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/ebs-volume-types.html).

 An example follows:

 ``` hcl
volume_provider_settings = {
  volume_snapshot_id = "snap-0123abcd"
}
```

#### Default provider settings by role

Some roles such as `server` or `mirror` have specific defaults that override those in the table above. Those are:

| Role         | Default values                | Testuite                      |
|--------------|-------------------------------|-------------------------------|
| server       | `{instance_type="t3.medium"}` | `{instance_type="m5.xlarge"}` |
| proxy        | `{instance_type="t3.micro"}`  | `{instance_type="t3.medium"}` |
| mirror       | `{instance_type="t3.micro"}`  | `{instance_type="t3.micro"}`  |
| controller   | `{instance_type="m5.large"}`  | `{instance_type="m5.large"}`  |
| grafana      | `{instance_type="t3.medium"}` | `{instance_type="t3.medium"}` |
| virthost     | `{instance_type="t3.medium"}` | `{instance_type="t3.medium"}` |

## Accessing instances

`bastion` is accessible through SSH at the public name noted in outputs.

```bash
$ tofu apply
...
Apply complete! Resources: 0 added, 0 changed, 0 destroyed.

Outputs:

bastion_host = ec2-XXX-XXX-XXX-XXX.compute-1.amazonaws.com

$ ssh -i key.pem root@ec2-XXX-XXX-XXX-XXX.compute-1.amazonaws.com
ip-YYY-YYY-YYY-YYY:~ #
```

Other hosts are accessible via SSH from the `bastion` itself.

This project provides a utility script, `configure_aws_tunnels.rb`, which will add `Host` definitions in your SSH config file so that you don't have to input tunneling flags manually.

```bash
$ tofu apply
...
$ ./configure_aws_tunnels.rb
$ ssh server
ip-YYY-YYY-YYY-YYY:~ #
```
