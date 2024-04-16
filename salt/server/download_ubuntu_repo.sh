#!/bin/bash

set -euo pipefail

DIRECTORY="/srv/www/htdocs/pub/${1}"
OPENSUSE_REPOSITORY_URL="${2}"
EXTENSIONS=(".deb" ".dsc" ".tar.xz" ".tar.gz" ".gz" ".key" ".gpg" "Packages" "Release" ".Sources")

if [ ! -d "${DIRECTORY}" ]; then
  mkdir --parents "${DIRECTORY}"
fi

files=$(
    curl --silent "${OPENSUSE_REPOSITORY_URL}" | \
    grep --only-matching --perl-regexp '<td\s+class="name"><a\s+href=".*?">(.*?)</a></td>' | \
    sed -r 's/<[^>]*>//g'
)

for filename in ${files[@]}; do
    for extension in ${EXTENSIONS[@]}; do
        if [[ $filename == *"$extension"* ]]; then
            curl --output "${DIRECTORY}/$filename" "${OPENSUSE_REPOSITORY_URL}/$filename"
        fi
    done
done
