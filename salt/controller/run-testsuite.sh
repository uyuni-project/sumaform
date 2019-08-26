#!/bin/bash

set -e

cd /root/spacewalk/testsuite

if [ -z "$1" ]; then
   rake cucumber:core
   rake cucumber:reposync
   rake cucumber:init_clients
   rake cucumber:secondary
   rake cucumber:secondary_parallelizable
   rake cucumber:finishing
fi

# this to run cucumber features in refhost
if [[ $1 = "refhost" ]]; then
   rake cucumber:refhost
fi

# this to run cucumber features in virtualization
if [[ $1 = "virtualization" ]]; then
   rake cucumber:virtualization
fi

# this to run cucumber features in sle-updates
if [[ $1 = "sle-updates" ]]; then
   rake cucumber:sle-updates
fi

# this to run cucumber features in parallel
if [[ $1 = "parallel" ]]; then
   rake cucumber:core
   rake cucumber:reposync
   rake parallel:init_clients
   rake cucumber:secondary
   rake parallel:secondary_parallelizable
   rake cucumber:finishing
fi
