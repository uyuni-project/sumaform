# AWS-specific configuration

## Overview

Modules provided by this project will create:
 - a VPC
 - two subnets
   - one private, that can only access other hosts in the VPC
   - one public, that can also access the Internet and accepts connections from an IP whitelist
 - security groups, routing tables, Internet gateways as appropriate
 - one `package-mirror` host in the public network that works as a bastion host
 - SUSE Manager servers, clients and proxies in the private network

This architecture is loosely inspired from [Segment's AWS Stack](https://segment.com/blog/the-segment-aws-stack/).

## Prerequisites

You will need:
 - an AWS account, specifically an Access Key ID and a Secret Access Key
 - [an SSH key pair](http://docs.aws.amazon.com/AWSEC2/latest/UserGuide/ec2-key-pairs.html#having-ec2-create-your-key-pair) valid for that account
 - IDs for a subnet and a security group that can be used to access an instance from your host. The easiest way to accomplish this is to use the `aws_network` module in this project, which will create a VPC with a public subnet and security group
 - the name of the region you want to use.

SUSE employees using openbare already have AMI images uploaded and data snapshots for the us-east-1 region; others have to follow instructions in [HOW_TO_UPLOAD.md](aws_images/HOW_TO_UPLOAD.md).

## package-mirror

In addition to acting as a bastion host for all other instances, the `package-mirror` host serves all repos and packages used by other instances. It works similarly to the one for the libvirt backend, allowing instances in the private subnet to be completely disconnected from the Internet.

Please note that content in `package-mirror` must be refreshed manually at this time, see comments in [aws_package_mirror/main.tf](aws_package_mirror/main.tf).

## Accessing instances

`package-mirror` is accessible through SSH at the public name noted in outputs.

```
$ terraform apply
...
Apply complete! Resources: 0 added, 0 changed, 0 destroyed.

Outputs:

package_mirror_public_name = ec2-XXX-XXX-XXX-XXX.compute-1.amazonaws.com

$ ssh -i key.pem root@ec2-XXX-XXX-XXX-XXX.compute-1.amazonaws.com
ip-YYY-YYY-YYY-YYY:~ #
```

Other hosts are accessible via SSH from the `package-mirror` itself.

This project provides a utility script, `configure_aws_tunnels.rb`, which will add `Host` definitions in your SSH config file so that you don't have to input tunneling flags manually.

```
$ terraform apply
...
$ ./configure_aws_tunnels.rb
$ ssh suma3pg
ip-YYY-YYY-YYY-YYY:~ #
```
