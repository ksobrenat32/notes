# Useful notes for my backups

## tar and xz

``` bash
tar -cJf file.txz /path/to/directorie/1 /path/to/directorie/2
# or with pipes for tunning compression level
tar -cf - /path/to/directorie/1 /path/to/directorie/2 | xz -z -T0 -9 > file.txz
```

- Use "-J" to use the xz protocol.
- Use "-cf" to create a new file.

## gpg

``` bash
gpg --encrypt --recipient <recipient> file
# or symmetric
gpg --encrypt --symmetric file
```

## sha256

``` bash
sha256sum file > file.sha256
```

- Generate a sha256 hash from the file

## rsync

``` bash
rsync -arzuvhP /path/to/source /path/to/destiny
```

- "a" for archive mode
- "r" for recursive
- "z" for compression on transit (useful in network)
- "u" for skipping files newer on receiver
- "v" for verbose
- "h" for human readable
- "P" for progress

- "c" for checksum
- "i" for showing changes in a verbose mode

- "--ignore-existing" for leaving untouched the files on destination
- "--delete" for deleting files on destination

> "-n" for dry run

## BTRFS with luks snapshot

### Taking snapshot

``` bash
cd /mnt/disk
sudo btrfs subvolume snapshot -r data/ backup/data-$(date -I)
```

### Sending incremental snapshot

``` bash
sudo btrfs send -p /mnt/disk/backup/data-(previous) /mnt/disk/backup/data-(new) \
    | sudo btrfs receive /mnt/dest/backup &
```

### Delete old snapshots

``` bash
sudo btrfs subvolume delete /mnt/backup-snapshots/data-(day)
```
