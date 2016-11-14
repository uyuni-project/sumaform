#! /bin/bash

# this script will run the cucumber suite in a jenkins context

terraform get
terraform apply
# HACK: we have to workaround  this issue, right now
# https://github.com/moio/sumaform/issues/11
if [ $? -eq 0 ]; then
   echo "ok, we can test"
else 
   terraform apply
   if [ $? -eq 0 ]; then  
     echo "ok, we can test"
   else 
     echo "FATAL ERROR: something bad with terraform"
     exit 1
   fi   
fi
