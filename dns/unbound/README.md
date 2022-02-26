# Unbound configuration

Use this configuration with blocky as a recursive dns with adblocking.

## Root-hints

You need the root hints, to download them use:

```sh
wget -S -N https://www.internic.net/domain/named.cache -O /etc/unbound/root.hints
```

You may have a cronjob running for this.

```cron
5 4 * * 7 /usr/bin/wget -S -N https://www.internic.net/domain/named.cache -O /etc/unbound/root.hints
```
