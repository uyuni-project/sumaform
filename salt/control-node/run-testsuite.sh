#!/bin/bash

export TESTHOST={{ grains.get("server") }}
export CLIENT={{ grains.get("client") }}
export MINION={{ grains.get("minion") }}
export BROWSER=phantomjs
BRANCH="{{ grains.get("branch") }}"

cd /root/spacewalk-testsuite-base
if [ ${BRANCH} == "refhost30" ]  ||  [ ${BRANCH} == "refhost" ]; then rake cucumber:refhost ; exit 0 ; fi
# HEAD and 3.0 branch are same for moment.
rake
