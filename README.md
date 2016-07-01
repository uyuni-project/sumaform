# sumaform

![Sumicform, a green hedgehog made of bricks, sumaform's mascot](help/sumicform.png)

Sumaform is a way to quickly configure test SUSE Manager setups with clients and servers.

It got its [portmanteau](https://en.wikipedia.org/wiki/Portmanteau) name being the successor of [suminator](https://github.com/SUSE/suminator/) implemented as [Terraform](https://www.terraform.io/) modules.

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

## Upload OpenStack images via Glance

Unfortunately, Terraform does not have support for [OpenStack Glance](http://docs.openstack.org/developer/glance/).
Thus, we manually have to upload our images to Glance.

* install the `glance` command on your distribution:
  * SLES and openSUSE:
  ```
  # replace <DISTRO> with SLE_12_SP2, openSUSE_Leap_42.1 or openSUSE_Tumbleweed
  zypper addrepo http://download.opensuse.org/repositories/Cloud:OpenStack:Master/<DISTRO>/Cloud:OpenStack:Master.repo
  zypper refresh
  zypper install python-glanceclient
  ```
  * Ubuntu:
  ```
  sudo apt install python-glanceclient
  ```
* customize and run `openstack_images/upload_images_to_glance.sh.example` to upload images to OpenStack through Glance.
