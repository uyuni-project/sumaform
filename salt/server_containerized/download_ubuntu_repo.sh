#!/bin/bash

set -e

DIR=$1/htdocs/pub/$2
mkdir -p $DIR
cd $DIR
wget -r -np -A deb,dsc,tar.xz,tar.gz,gz,key,gpg,Packages,Release,Sources http://$3
mv $3/* .
HOST=$(echo $3 | awk -F/ '{print $1}')
if [ -n "$HOST" -a x"$HOST" != "x/" ]; then
  rm -rf "$HOST"
fi

