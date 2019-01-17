#!/bin/bash

DIR=/srv/www/htdocs/pub/$1
mkdir -p $DIR
cd $DIR
wget -r -np -A deb,dsc,tar.xz,tar.gz,gz,key,Packages,Release,Sources https://$2
mv $2/* .
rm -rf download.opensuse.org

