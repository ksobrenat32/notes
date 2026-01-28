# Networking notes

## FirewallD

FirewallD is a dynamic firewall management tool with support for network zones.

### Basic commands

**List zones:**

```bash
firewall-cmd --get-zones
```

**Get active zones:**

```bash
firewall-cmd --get-active-zones
```

**Add service to zone:**

```bash
firewall-cmd --zone=<zone> --add-service=<service> --permanent
firewall-cmd --reload
```

**Add port to zone:**

```bash
firewall-cmd --zone=<zone> --add-port=<port>/tcp --permanent
firewall-cmd --reload
```

**Remove service from zone:**

```bash
firewall-cmd --zone=<zone> --remove-service=<service> --permanent
firewall-cmd --reload
```

**Remove port from zone:**

```bash
firewall-cmd --zone=<zone> --remove-port=<port>/tcp --permanent
firewall-cmd --reload
```

**List services in zone:**

```bash
firewall-cmd --zone=<zone> --list-all
```

**Add a source to a zone:**

```bash
firewall-cmd --zone=<zone> --add-source=<source_ip_or_network> --permanent
firewall-cmd --reload
```

**Remove a source from a zone:**

```bash
firewall-cmd --zone=<zone> --remove-source=<source_ip_or_network> --permanent
firewall-cmd --reload
```

### Firewalld geoblocking

If you only need your service in a certain country it is a good
 idea to block everything except the working zone, to do it:

1. Download the aggregated ips of the countries you need from
 https://www.ipdeny.com/ipblocks/

2. Create an ipset containing all the IPS

    ```sh
    firewall-cmd --permanent --new-ipset=IPs --type=hash:net
    firewall-cmd --permanent --ipset=IPs --add-entries-from-file=1.zone
    firewall-cmd --permanent --ipset=IPs --add-entries-from-file=2.zone
    ```

3. Create a zone with rules for the allowed countries

    ```sh
    firewall-cmd --permanent --new-zone=MYZONE
    firewall-cmd --permanent --zone=MYZONE --add-source=ipset:IPs
    firewall-cmd --permanent --zone=MYZONE --add-service=ssh
    firewall-cmd --permanent --zone=MYZONE --add-port=80/tcp
    firewall-cmd --reload
    ```

4. (Optional) If you dont want to allow anthing else you
 should drop everything by default. *REMEMBER TO KEEP SSH ACCESS*

    ```sh
    firewall-cmd --permanent --zone=public --set-target=DROP
    ```

> Keep in mind this has CPU/RAM usage implications depending on the
> amount of IPs you are blocking/allowing.

## Multithreading on network interfaces

I hit a situation where I noticed that my server with multiple
cores was not using all of them to handle network traffic.

After some research I found out that enabling multiqueue on the
network interface would help with that.

1. Check that your hardware supports it (I recommend intel cards with RSS (Receive Side Scaling))

```sh
ethtool -i <interface>
```

2. Install and start `irqbalance`, this service will help distribute
the interrupts across all the cores.

3. Optimize sysctl settings for better network performance by adding
the following lines to `/etc/sysctl.d/99-server-tuning.conf`:

```conf
#/etc/sysctl.d/99-server-tuning.conf 
# Increase the backlog of connections waiting to be accepted
# (Helps prevents timeouts during traffic spikes)
net.core.netdev_max_backlog = 5000
net.core.somaxconn = 4096

# Enable TCP BBR Congestion Control
# (Much better at handling the variable speeds of mirror downloads)
net.core.default_qdisc = fq
net.ipv4.tcp_congestion_control = bbr

# reuse timewait sockets (helps with Tor's many connections)
net.ipv4.tcp_tw_reuse = 1
```
