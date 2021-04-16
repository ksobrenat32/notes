#! /bin/bash

## This script needs to be run as root
## This script enables a zram module, it asks for the size.

function use-root () {
    	if ! [[ "$(id -u)" = 0 ]]; then
    	echo "Error, this script needs to be run as root"
    	exit 127
	fi
}

function s-size () {
	echo "Select a size"
    select option in "512M" "1024M" "2048M" "3072M" "4096M" ; do
        case $option in
        512M ) echo 'KERNEL=="zram0", ATTR{disksize}="512M",TAG+="systemd"' >> /etc/udev/rules.d/99-zram.rules ; break;;
        1024M ) echo 'KERNEL=="zram0", ATTR{disksize}="1024M",TAG+="systemd"' >> /etc/udev/rules.d/99-zram.rules ; break;;
        2048M ) echo 'KERNEL=="zram0", ATTR{disksize}="2048M",TAG+="systemd"' >> /etc/udev/rules.d/99-zram.rules ; break;;
        3072M ) echo 'KERNEL=="zram0", ATTR{disksize}="3072M",TAG+="systemd"' >> /etc/udev/rules.d/99-zram.rules ; break;;
        4096M ) echo 'KERNEL=="zram0", ATTR{disksize}="4096M",TAG+="systemd"' >> /etc/udev/rules.d/99-zram.rules ; break;;
	esac
done
}

function zram () {
	s-size
	echo 'zram' >> /etc/modules-load.d/zram.conf
	echo 'options zram num_devices=1' >> /etc/modprobe.d/zram.conf
cat >> /etc/systemd/system/zram.service <<EOF
[Unit]
Description=Swap with zram
After=multi-user.target

[Service]
Type=oneshot 
RemainAfterExit=true
ExecStartPre=/sbin/mkswap /dev/zram0
ExecStart=/sbin/swapon /dev/zram0
ExecStop=/sbin/swapoff /dev/zram0

[Install]
WantedBy=multi-user.target
EOF
	systemctl enable zram
	echo 'You need to reboot and you should disable the swap partition from fstab'
}

##------Script---------

echo 'This script enables a zram module'
use-root
zram
echo 'done'
