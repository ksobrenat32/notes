# SSH notes

## Generate safe ssh key pair

```bash
ssh-keygen -o -a 100 -t ed25519 -f ~/.ssh/id_ed25519 -C "user@email.com"
```

## Add a password to an existing key

```bash
ssh-keygen -p -f keyfile
```

## SELINUX ssh keys on non /home path

If you use `sudo audit2allow -w -a` and see something like this:

```output
avc: denied { read } for pid=13996 comm="sshd" name="authorized_keys" dev="dm-0" ino=4663556
    "sshd" was denied read on a file resource named "authorized_keys".
scontext=system_u:system_r:sshd_t:s0-s0:c0.c1023
    SELinux context of the sshd process that attempted the denied action.
    tcontext=system_u:object_r:admin_home_t:s0 tclass=file
    SELinux context of the authorized_keys file.
```

Use:

```bash
    sudo semanage fcontext --add -t ssh_home_t "/path/to/my/.ssh(/.*)?"
    sudo restorecon -FRv /path/to/my/.ssh
```

## Change port with SELINUX

If you want to change ssh default port

```bash
# Change port in config: vim /etc/ssh/sshd_config
dnf install -y policycoreutils-python-utils
semanage port -a -t ssh_port_t -p tcp ${sshport}
systemctl restart sshd.service
firewall-cmd --permanent --remove-service=ssh
firewall-cmd --permanent --add-port=${sshport}/tcp
firewall-cmd --reload
```
