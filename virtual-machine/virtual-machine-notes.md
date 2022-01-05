# Notes for creating virtual machines

## Configuring virsh for non-root user

1. Add your user to group libvirt

    sudo usermod -a -G libvirt user

2. Write the configuration to ~/.config/libvirt/libvirt.conf

    mkdir -p ~/.config/libvirt/

    echo 'uri_default = "qemu:///system"' | tee -a ~/.config/libvirt/libvirt.conf

## Enable Virtualization

For installing virtual machines without graphics we need
 to have some things installed. For debian:

    apt install qemu qemu-kvm qemu-system qemu-utils libvirt-clients libvirt-daemon-system virtinst virt-manager bridge-utils

And enable libvirt daemon

    systemctl enable libvirtd

## Create a disk image for the virtual machine

    qemu-img create -f qcow2 ./name.qcow2 8G

## Run the virtual machine from serial with virt install

The important thing is using some parameters with the
 virt install, disable the graphics and enable a serial console.

    --graphics none \
    --console pty,target_type=serial \
    --extra-args 'console=ttyS0,115200n8 serial'

For the os-variant parameter, we need to know the system
 supported variants, you can do so with

    osinfo-query os

If you are using an ISO, you can use the cdrom parameter

    --cdrom ./example.iso \

### Debian example

    virt-install \
        --name debian11 \
        --memory 1024 \
        --disk path=./debian10.qcow2,size=8,format=qcow2,bus=virtio \
        --cpu host \
        --vcpus 1 \
        --os-type linux \
        --os-variant debian11 \
        --network bridge=virbr0,model=virtio \
        --graphics none \
        --console pty,target_type=serial \
        --location 'http://ftp.debian.org/debian/dists/stable/main/installer-amd64/' \
        --extra-args 'console=ttyS0,115200n8 serial'

### URLS

- [Debian Stable](http://ftp.debian.org/debian/dists/stable/main/installer-amd64/)
- [Debian OldStable](http://ftp.debian.org/debian/dists/oldstable/main/installer-amd64/)
- [Debian Testing](http://ftp.debian.org/debian/dists/testing/main/installer-amd64/)
- [CentOS-stream8](http://mirror.centos.org/centos/8-stream/BaseOS/x86_64/os/)
- [CentOS-stream9](http://mirror.stream.centos.org/9-stream/BaseOS/x86_64/os/)
- [Rocky Linux 8.5](https://dl.rockylinux.org/pub/rocky/8.5/BaseOS/x86_64/os/)
