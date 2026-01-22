# Networking notes

## Nftables

A `/etc/nftables.conf` simple configuration

```nft
#!/usr/sbin/nft -f

flush ruleset

table inet filter {
    # Deny all input by default
    chain input {
    type filter hook input priority filter; policy drop;
        # If the connection is invalid, drop it 
        ct state invalid drop
        # If the connection was already stablished accept it
        ct state { established, related } accept
        # Allow internal loopback but do not allow packages from outside
        iif "lo" accept
        iif != "lo" ip daddr 127.0.0.1/8 drop
        iif != "lo" ip6 daddr ::1/128 drop
        # Allow ping usage
        ip protocol icmp accept
        ip6 nexthdr ipv6-icmp accept
        # Open some ports
        ip saddr 192.168.1.0/24 tcp dport 22 accept # Allow ssh port on local network
        tcp dport 443 accept # Allow https port from everywhere
    }
    # Drop all packages that want to forward
    chain forward {
        type filter hook forward priority filter; policy drop;
    }
    # Allow all outputs
    chain output {
        type filter hook output priority filter; policy accept;
    }
}
```

## Network bridge configuration

The network bridge configuration for any system that uses
 `/etc/network/interfaces` for its configuration.

```interfaces
source /etc/network/interfaces.d/*

# The loopback network interface
auto lo
iface lo inet loopback

# The primary network interface
allow-hotplug enp1s0
iface enp1s0 inet static

auto br0
iface br0 inet static
    address 192.168.122.220
    netmask 255.255.255.0
    gateway 192.168.122.1
    bridge_ports enp1s0
    up /usr/sbin/brctl stp br0 on

```

Where `address` is the static ip of the host.
