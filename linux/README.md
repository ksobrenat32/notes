# Linux notes

## Add user to use as a service

When you run a service, you should consider using a different user
 in order to not run as root or as a user with access to private
 information. This user does not has shell access and the home is
 usually where the aplication is stored.

DEBIAN:

```sh
sudo adduser --home /opt/blocky --gecos "" --disabled-password --uid 9901 --shell /sbin/nologin blocky
```

RHEL: 

```sh
sudo adduser --home /opt/olivetin --uid 9802 --no-create-home --shell /sbin/nologin olivetin
```

## Change permission

When you want to change permissions on a recursive way, when you
 come across directories you got to be careful because they need
 to have executable permissions in order to be able to explore
 them, but you may not want to give this permissions to the files.

So we use this for directories

```sh
find /dir -type d -exec chmod 755 {} \;
```

And use this for files

```sh
find /dir -type f -exec chmod 644 {} \;
```

## Centos

### Add btrfs support through kmod

I love btrfs, but I also like rhel and family which is not really
 btrfs-friendly, searching for a solution I founded [this user](https://cbs.centos.org/koji/userinfo?userID=258)
 which builds kmod and btrfs-progs with centos' koji system.

To install it, first install the repo on rhel 9 and family:

```sh
curl -o centos-release-kmods-9-1.el9s.noarch.rpm -fsSL https://cbs.centos.org/kojifiles/packages/centos-release-kmods/9/1.el9s/noarch/centos-release-kmods-9-1.el9s.noarch.rpm
sudo dnf install ./centos-release-kmods-9-1.el9s.noarch.rpm
```

To install it, first install the repo on rhel 9 and family:

```sh
curl -o centos-release-kmods-8-1.el8s.noarch.rpm -fsSL https://cbs.centos.org/kojifiles/packages/centos-release-kmods/8/1.el8s/noarch/centos-release-kmods-8-1.el8s.noarch.rpm
sudo dnf install ./centos-release-kmods-8-1.el8s.noarch.rpm
```

Then update and install btrfs-progs, it will download the kmod as
 a dependency

```sh
sudo dnf update
sudo dnf install btrfs-progs
```

Reboot and it should be working great :D
