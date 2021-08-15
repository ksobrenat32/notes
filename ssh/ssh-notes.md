### Generate safe ssh key pair

	ssh-keygen -o -a 100 -t ed25519 -f ~/.ssh/id_ed25519 -C "user@email.com"

### Add a password to an existing key

	ssh-keygen -p -f keyfile
