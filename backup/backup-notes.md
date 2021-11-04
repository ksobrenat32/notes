# Useful things for my backups

## telegram-cli

    telegram-cli -W --exec 'msg <channel or user> '"the message"
    telegram-cli -W --exec 'send_file <channel or user> '/path/to/file/to/send

- Use the "-W" flag for updating tha contacts list.

## tar and xz

    tar -cJf <the name of the compressed file>.tar.xz /path/to/directorie/1 /path/to/directorie/2

- Use "-J" to use the xz protocol.
- Use "-cf" to create a new file.

## gpg

    gpg -e -r <recipient> /path/to/file/to/encrypt

- Use "-e" to encrypt
- Use "-r" to specify the recipient

## sha256

    sha256sum /path/to/file > /path/to/file.sha256

- Generate a sha256 hash from the file

## rsync

    rsync -arzuvhP --ignore-existing /path/to/source /path/to/destiny

- "a" for archive mode
- "r" for rexursive
- "z" for compression on transit (useful in network)
- "u" for skipping files newer on receiver
- "h" for human readable
- "P" for progress

> "-n" for dry run

## btrfs with luks

### To mount

    sudo cryptsetup luksOpen /dev/sda/ orig
    sudo cryptsetup luksOpen /dev/sdb1/ dest

    sudo mount -o noatime,nodiratime,compress=zstd,defaults /dev/mapper/orig /mnt/orig
    sudo mount -o noatime,nodiratime,compress=zstd,defaults /dev/mapper/dest /mnt/dest

### Taking snapshot

    cd /mnt/orig
    sudo btrfs subvolume snapshot -r data/ backup-snapshots/data--$(date +%Y%m%d)

### Sending incremental snapshot

    sudo btrfs send -p /mnt/orig/backup-snapshots/data--(previous) /mnt/orig/backup-snapshots/data--(today) | sudo btrfs receive /mnt/dest/backup-snapshots &

### Delete old snapshots

    sudo btrfs su delete /mnt/backup-snapshots/data--(day-to-delete)

