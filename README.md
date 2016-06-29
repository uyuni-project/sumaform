# Sumaform = Suminator + Terraform

Hackweek 2016 Project

## Getting started

    % git clone gitlab@gitlab.suse.de:mbologna/sumaform.git
    % cd sumaform
    % export OS_USERNAME="foo" # your SUSE NIS username
    % export OS_PASSWORD="s3kr1t" # your SUSE NIS PASSWORD
    % terraform plan # show the provisioning plan
    % terraform apply # bring up your systems, fasten your seatbelts!

## Openstack images (glance)

Unfortunately, terraform does not have support for glance (image handling in openstack).
Thus, we manually have to upload our image to glance (different formats available, our take: qcow2).
In order to do this, you have to launch the following commands:

    $ pip install python-openstack-client
    $ pip install python-glanceclient
    $ export OS_USERNAME=...
    $ export OS_PASSWORD=...
    $ export OS_TENANT_ID=openstack
    $ export OS_AUTH_URL=***REMOVED***
    $ glance image-create --name <image_name> --disk-format=qcow2 --container-format=bare --visibility=public --file <image_filename>.qcow2
