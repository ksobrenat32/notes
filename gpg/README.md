# GPG notes

## Export key for backup

```sh
gpg -o private-backup.gpg --export-options backup --export-secret-keys username@example.com
```

## Import backup key

```sh
gpg --import-options restore --import private.gpg

gpg --edit-key username@example.com

> trust
> 5 (ultimately)
> save
```
