# Useful things for my backups

## telegram-cli

``` bash
telegram-cli -W --exec 'msg <channel or user> '"the message"
telegram-cli -W --exec 'send_file <channel or user> '/path/to/file/to/send
```

- Use the "-W" flag for updating tha contacts list.

## tar and xz

``` bash
tar -cJf <the name of the compressed file>.tar.xz /path/to/directorie/1 /path/to/directorie/2
```

- Use "-J" to use the xz protocol.
- Use "-cf" to create a new file.

## gpg

``` bash
gpg -e -r <recipient> /path/to/file/to/encrypt
```

- Use "-e" to encrypt
- Use "-r" to specify the recipient

## sha256

``` bash
sha256sum /path/to/file > /path/to/file.sha256
```

- Generate a sha256 hash from the file

## rsync

``` bash
rsync -arzuvhP --ignore-existing /path/to/source /path/to/destiny
```

- "a" for archive mode
- "r" for recursive
- "z" for compression on transit (useful in network)
- "u" for skipping files newer on receiver
- "h" for human readable
- "P" for progress
- "c" for checksum

> "-n" for dry run

## BTRFS with luks

### To mount

``` bash
sudo cryptsetup luksOpen /dev/sda/ orig
sudo cryptsetup luksOpen /dev/sdb1/ dest

sudo mount -o noatime,nodiratime,compress=zstd,defaults /dev/mapper/orig /mnt/orig
sudo mount -o noatime,nodiratime,compress=zstd,defaults /dev/mapper/dest /mnt/dest
```

### Taking snapshot

``` bash
cd /mnt/orig
sudo btrfs subvolume snapshot -r data/ backup-snapshots/data-$(date -I)
```

### Sending incremental snapshot

``` bash
sudo btrfs send -p /mnt/orig/backup-snapshots/data-(previous) /mnt/orig/backup-snapshots/data-(today) | sudo btrfs receive /mnt/dest/backup-snapshots &
```

### Delete old snapshots

``` bash
sudo btrfs su delete /mnt/backup-snapshots/data-(day-to-delete)
```

### BTRFS Guide

Cloned from [Moeser's guide](https://gist.github.com/Moeser/783c2e028a8402806771d5ddecdab76b)

#### Initial setup with LUKS/dm-crypt

This exemplary initial setup uses two devices `/dev/sdb` and
 `/dev/sdc` but can be applied to any amount of devices by
 following the steps with additional devices.

Create keyfile:

```sh
dd bs=64 count=1 if=/dev/urandom of=/etc/cryptkey iflag=fullblock
chmod 600 /etc/cryptkey
```

Encrypt devices:

```sh
cryptsetup -v -c aes-xts-plain64 -h sha512 -s 512 luksFormat /dev/sdb /etc/cryptkey
cryptsetup -v -c aes-xts-plain64 -h sha512 -s 512 luksFormat /dev/sdc /etc/cryptkey
```

Backup LUKS header:

```sh
cryptsetup luksHeaderBackup --header-backup-file ~/sdb.header.bak /dev/sdb
cryptsetup luksHeaderBackup --header-backup-file ~/sdc.header.bak /dev/sdc
```

Automatically unlock LUKS devices on boot by editing `/etc/crypttab`:

```sh
data1 UUID=xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx /etc/cryptkey luks,noearly #,discard (for SSDs)
data2 UUID=xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx /etc/cryptkey luks,noearly #,discard (for SSDs)
# Use 'blkid /dev/sdb' to get the UUID
```

Unlock encrypted devices now to create the filesystem in next step:

```sh
cryptsetup open --key-file=/etc/cryptkey --type luks /dev/sdb data1
cryptsetup open --key-file=/etc/cryptkey --type luks /dev/sdc data2
```

Create filesystem:

```sh
mkfs.btrfs -m raid1 -d raid1 /dev/mapper/data1 /dev/mapper/data2
```

(Add the fstab entry first, and the mount command is vastly simplified)
Automatically mount btrfs filesystem on boot by editing `/etc/fstab`:

```sh
/dev/mapper/data1 /mnt/data btrfs defaults,noatime,compress=zstd 0 2
# Add option 'autodefrag' to allow automatic defragmentation:
# useful for files with lot of random writes like databases or virtual machine images
```

Mount filesystem:

```sh
mount /mnt/data
```

#### Recovery from device failure

Example with one failed device:

- `/dev/mapper/data1` working device
- `/dev/mapper/data2` failed device
- `/dev/mapper/data3` new device
- `/mnt/data` mountpoint

In case of failing/failed device, mount in degraded mode with the working device:

```sh
mount -t btrfs -o defaults,noatime,compress=zstd,degraded /dev/mapper/data1 /mnt/data
```

(Remove missing devices first if you want to replace the same
 drive) Remove the missing device (NOTE: `missing` is a special
 device name and not a placeholder):

```sh
btrfs device delete missing /mnt/data
```

NOTE: Encrypt the new device before using it in the btrfs raid by
 following the steps above. Add new device to btrfs raid:

```sh
btrfs device add /dev/mapper/data3 /mnt/data
```

Re-balance data of btrfs raid:

```sh
btrfs balance start /mnt/data
```

The fstab entry is left unmodified with one of the working devices:

```fstab
/dev/mapper/data1 /mnt/data btrfs defaults,noatime,compress=zstd 0 2
```
