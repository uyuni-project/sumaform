#!/bin/bash

set -e

DIR=/srv/www/htdocs/pub/$1
mkdir -p $DIR
cd $DIR
wget -r -np -A deb,dsc,tar.xz,tar.gz,gz,key,Packages,Release,Sources http://$2
mv $2/* .
HOST=$(echo $2 | awk -F/ '{print $1}')
if [ -n "$HOST" -a x"$HOST" != "x/" ]; then
  rm -rf "$HOST"
fi

