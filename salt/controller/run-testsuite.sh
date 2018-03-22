#!/bin/bash

set -e

cd /root/spacewalk/testsuite

if [ -z "$1" ]; then
   rake
fi
# this to run cucumber features in parallel
if [[ $1 = "parallel" ]]; then
   rake core
   rake secondary_parallel
   rake post_run
fi
