# Sysadmin notes

## Add user to use as a service

When you run a service, you should consider using a different user
 in order to not run as root or as a user with access to private
 information. This user does not has shell access and the home is
 usually where the aplication is stored.

```sh
sudo adduser --home /opt/service --system  --shell /sbin/nologin service
```

## Change permission

When you want to change permissions on a recursive way, when you
 come across directories you got to be careful because they need
 to have executable permissions in order to be able to explore
 them, but you may not want to give this permissions to the files.

So we use this for directories

```sh
find /dir -type d -exec chmod 755 {} \;
```

And use this for files

```sh
find /dir -type f -exec chmod 644 {} \;
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
