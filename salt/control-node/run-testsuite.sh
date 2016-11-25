#!/bin/bash

export TESTHOST={{ grains.get("server") }}
export CLIENT={{ grains.get("client") }}
export MINION={{ grains.get("minion") }}
export BROWSER=phantomjs
BRANCH="{{ grains.get("branch") }}"

if [ ${BRANCH} == "refhost30" ]  ||  [ ${BRANCH} == "refhost-head" ]; then rake cucumber:refhost ; exit 0 ; fi
cd /root/spacewalk-testsuite-base
rake
