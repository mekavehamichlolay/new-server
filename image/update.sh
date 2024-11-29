#!/bin/bash

## This script is used to update the AspaklaryaLockDown extension in running container

version=$1

if [ -z "$version" ]; then
    echo "Usage: $0 <version>"
    exit 1
fi

# Download the extension to a temporary directory
set -eu; \
tmp_dir=$(mktemp -d); \
cd $tmp_dir; \
wget -q -O AspaklaryaLockDown.tar.gz https://github.com/mekavehamichlolay/AspaklaryaLockdown/archive/refs/heads/REL$version.tar.gz; \
tar -xzf AspaklaryaLockDown.tar.gz --strip-components 1; \
rm AspaklaryaLockDown.tar.gz; \
rm -rf /var/www/html/w/extensions/AspaklaryaLockDown; \
mv $tmp_dir /var/www/html/w/extensions/AspaklaryaLockDown
chown -R www-data:www-data /var/www/html/w/extensions/AspaklaryaLockDown