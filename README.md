# Sumaform = Suminator + Terraform

Hackweek 2016 Project

## Getting started

```
git clone gitlab@gitlab.suse.de:mbologna/sumaform.git
cd sumaform

# if using the OpenStack backend
export OS_USERNAME="foo"
export OS_PASSWORD="s3kr1t"

terraform plan # show the provisioning plan
terraform apply # bring up your systems, fasten your seatbelts!
```

## Upload OpenStack images (glance)

Unfortunately, terraform does not have support for glance (image handling in
OpenStack).
Thus, we manually have to upload our image to glance (different formats
available, our take: qcow2).

### Installation

#### SLES 12 SP2

```
zypper addrepo http://download.opensuse.org/repositories/Cloud:OpenStack:Master/SLE_12_SP2/Cloud:OpenStack:Master.repo
zypper refresh
zypper install python-glanceclient
```

#### SLES 12 SP1

```
zypper addrepo http://download.opensuse.org/repositories/Cloud:OpenStack:Master/SLE_12_SP1/Cloud:OpenStack:Master.repo
zypper refresh
zypper install python-glanceclient
```

#### OpenSUSE

##### Tumbleweed

```
zypper addrepo http://download.opensuse.org/repositories/Cloud:OpenStack:Master/openSUSE_Tumbleweed/Cloud:OpenStack:Master.repo
zypper refresh
zypper install python-glanceclient
```

##### Leap 42.1

```
zypper addrepo http://download.opensuse.org/repositories/Cloud:OpenStack:Master/openSUSE_Leap_42.1/Cloud:OpenStack:Master.repo
zypper refresh
zypper install python-glanceclient
```

#### Ubuntu

```
sudo apt install python-glanceclient
```

<!-- ##### Compile it from source

```
sudo pip install virtualenv
cd sumaform
virtualenv sumaform-env
source sumaform-env/bin/activate
pip install python-openstackclient
pip install python-glanceclient
```

#### Usage

Then you have to customize and run the supplied script:
`openstack_images/upload_images_to_glance.sh.example`
(be sure to customize it with your credentials and rename it to
`upload_images_to_glance.sh`).

Launch it and your images will be uploaded to OpenStack glance.
-->
