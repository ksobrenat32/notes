# Command line use notes

## Bash notes

For compatibility, use this as shebang on scripts:

```sh
#!/usr/bin/env bash
```

Temporarily disable the bash history

```sh
set +o history
```

Some useful parameters on scripts

```sh
set -e # exit on error
set -u # exit when undeclared variables exist
set -x # trace what gets executed
```

As a recommendation, use variables like: `"${var}"` to avoid
 problems with the names

### Send to background

End commands with `&` to execute on background

When the command is already running, use `ctrl+z` to turn
 it into zombie (in background but not executing)

With `jobs` you can print already running processes

With `fg` you can bring back zombies processes from background
 to foreground and they start executing, with `bg` you can
 let zombie processes execute in the background.

> Remember you can use `kill -9 PID` to kill a proccess
> To obtain the PID, use `ps ax`
> Use `renice` to adjust priority of processes

### `for` statement

Example of a for statement, this example does something like `ls`

```sh
for i in ./* ; do echo "$i" ; done
```

### Umask

Use umask to temporarily change the default permissions

Owner only read

```sh
umask 277
```

Owner only read and write

```sh
umask 177
```

## VIM notes

You can use regex expressions on vim, for example,
 to delete all comment lines:

```vim
:g/^\s*#/d
```

You can invoke netrw which is kinda file explorer

```vim
:Explore - opens netrw in the current window
:Sexplore - opens netrw in a horizontal split
:Vexplore - opens netrw in a vertical split
```

You can also snigger by typing `:Sex` to invoke a horizontal split.

### How to copy paste [on vim](https://vim.fandom.com/wiki/Copy,_cut_and_paste)

1. Position the cursor where you want to begin cutting.
2. Press v to select characters, or uppercase V to select whole lines,
 or Ctrl-v to select rectangular blocks (use Ctrl-q if Ctrl-v is mapped to paste).
3. Move the cursor to the end of what you want to cut.
4. Press d to cut (or y to copy).
5. Move to where you would like to paste.
6. Press P to paste before the cursor, or p to paste after.

## GPG notes

To export secret key for backup

```sh
gpg -o private-backup.gpg --export-options backup --export-secret-keys username@example.com
```

And to import the backup key

```sh
gpg --import-options restore --import private.gpg

gpg --edit-key username@example.com

> trust
> 5 (ultimately)
> save
```

## SSH notes

Generate safe ssh key pair

```sh
ssh-keygen -o -a 100 -t ed25519 -f ~/.ssh/id_ed25519 -C "user@email.com"
```

Add a password to an existing key

```sh
ssh-keygen -p -f keyfile
```
