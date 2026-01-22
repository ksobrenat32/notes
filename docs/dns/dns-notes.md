# DNS notes

## Dig utility

Dig is a useful tool for querying DNS servers.

### Usage

**Basic query:**

```sh
dig example.com
```

**Query specific record type:**

```sh
dig example.com A
dig example.com MX
dig example.com TXT
```

**Query using a specific DNS server:**

```sh
dig @1.1.1.1 example.com
```

**Query with +short for concise output:**

```sh
dig example.com +short
```

## Unbound dns server

Unbound is a validating, recursive, and caching DNS resolver.

### Basic configuration

For a recursive dns server you need to be able to resolve from the root servers,
 for that you need the root hints file.

**Get root hints:**

```sh
wget -S -N https://www.internic.net/domain/named.cache -O /etc/unbound/root.hints
# or with curl
curl -fsSL -o /etc/unbound/root.hints https://www.internic.net/domain/named.cache
```

> You should have a cronjob running for this every month (as root)s

## Systemd-resolved configuration

If you need to be able to bind port 53 with systemd-resolved enabled,
 you need to configure systemd-resolved to listen on another port
 besides 53, for example 5353, and then configure unbound or blocky

1. Edit /etc/systemd/resolved.conf

```sh
[Resolve]
DNS=9.9.9.9 8.8.8.8
DNSStubListener=no
```

2. Restart systemd-resolved

```sh
sudo systemctl restart systemd-resolved
```
