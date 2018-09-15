# Image building and uploading

This project requires custom images to be uploaded to AWS.

Building of these images happens via [KIWI](https://github.com/SUSE/kiwi) in the following [Open Build Service](http://openbuildservice.org/) projects:

 * [openSUSE image](https://build.opensuse.org/package/show/home:SilvioMoioli:Terraform:Images:AmazonEC2/opensuse422) (publicly accessible)
 * [SLES 12 SP1 image](https://build.suse.de/package/show/Devel:Galaxy:Terraform:Images:AmazonEC2/sles12sp1) (SUSE employees only)
 * [SLES 12 SP2 image](https://build.suse.de/package/show/Devel:Galaxy:Terraform:Images:AmazonEC2/sles12sp2) (SUSE employees only)

Uploading images built from those projects as new AMIs is non-trivial, as it requires a temporary instance with multiple volumes and switching of the root volume. This is automated via the `ec2uploadimg` tool from the [Enceladus project](https://github.com/SUSE/Enceladus).

## Minimal AWS setup

 - obtain credentials to access AWS in a region
 - log in to the [AWS Console](http://console.aws.amazon.com/)
   - if you don't have one, create an SSH key (Console Home -> EC2 -> Network and Security -> Key Pairs -> Create Key Pair). Store the pem file and note the key name
   - take ID of a subnet that has an Internet Gateway associated (Console Home -> VPC -> Subnets — on a new AWS account any of the default ones will work)
   - take ID of a security group that allows SSH traffic from your host:
     - on a new AWS account, select the default security group (Console Home -> EC2 -> Security Groups -> default). Otherwise use an existing one or create a new one
     - add a rule to allow SSH traffic from your host:
       - Console Home -> EC2 -> Security Groups -> default -> Inbound -> Edit -> Add Rule
         - Type: SSH
         - Protocol: TCP
         - Port Range: 22
         - Source: My IP
         - click on Save

## Installing `ec2uploadimg`

 - SUSE distributions:
   - install the [python-ec2uploadimg](https://software.opensuse.org/package/python-ec2uploadimg?search_term=python-ec2uploadimg) package and its dependencies
 - Debian and Debian-based distributions:
   ```
   sudo apt install python3 python3-dev build-essential
   virtualenv --python=python3 ~/virtualenv/enceladus
   cd ~/virtualenv/enceladus
   source bin/activate
   git clone git@github.com:SUSE/Enceladus.git
   git checkout fc77486e984637d76e0627de200bb0df7be25b3c
   cd Enceladus/ec2utils/ec2utilsbase
   python setup.py install
   cd ../ec2uploadimg/
   python setup.py install
   easy_install boto3==1.4.7
   easy_install paramiko==2.3.1
   ```

## Configuring `ec2uploadimg`

Copy the [ec2utils example configuration file](https://raw.githubusercontent.com/SUSE/Enceladus/master/ec2utils/ec2utils.conf.example) to `modules/aws/images` and edit it to match your configuration. In particular:

 - the `[account-servers]` section must be filled
 - at least one region section must be filled. AKI IDs are not important, leave the default user.

## Uploading images

You can use the following commands:

```
PUBLIC_VPC_SUBNET_ID=subnet-07ee4e38
SECURITY_GROUP_ID=sg-0a430b78
NAME_POSTFIX=v1 # change in case of collisions

wget http://download.opensuse.org/repositories/home:/SilvioMoioli:/Terraform:/Images:/AmazonEC2/images/opensuse422.x86_64.raw.xz -O /tmp/opensuse422.x86_64.raw.xz
ec2uploadimg \
  --file ec2utils.conf \
  --account servers \
  --backing-store ssd \
  --description "sumaform opensuse422 image" \
  --grub2 \
  --machine x86_64 \
  --name sumaform-opensuse422-$NAME_POSTFIX \
  --sriov-support \
  --virt-type hvm \
  --root-volume-size 10 \
  --verbose \
  --regions us-east-1 \
  --vpc-subnet-id $PUBLIC_VPC_SUBNET_ID \
  --security-group-ids $SECURITY_GROUP_ID \
  --wait-count 3 \
  /tmp/opensuse422.x86_64.raw.xz

wget http://download.suse.de/ibs/Devel:/Galaxy:/Terraform:/Images:/AmazonEC2/images/sles12sp1.x86_64.raw.xz -O /tmp/sles12sp1.x86_64.raw.xz
ec2uploadimg \
  --file ec2utils.conf \
  --account servers \
  --backing-store ssd \
  --description "sumaform sles12sp1 image" \
  --grub2 \
  --machine x86_64 \
  --name sumaform-sles12sp1-$NAME_POSTFIX \
  --sriov-support \
  --virt-type hvm \
  --root-volume-size 2 \
  --verbose \
  --regions us-east-1 \
  --vpc-subnet-id $PUBLIC_VPC_SUBNET_ID \
  --security-group-ids $SECURITY_GROUP_ID \
  --wait-count 3 \
  /tmp/sles12sp1.x86_64.raw.xz
```

wget http://download.suse.de/ibs/Devel:/Galaxy:/Terraform:/Images:/AmazonEC2/images/sles12sp2.x86_64.raw.xz -O /tmp/sles12sp2.x86_64.raw.xz
ec2uploadimg \
  --file ec2utils.conf \
  --account servers \
  --backing-store ssd \
  --description "sumaform sles12sp2 image" \
  --grub2 \
  --machine x86_64 \
  --name sumaform-sles12sp2-$NAME_POSTFIX \
  --sriov-support \
  --virt-type hvm \
  --root-volume-size 2 \
  --verbose \
  --regions us-east-1 \
  --vpc-subnet-id $PUBLIC_VPC_SUBNET_ID \
  --security-group-ids $SECURITY_GROUP_ID \
  --wait-count 3 \
  /tmp/sles12sp2.x86_64.raw.xz
```
