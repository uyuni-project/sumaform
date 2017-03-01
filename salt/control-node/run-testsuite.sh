#!/bin/bash

export SSHMINION={{ grains.get("ssh-minion") }}
export CENTOSMINION={{ grains.get("centos-minion") }}
export TESTHOST={{ grains.get("server") }}
export CLIENT={{ grains.get("client") }}
export MINION={{ grains.get("minion") }}
export BROWSER=phantomjs

# phantomjs need suma-server certificate for running secure websockets
if [ ! -f /etc/pki/trust/anchors/$TESTHOST.cert ]; then
  wget http://$TESTHOST/pub/RHN-ORG-TRUSTED-SSL-CERT -O /etc/pki/trust/anchors/$TESTHOST.cert
  update-ca-certificates
fi

cd /root/spacewalk-testsuite-base
rake
