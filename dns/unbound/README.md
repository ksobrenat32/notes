# Unbound configuration

Use this configuration with blocky as a recursive dns with adblocking.

## AlpineLinux - Root-hints

You need the root hints, to download them use:

```sh
sudo wget -S -N https://www.internic.net/domain/named.cache -O /etc/unbound/root.hints
```

You may have a cronjob running for this (as root).

```cron
5 4 * * 7 /usr/bin/wget -S -N https://www.internic.net/domain/named.cache -O /etc/unbound/root.hints
```

## Debian - resolvconf

Disable unbound-resolvconf if you do not use it

```sh
sudo systemctl disable unbound-resolvconf.service
```
