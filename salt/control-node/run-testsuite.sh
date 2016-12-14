#!/bin/bash

export CENTOSMINION={{ grains.get("centos-minion") }}
export TESTHOST={{ grains.get("server") }}
export CLIENT={{ grains.get("client") }}
export MINION={{ grains.get("minion") }}
export BROWSER=phantomjs

cd /root/spacewalk-testsuite-base
rake
