# Selinux notes

## Troubleshooting

### Allowing a service to bind to a port

If you have a service that needs to bind to a port
 that is restricted by selinux, you can allow it
 with the following command:

```sh
sudo semanage port -a -t <type> -p <protocol> <port>
```

**Examples:**

- HTTP

```sh
sudo semanage port -a -t http_port_t -p tcp 8080
```

- DNS

```sh
sudo semanage port -a -t dns_port_t -p tcp 5353
sudo semanage port -a -t dns_port_t -p udp 5353
```

- SSH

```sh
sudo semanage port -a -t ssh_port_t -p tcp 2222
```

### Restore SELINUX context

You can change the SELINUX context to the default of the directory
 it is located with

```sh
sudo restorecon -R file
```

Or you you can fix owner, group and selinux context if it was a path
 created from a rpm package.

```sh
sudo rpm --restore -f /var/lib/path
```

### SELINUX ssh keys on non /home path

If you use `sudo audit2allow -w -a` and see something like this:

```output
avc: denied { read } for pid=13996 comm="sshd" name="authorized_keys" dev="dm-0" i
    "sshd" was denied read on a file resource named "authorized_keys".
scontext=system_u:system_r:sshd_t:s0-s0:c0.c1023
    SELinux context of the sshd process that attempted the denied action.
    tcontext=system_u:object_r:admin_home_t:s0 tclass=file
    SELinux context of the authorized_keys file.
```

Use:

```sh
semanage fcontext --add -t ssh_home_t "/path/to/my/.ssh(/.*)?"
restorecon -FRv /path/to/my/.ssh
```

### Racknerd SELINUX

Racknerd and other VPS providers with RHEL based images do not have SELINUX enabled.
    To enable SELINUX do the following steps:

1. Enable NetworkManager

```sh
systemctl enable NetworkManager
```

2. Update

```sh
dnf update --allowerasing
dnf install vim selinux-policy-targeted selinux-policy-devel policycoreutils
```

3. Autolabel all files

```sh
touch /.autorelabel
```

4. Set SELINUX as permissive for autolabel and reboot

```sh
vim /etc/selinux/config
reboot
```

5. Check status and set enforcing

```sh
sestatus
vim /etc/selinux/config
```

Now you can setup the new user, config ssh, automatic updates,
 etc.
