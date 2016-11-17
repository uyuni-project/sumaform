#!/bin/bash

export TESTHOST={{ grains.get("server") }}
export CLIENT={{ grains.get("client") }}
export MINION={{ grains.get("minion") }}
export BROWSER=phantomjs

# we have sometimes the issue, that the git salt-formula
# could fail : make sure that we cloned. 
# error: RPC failed; result=56, HTTP code = 200
# fatal: The remote end hung up unexpectedly early EOF

if cd /root/spacewalk-testsuite-base; then
    rake
else
    git clone -b slenkins https://github.com/SUSE/spacewalk-testsuite-base.git /root/spacewalk-testsuite-base
    cd /root/spacewalk-testsuite-base
    rake
fi
