#!/bin/bash

set -e

cd /root/spacewalk/testsuite

if [ -z "$1" ]; then
   rake
fi
# this to run cucumber features in parallel
if [[ $1 = "parallel" ]]; then
   rake cucumber:core
   rake parallel:init_clients
   rake cucumber:secondary
   rake parallel:secondary_parallelizable
   rake cucumber:finishing
fi
