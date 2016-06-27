$ pip install puthon-openstack-client
$ pip install python-glanceclient
$ export OS_USERNAME=...
$ export OS_PASSWORD=...
$ export OS_TENANT_ID=openstack
$ export OS_AUTH_URL=***REMOVED***
$ glance image-create --name test-sumaform-sp11 --disk-format=qcow2 --container-format=bare --visibility=public --file sles11sp3.x86_64.qcow2
