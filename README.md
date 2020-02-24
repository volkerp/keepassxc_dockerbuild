# Build KeePassXC version 2.5.x RPM for Centos7

As of Feb 2020 no 2.5.x version of keepassxc is available as an rpm.
This here projects builds an rpm in a docker container.

## Requirements

* docker environment (docker host may or may not be centos)

## Usage
```
> ./build.sh
```

This will start an docker image build from *Dockerfile* in the current directory.
After successful build the rpm is extracted from the image and copied to the current directory.

Install with ```sudo yum install keepassxc-*.rpm```. Package *epel-release* must be installed for dependencies.

