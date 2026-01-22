# Sysadmin notes

## List for basic setup

- [ ] Add ssh key
- [ ] Configure ssh, [mine](https://raw.githubusercontent.com/ksobrenat32/notes/main/ssh/sshd_config)
- [ ] Enable a firewall
- [ ] Enable zram
- [ ] Configure automatic security updates
- [ ] Setup hostname and timezone
- [ ] If ssd you may enable /tmp on tmpfs

## Add user to use as a service

When you run a service, you should consider using a different user
 in order to not run as root or as a user with access to private
 information. This user does not has shell access and the home is
 usually where the aplication is stored.

```sh
# No storage needed
sudo adduser --home /var/empty/service --system  --shell /sbin/nologin service
# Persistent storage needed
sudo adduser --home /var/lib/service --system  --shell /sbin/nologin service
```

## Change permission

When you want to change permissions on a recursive way, when you
 come across directories you got to be careful because they need
 to have executable permissions in order to be able to explore
 them, but you may not want to give this permissions to the files.

So we use this for directories

```sh
find /dir -type d -exec chmod 755 {} \;
# Readonly
find /dir -type d -exec chmod 500 {} \;
```

And use this for files

```sh
find /dir -type f -exec chmod 644 {} \;
# Read only
find /dir -type f -exec chmod 400 {} \;
```

## Wireguard

For setting up a wireguard server, you need a compatible kernel
 and the wireguard tools, the wireguard config you can build it
 yourself using [this](https://fedoramagazine.org/build-a-virtual-private-network-with-wireguard/)
 just remember that if you need forwarding packets, you should
 allow it in your firewall, in firewalld:

```sh
firewall-cmd --add-forward
firewall-cmd --add-masquerade
```

And to add to your `/etc/sysctl.conf`

```sysctl
net.ipv4.ip_forward=1
net.ipv6.conf.all.forwarding=1
```

## Restore SELINUX context

You can change the SELINUX context to the default of the directory
 it is located with

```sh
sudo restorecon -R file
```

Or you you can fix owner, group and selinux context if it was a path
 created from a rpm package.

```sh
sudo rpm --restore -f /var/lib/path
```

## Smart data

Some notes of the meaning of each smart attribute, this
 just apply to mechanical disks

ATTRIBUTE_NAME | Meaning | Best value
--- | --- | ---
G-SENSE RATE | Impacts detected when the disk was powered on | Lower better
REALOCATE SECTOR COUNTS | The name | Normal to have a few
CURRENT PENDING SECTOR | Bad shutdown | 1 can be fixed
OFFLINE UNCORRECTABLE | Failed sector | More than 0 and the disk is diying
ULTRA DMA CRC ERROR | Problem with the wire or controller | Lower better
LOAD CYCLE COUNT | Head stopped for inativity | Less than 150K
LOAD RETRY COUNT | Head retrying enter the disk | Lower better

## BTRFS - setup with LUKS/dm-crypt and data duplication on single disk

This exemplary initial setup uses one device partition `/dev/sdc1` this
 needs to be a disk more than the double of the size of the data you will
 store, this makes a single drive setup survive data corruption.

WARNING:

- This data duplication may not work with ssds.
- This setup does not survive a full disk failure, remember that one
 copy is not backup
- You need to run constant scrubs to check for corruption and correct it
 before it is irreparable

```sh
# Encrypt partition, remember to use a strong password
cryptsetup --cipher aes-xts-plain64 --key-size 512 --hash sha512 --iter-time 5000 --use-urandom luksFormat /dev/sdc1
# Backup the header, this contains the disk key, 
cryptsetup luksHeaderBackup --header-backup-file /root/sdc1.header.bak /dev/sdc1
# Open luks device
cryptsetup open /dev/sdc1 disk
# Format with btrfs
mkfs.btrfs -d dup -m dup /dev/mapper/disk
# Mount drive with compression
mkdir -p /mnt/disk
mount -o noatime,nodiratime,compress=zstd:6,defaults /dev/mapper/disk /mnt/disk/
```

## Safetely remove a SATA disk from a running system

1. Unmount any filesystems on the disk. (`umount ...`)
2. Deactivate any LVM groups. (`vgchange -an`)
3. Make sure nothing is using the disk for anything.
4. Spin the HDD down. (irrelevant for SSD's) (`hdparm -Y /dev/sdX`)
5. Tell the system, that we are unplugging the HDD. (`echo 1 | sudo tee /sys/block/sdX/device/delete`)

## SELINUX ssh keys on non /home path

If you use `sudo audit2allow -w -a` and see something like this:

```output
avc: denied { read } for pid=13996 comm="sshd" name="authorized_keys" dev="dm-0" i
    "sshd" was denied read on a file resource named "authorized_keys".
scontext=system_u:system_r:sshd_t:s0-s0:c0.c1023
    SELinux context of the sshd process that attempted the denied action.
    tcontext=system_u:object_r:admin_home_t:s0 tclass=file
    SELinux context of the authorized_keys file.
```

Use:

```sh
semanage fcontext --add -t ssh_home_t "/path/to/my/.ssh(/.*)?"
restorecon -FRv /path/to/my/.ssh
```

## Change SSH port with SELINUX

If you want to change ssh default port

```bash
# Change port in config: vim /etc/ssh/sshd_config
dnf install -y policycoreutils-python-utils
semanage port -a -t ssh_port_t -p tcp ${sshport}
systemctl restart sshd.service
firewall-cmd --permanent --remove-service=ssh
firewall-cmd --permanent --add-port=${sshport}/tcp
firewall-cmd --reload
```

## luks trim fedora silverblue

To check if trim is enabled.

```sh
sudo dmsetup table
```

If the output contains allow_discards, its all done, else

```sh
rpm-ostree kargs --append=rd.luks.options=discard
```

## Racknerd SELINUX

Racknerd's VPS RHEL based images do not have SELINUX enabled.

1. Enable NetworkManager

    ```sh
    systemctl enable NetworkManager
    ```

2. Update

    ```sh
    dnf update --allowerasing
    dnf install vim selinux-policy-targeted selinux-policy-devel policycoreutils
    ```

3. Autolabel all files

    ```sh
    touch /.autorelabel
    ```

4. Set SELINUX as permissive for autolabel and reboot

    ```sh
    vim /etc/selinux/config
    reboot
    ```

5. Check status and set enforcing

    ```sh
    sestatus
    vim /etc/selinux/config
    ```

Now you can setup the new user, config ssh, automatic updates,
 etc.

## Firewalld geoblocking

If you only need your service in a certain country it is a good
 idea to block everything except the working zone, to do it:

1. Download the aggregated ips of the countries you need from
 https://www.ipdeny.com/ipblocks/

2. Create an ipset containing all the IPS

    ```sh
    firewall-cmd --permanent --new-ipset=IPs --type=hash:net
    firewall-cmd --permanent --ipset=IPs --add-entries-from-file=1.zone
    firewall-cmd --permanent --ipset=IPs --add-entries-from-file=2.zone
    ```

3. Create a zone with rules for the allowed countries

    ```sh
    firewall-cmd --permanent --new-zone=MYZONE
    firewall-cmd --permanent --zone=MYZONE --add-source=ipset:IPs
    firewall-cmd --permanent --zone=MYZONE --add-service=ssh
    firewall-cmd --permanent --zone=MYZONE --add-port=80/tcp
    firewall-cmd --reload
    ```

4. (Optional) If you dont want to allow anthing else you
 should drop everything by default. *REMEMBER TO KEEP SSH ACCESS*

    ```sh
    firewall-cmd --permanent --zone=public --set-target=DROP
    ```
