#!/bin/bash

sync_repos()
{
  test -z "$SERVER" && { echo "SERVER not set" ; exit 1 ; }
  repos=`salt-call --out txt --local --file-root=/root/salt grains.get repos_to_sync  | cut -d' ' -f2- 2>/dev/null`

  if [ -n "$repos" ]; then
    cmd="ssh -o StrictHostKeyChecking=no $SERVER \"spacewalk-repo-sync --latest --type yum"
    for i in $repos ; do
      cmd="$cmd --channel $i"
    done
    cmd="$cmd\""
    echo "syncing repos '$repos' on server"
    eval $cmd
  fi
}

set -e

cd /root/spacewalk/testsuite

if [ -z "$1" ]; then
   rake cucumber:core
   rake cucumber:reposync
   sync_repos
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
   sync_repos
   rake parallel:init_clients
   rake cucumber:secondary
   rake parallel:secondary_parallelizable
   rake cucumber:finishing
fi
