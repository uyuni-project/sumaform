#!/bin/bash

cd /srv/www/htdocs/pub/TestRepoDeb
wget -r -np -A deb,dsc,tar.xz,tar.gz,gz,key,Packages,Release,Sources https://download.opensuse.org/repositories/systemsmanagement:/Uyuni:/Ubuntu-Test/xUbuntu_18.04/ 
mv download.opensuse.org/repositories/systemsmanagement\:/Uyuni\:/Ubuntu-Test/xUbuntu_18.04/* .
rm -rf download.opensuse.org

