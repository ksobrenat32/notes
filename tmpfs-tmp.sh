#! /bin/bash

## This script needs to be run as root
## This script enables a zram module, it asks for the size.

function use-root () {
    	if ! [[ "$(id -u)" = 0 ]]; then
    	echo "Error, this script needs to be run as root"
    	exit 127
	fi
}

##----Script-----

echo 'This script makes your /tmp run on a tmpfs'
use-root
echo "What will be the limit size?"
    select option in "100M" "512M" "1024M" "2048M" "4096M"; do
        case $option in
        100M ) echo 'tmpfs /tmp tmpfs mode=1777,nosuid,nodev,defaults,noatime,size=100M 0 0' >> /etc/fstab ; break;;
        512M ) echo 'tmpfs /tmp tmpfs mode=1777,nosuid,nodev,defaults,noatime,size=512M 0 0' >> /etc/fstab ; break;;
        1024M ) echo 'tmpfs /tmp tmpfs mode=1777,nosuid,nodev,defaults,noatime,size=1024M 0 0' >> /etc/fstab ; break;;
        2048M ) echo 'tmpfs /tmp tmpfs mode=1777,nosuid,nodev,defaults,noatime,size=2048M 0 0' >> /etc/fstab ; break;;
        4096M ) echo 'tmpfs /tmp tmpfs mode=1777,nosuid,nodev,defaults,noatime,size=4096M 0 0' >> /etc/fstab ; break;;
        esac
done
echo 'done!'