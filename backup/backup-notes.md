## Useful things for my backups

### telegram-cli

	telegram-cli -W --exec 'msg <channel or user> '"the message"
	telegram-cli -W --exec 'send_file <channel or user> '/path/to/file/to/send

- Use the "-W" flag for updating tha contacts list.

### tar and xz

	tar -cJf <the name of the compressed file>.tar.xz /path/to/directorie/1 /path/to/directorie/2

- Use "-J" to use the xz protocol.
- Use "-cf" to create a new file. 

### gpg

	gpg -e -r <recipient> /path/to/file/to/encrypt
		
- Use "-e" to encrypt
- Use "-r" to specify the recipient

### sha256

	sha256sum /path/to/file > /path/to/file.sha256

- Generate a sha256 hash from the file

### rsync

	rsync -aruvh --ignore-existing --info=progress2 /path/to/source /path/to/destiny

- "a" for archive mode
- "r" for rexursive
- "u" for skipping files newer on receiver
- "h" for human readable
