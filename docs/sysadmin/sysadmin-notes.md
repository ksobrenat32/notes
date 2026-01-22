# Sysadmin notes

## List for basic setup

- [ ] Add ssh key
- [ ] Configure ssh
- [ ] Enable a firewall
- [ ] Enable zram
- [ ] Configure automatic security updates
- [ ] Setup hostname and timezone
- [ ] If ssd you may enable /tmp on tmpfs

## Tips and tricks

### Add user to use as a service

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

### Change permission

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

## Smartmontools

### Commands

- Show all info

```sh
sudo smartctl -a /dev/sdX
```

- Run a short test

```sh
sudo smartctl -t short /dev/sdX
```

- Run a long test

```sh
sudo smartctl -t long /dev/sdX
```

### Understanding SMART attributes

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

## Disks

### Luks

**To open a luks encrypted disk**

```sh
cryptsetup open /dev/sdX name
```

**Encrypt a disk with luks**

```sh
cryptsetup --cipher aes-xts-plain64 --key-size 512 --hash sha512 --iter-time 5000 --use-urandom luksFormat /dev/sdXn
```

**Header backup**

```sh
cryptsetup luksHeaderBackup --header-backup-file /root/sdXn.header.bak /dev/sdXn
```

### Safetely remove a SATA disk from a running system

1. Unmount any filesystems on the disk. (`umount ...`)
2. Deactivate any LVM groups. (`vgchange -an`)
3. Make sure nothing is using the disk for anything.
4. Spin the HDD down. (irrelevant for SSD's) (`hdparm -Y /dev/sdX`)
5. Tell the system, that we are unplugging the HDD. (`echo 1 | sudo tee /sys/block/sdX/device/delete`
