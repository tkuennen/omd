#!/bin/bash

if [ ! -d t ]; then
    echo "please run via 'make test' from the project directory"
    exit 1
fi

if [ $(id -u) -ne 0 ]; then
    echo "please run as root because we need to create test sites"
    exit 1
fi

# do we install a package?
if [ ! -z $OMD_PACKAGE ]; then
    echo "installing " `basename $OMD_PACKAGE`

    # Debian / Ubuntu
    if [ -x /usr/bin/apt-get  ]; then
        apt-get -y install `dpkg-deb --info $OMD_PACKAGE | grep Depends: | sed -e 's/Depends://' -e 's/debconf.*debconf-2.0,//' | tr -d ','`
        dpkg -i $OMD_PACKAGE

    # Centos
    elif [ -x /usr/bin/yum  ]; then
        /usr/bin/yum install -y --nogpgcheck $OMD_PACKAGE

    # Suse
    elif [ -x /usr/bin/zypper  ]; then
        /usr/bin/zypper install -n -l --no-recommends $OMD_PACKAGE
    fi
fi

if [ -z $OMD_BIN ]; then
    OMD_BIN=destdir/usr/bin/omd
fi

OMD_BIN=$OMD_BIN PERL_DL_NONLAZY=1 /usr/bin/env perl "-MExtUtils::Command::MM" "-e" "test_harness(0)" t/*.t
