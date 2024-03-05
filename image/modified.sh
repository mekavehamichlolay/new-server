#!/bin/bash

version=""
extensions=()

while [[ $# -gt 0 ]]; do
    case "$1" in
        --version)
            shift
            version="$1"
            ;;
        *)
            extensions+=("$1")
            ;;
    esac
    shift
done

if [ -z "$version" ] || [ ${#extensions[@]} -eq 0 ]; then
    echo "Usage: $0 --version <version> <extensions>"
    exit 1
fi

for extension in "${extensions[@]}"; do
    author="wikimedia"
    if [ "$extension" = "TextExtracts" ]; then
        author="mekavehamichlolay"
    fi
    echo "$extension is downloaded from $author"
    git_url="https://github.com/$author/mediawiki-extensions-$extension/archive/refs/heads/REL$version.tar.gz"
    set -eu; \
        cd /var/www/html/w/extensions; \
        wget -q -O "$extension.tar.gz" "$git_url"; \
        [ ! -d "$extension" ] && mkdir -p "./$extension"; \
        tar -xzf "$extension.tar.gz" -C "./$extension" --strip-components 1; \
        chown -R www-data:www-data "./$extension"; \
        rm "$extension.tar.gz"
done

echo "download purge";
set -eu; \
purge=Purge; \
cd /var/www/html/w/extensions; \
wget -q -O $purge.tar.gz https://github.com/AlPha5130/mediawiki-extensions-Purge/archive/refs/heads/master.tar.gz; \
[ ! -d $purge ] && mkdir ./$purge; \
tar -xzf $purge.tar.gz -C ./$purge --strip-components 1; \
rm $purge.tar.gz