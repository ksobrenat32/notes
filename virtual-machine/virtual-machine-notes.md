For using virsh without root, add your user to group libvirt

	sudo usermod -a -G libvirt user

# Headless vm

For installing virtual machines without graphics appart from libvirt, kvm,qemu and their dependencies,we need virt-install, and qemu-img.
 
### Create a disk image for the virtual machine

    qemu-img create -f qcow2 ./name.qcow2 8G

Change the size and name

### Run the virtual machine from serial with virt install.

The important thing is using some parameters with the virt install, disable the graphics and enable a serial console.

    --graphics none \
    --console pty,target_type=serial \
    --extra-args 'console=ttyS0,115200n8 serial'

For the os-variant parameter, we need to know the system supported variants, you can do so with 

    osinfo-query os

If you are using an ISO, you can use the cdrom parameter

    --cdrom ./example.iso \


#### Debian example

    virt-install \
        --name debian10 \
        --memory 1024 \
        --disk path=./debian10.qcow2,size=8,format=qcow2,bus=virtio \
        --cpu host \
        --vcpus 1 \
        --os-type linux \
        --os-variant debian10 \
        --network bridge=virbr0,model=virtio \
        --graphics none \
        --console pty,target_type=serial \
        --location 'http://ftp.debian.org/debian/dists/buster/main/installer-amd64/' \
        --extra-args 'console=ttyS0,115200n8 serial'

#### Centos example

    virt-install \
        --name centos-stream8 \
        --memory 2048 \
        --disk path=./centos-stream8.qcow2,size=10,format=qcow2,bus=virtio \
        --vcpus 1 \
        --os-type linux \
        --os-variant centos-stream8 \
        --network bridge=virbr0,model=virtio \
        --graphics none \
        --console pty,target_type=serial \
        --location 'https://mirror.arizona.edu/centos/8-stream/BaseOS/x86_64/os/' \
        --extra-args 'console=ttyS0,115200n8 serial'
