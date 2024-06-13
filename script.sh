#!/bin/bash

cd /var/www/html/ubuntu/mirror/archive.ubuntu.com/ubuntu/dists

for dist in jammy jammy-updates jammy-security jammy-backports; do
  for comp in main multiverse universe; do
    for size in 48 64 128; do
    wget http://archive.ubuntu.com/ubuntu/dists/$dist/$comp/dep11/icons-${size}x${size}@2.tar.gz -O $dist/$comp/dep11/icons-${size}x${size}@2.tar.gz;
   done
 done
done

cd /var/tmp
for p in "${1:-jammy}"{,-{security,updates,backports}}/{main,restricted,universe,multiverse}; do
    >&2 echo "${p}"
wget -q -c -r -np -R "index.html*" "http://archive.ubuntu.com/ubuntu/dists/${p}/cnf/Commands-amd64.xz"
wget -q -c -r -np -R "index.html*" "http://archive.ubuntu.com/ubuntu/dists/${p}/cnf/Commands-i386.xz"
wget -q -c -r -np -R "index.html*" "http://archive.ubuntu.com/ubuntu/dists/${p}/binary-i386/"
done

sudo cp -av archive.ubuntu.com/ubuntu/ /var/www/html/ubuntu/mirror/archive.ubuntu.com
