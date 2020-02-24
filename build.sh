#! /bin/bash

KPVERSION=2.5.3
DESTDIR=/opt/keepassxc

# build rpm inside container
docker build --build-arg VERSION=${KPVERSION} --build-arg DESTDIR=${DESTDIR} -t keepassxc .

# need to create dummy container to extract the rpm
docker create -ti --name keepassxc_dummy keepassxc bash
docker cp keepassxc_dummy:/root/rpmbuild/RPMS/x86_64/keepassxc-${KPVERSION}-1.el7.x86_64.rpm .
docker rm -f keepassxc_dummy

ls -l ./keepassxc-${KPVERSION}-1.el7.x86_64.rpm

