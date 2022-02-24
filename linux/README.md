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
