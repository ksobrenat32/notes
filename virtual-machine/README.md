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
apt install qemu qemu-kvm qemu-system qemu-utils libvirt-clients libvirt-daemon-system virtinst virt-manager bridge-utils
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
- [CentOS-stream8](http://mirror.centos.org/centos/8-stream/BaseOS/x86_64/os/)
- [CentOS-stream9](http://mirror.stream.centos.org/9-stream/BaseOS/x86_64/os/)
- [Rocky Linux 8.5](https://dl.rockylinux.org/pub/rocky/8.5/BaseOS/x86_64/os/)
- [Fedora Server 35](https://mirror.umd.edu/fedora/linux/releases/35/Server/x86_64/os/)

## Converting from raw to qcow2

For converting raw (in this case a linux volume) to a qcow2 we
 must sparse it, so it does not use lots of space, in order to
 do this, first of all we need to install `libguestfs-tools-c`

 ``` sh
sudo dnf install libguestfs-tools-c
 ```

With that it will be installed the tool `virt-sparsify`, that is
 the one we need. Now we need to be sure that out /tmp directory
 is bigger than the raw image we are converting, may mount other
 drive in /tmp.

In orther to do the convertion, we can use

```sh
sudo virt-sparsify /dev/mapper/VG-VM --convert qcow2 /out/VM.qcow2 --check-tmpdir fail
```

The last flag is to check if the size of /tmp is enough.
