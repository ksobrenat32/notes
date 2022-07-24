# Notes for creating virtual machines

## Configuring virsh for non-root user

1. Add your user to group libvirt
2. Write the configuration to ~/.config/libvirt/libvirt.conf

```bash
sudo usermod -a -G libvirt user
mkdir -p ~/.config/libvirt/
echo 'uri_default = "qemu:///system"' | tee -a ~/.config/libvirt/libvirt.conf
```

## Enable Virtualization

For installing virtual machines without graphics we need
 to have some things installed and then enable libvirt daemon

```bash
apt install qemu qemu-kvm qemu-system qemu-utils \
    libvirt-clients libvirt-daemon-system virtinst \
    virt-manager bridge-utils
# or
dnf install @virtualization
systemctl enable libvirtd
```

## Create a disk image for the virtual machine

```bash
qemu-img create -f qcow2 ./name.qcow2 8G
```

## Run the virtual machine from serial with virt install

The important thing is using some parameters with the
 virt install, disable the graphics and enable a serial console.

```bash
--graphics none \
--console pty,target_type=serial \
--extra-args 'console=ttyS0,115200n8 serial'
```

For the os-variant parameter, we need to know the system
 supported variants, you can do so with

```bash
osinfo-query os
```

If you are using an ISO, you can use the cdrom parameter

```bash
--cdrom ./example.iso \
```

### Debian example

```bash
virt-install \
    --name debian11 \
    --memory 1024 \
    --disk path=./debian10.qcow2,size=8,format=qcow2,bus=virtio \
    --cpu host \
    --virt-type kvm \
    --vcpus 1 \
    --os-type linux \
    --os-variant debian11 \
    --network bridge=virbr0,model=virtio \
    --graphics none \
    --console pty,target_type=serial \
    --location 'http://your.url/installer' \
    --extra-args 'console=ttyS0,115200n8 serial'
```

### URLS

You may need to change architecture if running on aarch64

- [Debian Stable](http://ftp.debian.org/debian/dists/stable/main/installer-amd64/)
- [Debian OldStable](http://ftp.debian.org/debian/dists/oldstable/main/installer-amd64/)
- [Debian Testing](http://ftp.debian.org/debian/dists/testing/main/installer-amd64/)
- [CentOS-stream9](http://mirror.stream.centos.org/9-stream/BaseOS/x86_64/os/)
- [Rocky Linux 9](https://dl.rockylinux.org/pub/rocky/9/BaseOS/x86_64/os/)
- [Fedora Everything 36](https://mirror.umd.edu/fedora/linux/releases/36/Everything/x86_64/os/)

## Converting from raw to qcow2

For converting raw (in this case a linux volume) to a qcow2 we
 must sparse it, so it does not use lots of space, in order to
 do this, first of all we need to install `libguestfs-tools-c`

 ``` sh
dnf install libguestfs-tools-c
 ```

With that it will be installed the tool `virt-sparsify`, that is
 the one we need. Now we need to be sure that out /tmp directory
 is bigger than the raw image we are converting, may mount other
 drive in /tmp.

In orther to do the convertion, we can use

```sh
virt-sparsify /dev/mapper/VG-VM --convert qcow2 /out/VM.qcow2 --check-tmpdir fail
```

The last flag is to check if the size of /tmp is enough.

## Mount qcow2 image

For mounting:

```sh
modprobe nbd max_part=8
qemu-nbd --connect=/dev/nbd0 ./image.qcow2
fdisk /dev/nbd0 -l
mount /dev/nbd0p1 /mnt
```

For unmounting:

```sh
umount /mnt/somepoint/
qemu-nbd --disconnect /dev/nbd0
rmmod nbd
```

## Mount raw image or linux volume

Create a loop device with

```sh
losetup -f -P raw.img
```

You can see the open files with:

```sh
losetup -l
fdisk -l
```

And mount it with:

```sh
mount /dev/loop0p1 /mnt/mypartition
```

For unmounting and closing:

```sh
umount /mnt/mypartition
losetup -d /dev/loop0p1
```

## Mount with virtiofsd

I had a problem, I needed to mount a btrfs disk on a rhel9 vm,
 this is not supported, so I thought it would be a great idea
 to mount it on the Debian host and share it with virtiofsd,
 supporting selinux and all of that, it may not be the most
 secure way and it has some problems, so use it at your own
 risk.

### Upgrade Debian libvirt packages

Debian 11 bullseye has an old libvirt package, so you need to
 upgrade them from backports, the packages are `qemu qemu-kvm
 qemu-system qemu-utils libvirt-clients libvirt-daemon-system
 virtinst` and after the upgrade you should restart libvirtd

### Run virtiofsd as a systemd service

In order to run virtiofsd in a socket, you should run it separated
 this can be done with a systemd service:

```service
[Unit]
Description=Virtiofsd for sharing disk WD-WX32D5143K0L
Documentation=https://gitlab.com/virtio-fs/virtiofsd

[Service]
ExecStart=/usr/lib/qemu/virtiofsd --socket-path=/var/virtiofsd.sock \
    --socket-group=libvirt-qemu -o xattr,source="/mnt/Disk",\
    xattrmap=":map:security.selinux:trusted.virtiofs.:",modcaps=+sys_admin

 [Install]
WantedBy=multi-user.target
```

The extra options are 'xattr' for enabling those, 'source'
 to declare the dir to share, 'xattrmap' so you can have
 different selinux context on the host and the guest,
 'modcaps' so it is able to set trusted xattr. The service
 should run as root.

### Add the xml to the vm

With `virsh edit` you should edit the domain xml to declare the
 socket

```xml
<filesystem type='mount'>
  <driver type='virtiofs' queue='1024'/>
  <source socket='/var/virtiofsd.sock'/>
  <target dir='myDisk'/>
  <alias name='fs0'/>
  <address type='pci' domain='0x0000' bus='0x07' slot='0x00' function='0x0'/>
</filesystem>
```
