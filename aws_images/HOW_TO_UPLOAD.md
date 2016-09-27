# Image building and uploading

This project requires custom images to be uploaded to AWS.

Building of these images happens via [KIWI](https://github.com/SUSE/kiwi) in the following [Open Build Service](http://openbuildservice.org/) projects:

 * [openSUSE image](https://build.opensuse.org/package/show/home:SilvioMoioli:Terraform:Images:AmazonEC2/opensuse421) (publicly accessible)
 * [SLES 12 SP1 image](https://build.suse.de/package/show/Devel:Galaxy:Terraform:Images:AmazonEC2/sles12sp1) (SUSE employees only)

Uploading images built from those projects as new AMIs is non-trivial, as it requires a temporary instance with multiple volumes and switching of the root volume. This is automated via the `ec2uploadimg` tool from the [Enceladus project](https://github.com/SUSE/Enceladus).

## AWS prerequisites

You will need:
 - an AWS account, specifically an Access Key ID and a Secret Access Key
 - [an SSH key pair](http://docs.aws.amazon.com/AWSEC2/latest/UserGuide/ec2-key-pairs.html#having-ec2-create-your-key-pair) valid for that account
 - IDs for a subnet and a security group that can be used to access an instance from your host. The easiest way to accomplish this is to use the `aws_network` module in this project, which will create a VPC with a public subnet and security group
 - the name of the region you want to use.
 
## Installing `ec2uploadimg`

 - SUSE distributions:
   - install the [python-ec2uploadimg](https://software.opensuse.org/package/python-ec2uploadimg?search_term=python-ec2uploadimg) package and its dependencies
 - Debian and Debian-based distributions:
   ```
   sudo apt install python-boto3
   git clone git@github.com:SUSE/Enceladus.git
   cd Enceladus/ec2utils/ec2utilsbase
   sudo python setup.py install --single-version-externally-managed --root=/
   cd ../ec2uploadimg/
   sudo python setup.py install --single-version-externally-managed --root=/
   ```

## Configuring `ec2uploadimg`

Copy the [ec2utils example configuration file](https://raw.githubusercontent.com/SUSE/Enceladus/master/ec2utils/ec2utils.conf.example) to `aws_images` and edit it to match your configuration. In particular:

 - the `[account-servers]` section must be filled
 - at least one region section must be filled. AKI IDs are not important, leave the default user.

## Uploading images

You can use the following commands:

```
wget http://download.opensuse.org/repositories/home:/SilvioMoioli:/Terraform:/Images:/AmazonEC2/images/opensuse421.x86_64.raw.xz -O /tmp/opensuse421.x86_64.raw.xz
ec2uploadimg \
  --file ec2utils.conf \
  --account servers \
  --backing-store ssd \
  --description <DESCRIPTION> \
  --grub2 \
  --machine x86_64 \
  --name <NAME> \
  --sriov-support \
  --virt-type hvm \
  --root-volume-size 10 \
  --verbose \
  --regions us-east-1 \
  --vpc-subnet-id <PUBLIC_VPC_SUBNET_ID> \
  --security-group-ids <SECURITY_GROUP_ID> \
  --wait-count 3 \
  /tmp/opensuse421.x86_64.raw.xz

wget http://download.suse.de/ibs/Devel:/Galaxy:/Terraform:/Images:/AmazonEC2/images/sles12sp1.x86_64.raw.xz -O /tmp/sles12sp1.x86_64.raw.xz
ec2uploadimg \
  --file ec2utils.conf \
  --account servers \
  --backing-store ssd \
  --description <DESCRIPTION> \
  --grub2 \
  --machine x86_64 \
  --name <NAME> \
  --sriov-support \
  --virt-type hvm \
  --root-volume-size 2 \
  --verbose \
  --regions us-east-1 \
  --vpc-subnet-id <PUBLIC_VPC_SUBNET_ID> \
  --security-group-ids <SECURITY_GROUP_ID> \
  --wait-count 3 \
  /tmp/sles12sp1.x86_64.raw.xz
```
