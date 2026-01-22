# Backup Notes

## Utilities

### Tar

Tar is great for creating archives of multiple directories or files into a single file.
 It also supports compression and can be combined with other tools for encryption
 and integrity checks.


#### Usage

**Compressing directories into a .txz archive:**

```sh
tar -cJf file.txz /path/to/directorie/1 /path/to/directorie/2
```

- Use "-J" to use the xz protocol.
- Use "-cf" to create a new file.

**Using multithreading compression:**

```sh
tar -cf - /path/to/directorie/1 /path/to/directorie/2 | xz -z -T0 -9 > file.txz
```

- "-T0" uses all available CPU cores.
- "-9" is the maximum compression level.

**Extracting an archive:**

```sh
tar -xJf file.txz
```

### GPG

GPG can be used to encrypt files for secure storage or transfer.


#### Usage

**Create a keypair:**

```sh
gpg --full-generate-key
```

**Get key information:**

```sh
gpg --list-keys
```

For the key ID, use the long format (16 characters).

```sh
gpg --list-keys --keyid-format LONG
```

**Export public key:**

```sh
gpg --export --armor <recipient_key_id> > publickey.asc
```

**Import public key:**

```sh
gpg --import publickey.asc
```

**Export secret key for backup:**

```sh
gpg -o private-backup.gpg --export-options backup --export-secret-keys <email_or_key_id>
```

**Import the backup key:**

```sh
gpg --import-options restore --import private-backup.gpg

gpg --edit-key username@example.com

> trust
> 5 (ultimately)
> save
```

**Encrypt a file with a recipient**

```sh
gpg --encrypt --recipient <recipient_key_id> file
```

**Decrypt a file**

```sh
gpg --decrypt file.gpg > file
```

**Encrypt a file with password**

```sh
gpg --encrypt --symmetric file
```

### Rsync

Rsync is a powerful tool for synchronizing files and directories between two locations,
 either locally or over a network.

#### Usage

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

### Btrfs

Btrfs is a modern filesystem that supports advanced features like snapshots,
subvolumes, and built-in RAID support. It is well-suited for backup solutions
due to its snapshot capabilities and efficient storage management.

#### Usage

**Format a partition with Btrfs:**

``` bash
sudo mkfs.btrfs /dev/sdXn
```

**To mount a Btrfs filesystem:**

``` bash
sudo mount -o options -t btrfs /dev/sdXn /mnt/point
```

Options can include:

- "compress=zstd" for compression (also supported: lzo, zlis)
- "noatime" to disable access time updates
- "subvol=subvolume_name" to mount a specific subvolume
- "space_cache=v2" for improved space cache management
- "autodefrag" to enable automatic defragmentation

**Taking a snapshot:**

``` bash
sudo btrfs subvolume snapshot -r /mnt/point/subvolume /mnt/point/snapshot_name
```

**Sending a snapshot to another location:**

``` bash
sudo btrfs send /mnt/point/snapshot_name | sudo btrfs receive /mnt/dest/point
```

**Sending an incremental snapshot:**

``` bash
sudo btrfs send -p /mnt/point/snapshot_previous /mnt/point/snapshot_new | sudo btrfs receive /mnt/dest/point
```

**Delete a snapshot:**

``` bash
sudo btrfs subvolume delete /mnt/point/snapshot_name
```
