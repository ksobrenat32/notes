# Useful notes for my backups

## Utilities

```sh
tar -cJf file.txz /path/to/directorie/1 /path/to/directorie/2
# - Use "-J" to use the xz protocol.
# - Use "-cf" to create a new file.

# or with pipes for tunning compression level
tar -cf - /path/to/directorie/1 /path/to/directorie/2 | xz -z -T0 -9 > file.txz

gpg --encrypt --recipient <recipient> file

# or symmetric encryption
gpg --encrypt --symmetric file

sha256sum file > file.sha256
```

## rsync

```sh
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
- "-delete" for deleting files on destination

> "-n" for dry run

When using -i (--itemize-changes) the output of the changes will be
 more verbose of why the changes are being done, running it with
 --dry-run is a secure practice in case you want to use -delete, the
 output description is:

```sh
YXcstpoguax  path/to/file
|||||||||||
`----------- the type of update being done::
 ||||||||||   <: file is being transferred to the remote host (sent).
 ||||||||||   >: file is being transferred to the local host (received).
 ||||||||||   c: local change/creation for the item, such as:
 ||||||||||      - the creation of a directory
 ||||||||||      - the changing of a symlink,
 ||||||||||      - etc.
 ||||||||||   h: the item is a hard link to another item (requires --hard-links).
 ||||||||||   .: the item is not being updated (though it might have attributes that are being modified).
 ||||||||||   *: means that the rest of the itemized-output area contains a message (e.g. "deleting").
 ||||||||||
 `---------- the file type:
  |||||||||   f for a file,
  |||||||||   d for a directory,
  |||||||||   L for a symlink,
  |||||||||   D for a device,
  |||||||||   S for a special file (e.g. named sockets and fifos).
  |||||||||
  `--------- c: different checksum (for regular files)
   ||||||||     changed value (for symlink, device, and special file)
   `-------- s: Size is different
    `------- t: Modification time is different
     `------ p: Permission are different
      `----- o: Owner is different
       `---- g: Group is different
        `--- u: The u slot is reserved for future use.
         `-- a: The ACL information changed
```

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
