# DNS notes

## Unbound configuration

Use this configuration with blocky as a recursive dns with adblocking.
You need the root hints, to download them use:

```sh
wget -S -N https://www.internic.net/domain/named.cache -O /etc/unbound/root.hints
# or with curl
curl -fsSL -o /etc/unbound/root.hints https://www.internic.net/domain/named.cache
```

You may have a cronjob running for this (as root).

```cron
15 14 1 * * wget -S -N https://www.internic.net/domain/named.cache -O /etc/unbound/root.hints
# or with curl
15 14 1 * * curl -fsSL -o /etc/unbound/root.hints https://www.internic.net/domain/named.cache
```

### Debian - resolvconf

Disable unbound-resolvconf if you do not use it because
 it may cause conflict with blocky and unbound running
 at the same time, you should have another DNS ip on the
 /etc/resolv.conf file.

```sh
sudo systemctl disable unbound-resolvconf.service
```

### RHEL based

To allow the writing on the trust anchor file:

```sh
 sudo chown -R unbound: /var/lib/unbound
```

Selinux run unbound on port 5353:

```sh
sudo semanage port -a -t dns_port_t -p tcp 5353
sudo semanage port -a -t dns_port_t -p udp 5353
```
