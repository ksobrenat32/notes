# Cisco notes

Notes for configuration and management of Cisco devices.

## Commands

### Connect

#### Using screen

```sh
screen /dev/ttyUSB0 9600
```

## DHCP & DHCP snooping

This section contains common commands and recommendations for DHCP configuration on Cisco devices, DHCP helper (relay) and DHCP snooping.

### DHCP client on a router/interface

Use this when the router itself should obtain an IP via DHCP (for example on a WAN link or a lab server acting as a DHCP client):

```sh
configure terminal
    interface Fa0/0
        ip address dhcp
        no shutdown
    exit
exit
```

### DHCP helper (relay)

When you have a DHCP server on a different subnet, configure the gateway/interface that receives DHCP broadcasts to forward them to the DHCP server:

```sh
configure terminal
    interface Fa0/0
        ip helper-address <dhcp_server_ip>
    exit
exit
```

Notes:
- `ip helper-address` forwards several UDP services by default (including DHCP). If you need to restrict which services are forwarded, use `ip forward-protocol` or ACLs as appropriate.

### DHCP snooping (protects against rogue DHCP servers)

DHCP snooping filters untrusted DHCP messages and builds a binding table of MAC/IP/port information that can be used by other features (e.g., dynamic ARP inspection).

Basic configuration:

```sh
configure terminal
    # Enable DHCP snooping globally
    ip dhcp snooping

    # Enable on specific VLAN(s)
    ip dhcp snooping vlan 1

    # Interface that connects to your DHCP server (or trusted uplink) should be trusted
    interface Fa0/0
        ip dhcp snooping trust
    exit

    # Client-facing interfaces should remain untrusted (this is the default)
    # Do NOT configure 'ip dhcp snooping trust' on access ports that go to clients.
exit
```

Key points:
- Only configure `ip dhcp snooping trust` on ports that lead to DHCP servers or to another switch/router where a DHCP server resides (uplinks).
- Do not mark client-facing ports as trusted — they should remain untrusted so the switch can drop spoofed DHCP offers.
- Optionally configure a persistent database (platform-dependent) to retain bindings across reloads (e.g., `ip dhcp snooping database flash:dhcp_snoop.db`).

Verification commands:

```sh
show ip dhcp snooping
show ip dhcp snooping binding
show ip dhcp snooping statistics
```

### Example: corrected sample router configs (R1, R2, R3)

R1 (edge router with Fa0/0 in 192.168.1.0/24 and serial to R2):

```sh
enable
configure terminal
    hostname R1
    interface Fa0/0
        ip address 192.168.1.254 255.255.255.0
        no shutdown
    interface Se0/0/0
        ip address 192.168.2.1 255.255.255.0
        no shutdown

    router rip
        version 2
        network 192.168.1.0
        network 192.168.2.0
    exit
exit
```

R2 (middle router between R1 and R3):

```sh
enable
configure terminal
    hostname R2
    interface Se0/0/0
        ip address 192.168.2.2 255.255.255.0
        no shutdown
    interface Se0/0/1
        ip address 192.168.3.1 255.255.255.0
        no shutdown

    router rip
        version 2
        network 192.168.2.0
        network 192.168.3.0
    exit
exit
```

R3 (edge router with Fa0/0 in 192.168.4.0/24 and serial to R2):

```sh
enable
configure terminal
    hostname R3
    interface Fa0/0
        ip address 192.168.4.254 255.255.255.0
        no shutdown
    interface Se0/0/1
        ip address 192.168.3.2 255.255.255.0
        no shutdown

    router rip
        version 2
        network 192.168.3.0
        network 192.168.4.0
    exit
exit
```

These examples are cleaned up versions of the original snippets and include the corrected DHCP snooping guidance (trust only uplinks).

---

#### Using telnet

```sh
telnet <ip_address>
```

#### Using SSH

```sh
ssh -l <username> <ip_address>
```

### Configure

#### Global setup

```sh
enable
configure terminal
    hostname <new_hostname> # Set the hostname
    no ip domain-lookup # Disable DNS lookup
    service password-encryption # Enable password encryption
exit
```

#### List interfaces

```sh
show ip interface brief
```

#### Configure interface on router

```sh
configure terminal
    interface <interface_name>
        description <description>
        ip address <ip_address> <subnet_mask>
        no shutdown
    exit
exit
```

#### Configure interface on switch

```sh
configure terminal
    interface vlan 1
        description <description>
        ip address <ip_address> <subnet_mask>
        ip default-gateway <gateway_ip>
        no shutdown
    exit
exit
```

#### DHCP pool

```sh
configure terminal
    ip dhcp pool <name>
        network <network_address> <subnet_mask>
        default-router <gateway_ip>
        dns-server <dns_server_ip>
    exit
exit
```

#### MAC address table commands

```sh
show mac address-table
clear mac address-table dynamic
```

#### Remove IP address configuration

```sh
configure terminal
    interface <interface_name>
        no ip address
    exit
```

#### Configure enable password

```sh
configure terminal
    enable secret <password>
exit
```

#### Enable console authentication

```sh
configure terminal
    line console 0
        login local
    exit
exit
```

#### Create user

```sh
configure terminal
    username <username> password <password> # Plain text password
    username <username> secret <password> # MD5 hashed password
exit
```

#### Delete user

```sh
configure terminal
    no username <username>
exit
```

#### Encrypt passwords with cisco hashes

```sh
service password-encryption
```

#### Enable virtual terminal authentication

```sh
configure terminal
    line vty 0 15
        login local
        transport input telnet # If login local is not working
        transport input ssh # If login local is not working
    exit
exit
```

#### Configure SSH

```sh
configure terminal
    ip domain-name <domain_name>
    crypto key generate rsa
        1024 # Key size in bits
    aaa new-model
    ip ssh authentication-retries 3
    ip ssh time-out 60
exit
```

#### Save configuration

```sh
write
# or
copy running-config startup-config
```

#### Clock and NTP configuration

```sh
# Set the clock manually (in privileged EXEC mode)
clock set HH:MM:SS DAY MONTH YEAR
# Example: clock set 14:30:00 14 November 2025
```

```sh
# Configure NTP server (device will sync time from this server)
configure terminal
    ntp server <ip>
exit
```

```sh
# Configure this device as an NTP master (authoritative time source)
configure terminal
    ntp master
exit
```

```sh
# Show current clock time
show clock

# Show NTP status and synchronization
show ntp status

# Show NTP associations (configured NTP servers and their status)
show ntp associations
```

#### Syslog configuration

```sh
# Send log messages to a syslog server
configure terminal
    logging host <ip>
exit
```

```sh
# Set the severity level of messages sent to syslog server
# Levels: 0=emergencies, 1=alerts, 2=critical, 3=errors, 4=warnings, 5=notifications, 6=informational, 7=debugging
configure terminal
    logging trap <message_level>
exit
```

```sh
# Add timestamps to log messages with millisecond precision
configure terminal
    service timestamps log datetime msec
exit
```

```sh
# Show logging configuration and buffered logs
show logging
```

### IPv6

#### Enable IPv6 Routing
```sh
configure terminal
    ipv6 unicast-routing
exit
```

#### Configure IPv6 on interface
```sh
configure terminal
    interface <interface_name>
        ipv6 address <ipv6_address>/<prefix_length>
        no shutdown
    exit
exit
```

#### Configure IPv6 on interface with EUI-64
```sh
configure terminal
    interface <interface_name>
        ipv6 address <ipv6_network>/<prefix_length> eui-64
        no shutdown
    exit
exit
```

### Routing

#### Routing multiple networks

```sh
configure terminal
    router rip
        version 2
        network <network_address>
        network <network_address>
        network <network_address>
    exit
exit
```

#### Show IP route

```sh
show ip route
```

#### Static route

##### Set a static route

```sh
configure terminal
    ip route <network> <mask> <next_hop_ip/local_interface> #optional <administrative_distance>
```

##### Example of a static route

```sh
configure terminal
    ip route 192.168.1.0 255.255.255.0 192.168.30.1
```

##### Example of a default static route

```sh
configure terminal
    ip route 0.0.0.0 0.0.0.0 <next_hop_ip>
```


#### Default route in routing protocol

```sh
configure terminal
    router rip
        default-information originate
    exit
exit
```

## Enrutamiento OSPF

Configurar OSPF con ejemplos comunes (loopback, áreas, router-id):

```sh
# Loopback interface (useful for router-id stability)
configure terminal
    interface loopback 1
        ip address 192.168.3.1 255.255.255.255
    exit
exit
```

```sh
# OSPF - area 0 example advertising networks 192.168.1.0/24 and 192.168.3.0/24
configure terminal
    router ospf 1
        network 192.168.1.0 0.0.0.255 area 0
        network 192.168.3.0 0.0.0.255 area 0
    exit
exit
```

```sh
# OSPF with explicit router-id
configure terminal
    router ospf 1
        network 192.168.1.0 0.0.0.255 area 0
        router-id 1.1.1.1
    exit
exit
```

```sh
# Example: put a network in area 1
configure terminal
    router ospf 1
        network 192.168.2.0 0.0.0.255 area 1
    exit
exit
```

Comandos de verificación OSPF / enrutamiento:

```sh
show ip route
show ip ospf neighbor
show ip ospf database
```


#### DHCP bindings & exclusions

```sh
# Exclude addresses from DHCP pool
configure terminal
    ip dhcp excluded-address 192.168.1.1 192.168.1.10
exit

# Show DHCP bindings (current leases)
show ip dhcp binding

# Clear a specific binding
clear ip dhcp binding 192.168.1.20
```

### VLANs

#### Show VLANs

```sh
show vlan brief
```

#### Create and Name VLANs

```sh
configure terminal
    vlan <vlan_id>
        name <vlan_name>
    exit
```

#### Assign Port to VLAN (Access Mode)

```sh
configure terminal
    interface <interface_name>
        switchport mode access
        switchport access vlan <vlan_id>
    exit
```

#### Assign a Range of Ports to a VLAN

```sh
configure terminal
    interface range <interface_range>  # e.g., fa0/3-4
        switchport mode access
        switchport access vlan <vlan_id>
    exit
```

#### Configure Trunk Port

```sh
configure terminal
    interface <interface_name>
        switchport mode trunk
        # Optional: Specify allowed VLANs
        switchport trunk allowed vlan <vlan_list> # e.g., 5,7
    exit
```

#### Router-on-a-Stick (Inter-VLAN Routing on a Router)

```sh
configure terminal
    # Create a subinterface for each VLAN
    interface <interface_name>.<vlan_id>
        encapsulation dot1q <vlan_id>
        ip address <ip_address> <subnet_mask>
    exit

    # Example for VLAN 7
    # interface Gi0/0/0.7
    #    encapsulation dot1q 7
    #    ip address 192.168.7.254 255.255.255.0

    # Bring up the physical interface
    interface <interface_name>
        no shutdown
    exit
exit
```

#### Layer 3 Switch Configuration

##### Enable IP Routing

```sh
configure terminal
    ip routing
exit
```

##### Configure a Routed Port (L3 Interface)

```sh
configure terminal
    interface <interface_name>
        no switchport
        ip address <ip_address> <subnet_mask>
    exit
```

##### Configure a Switched Virtual Interface (SVI) for Inter-VLAN Routing

```sh
configure terminal
    interface vlan <vlan_id>
        ip address <ip_address> <subnet_mask>
    exit
```

##### Show Trunk Interfaces

```sh
show interfaces trunk
```

#### Spanning Tree

```sh
# Show general Spanning Tree status
show spanning-tree

# Show Spanning Tree for a specific VLAN (example VLAN 10)
show spanning-tree vlan 10
```

```sh
configure terminal
    # Make this switch the root for VLAN X (primary)
    spanning-tree vlan <vlan_id> root primary
    # This subtracts 2 × 4096 from the default priority

    # Make this switch the secondary root for VLAN X
    spanning-tree vlan <vlan_id> root secondary
    # This subtracts 1 × 4096 from the default priority

    # Manually set the priority (must be a multiple of 4096, range 0-61440)
    spanning-tree vlan <vlan_id> priority <priority_value>
exit
```

> Note: it's 4096 because that step corresponds to the maximum number of VLANs (4096).

```sh
enable
configure terminal
    interface fa0/10
        # Enable PortFast on a specific interface (example fa0/10)
        spanning-tree portfast

        # Enable BPDU Guard
        spanning-tree bpduguard enable
    exit
exit
```

### EtherChannel / Port-channel

```sh
# Configure EtherChannel (PAgP) on a range of interfaces - mode desirable
enable
configure terminal
    interface range fa0/1-3
        channel-group 1 mode desirable
    exit

    interface port-channel 1
        switchport mode trunk
    exit
exit
```

```sh
# Configure EtherChannel (PAgP) on a range of interfaces - mode auto
enable
configure terminal
    interface range fa0/1-3
        channel-group 1 mode auto
    exit

    interface port-channel 1
        switchport mode trunk
    exit
exit
```

```sh
# Configure EtherChannel (LACP) on a range of interfaces - mode active
enable
configure terminal
    interface range fa0/1-3
        channel-group 1 mode active
    exit

    interface port-channel 1
        switchport mode trunk
    exit
exit
```

```sh
# Configure EtherChannel (LACP) on a range of interfaces - mode passive
enable
configure terminal
    interface range fa0/1-3
        channel-group 1 mode passive
    exit

    interface port-channel 1
        switchport mode trunk
    exit
exit
```

```sh
# Verify Port-channel and EtherChannel status
show interface port-channel 1
show etherchannel summary
```

### Port Security

#### Show Port Security Status

```sh
show port-security interface <interface_name>
```

#### Configure Port Security

```sh
configure terminal
    interface <interface_name>
        # Port must be in access or trunk mode
        switchport mode access
        
        # Enable port security
        switchport port-security
        
        # Set the maximum number of MAC addresses allowed (default is 1)
        switchport port-security maximum <number>
        
        # Set the violation mode (shutdown is default)
        # shutdown: Disables the port. Must be manually re-enabled.
        # protect: Drops packets from unknown MACs, no log message.
        # restrict: Drops packets from unknown MACs, sends a log message and increments violation counter.
        switchport port-security violation <shutdown | protect | restrict>
        
        # Learn MAC addresses dynamically and add them to the running config
        switchport port-security mac-address sticky
        
        # Manually specify a MAC address
        switchport port-security mac-address <mac_address>
    exit
exit
```

#### Re-enable a Port after a Shutdown Violation
```sh
configure terminal
    interface <interface_name>
        shutdown
        no shutdown
    exit
exit
```

## Miscellaneous

### Simple http server with Python

```sh
sudo python3 -m http.server 80 # It will show the files on the pwd!
```

### Simple DNS server with dnsmasq

```conf
no-resolv
no-poll

listen-address=127.0.0.1
listen-address=192.168.50.100 # IP of the server
address=/cisco.com/192.168.50.225 # DNS record example
```

### Cisco Packet Tracer Servers

Notes on configuring services on a server in Cisco Packet Tracer.

#### DNS Server
1.  Go to the server's `Services` tab.
2.  Select `DNS`.
3.  Turn the service `On`.
4.  Create `A` records for your domains (e.g., `www.example.com`) pointing to your web server's IP.
5.  Create an `MX` record for your mail server (e.g., `mail.example.com`).

#### Email Server (SMTP/POP3)
1.  Go to the server's `Services` tab.
2.  Select `Email`.
3.  Turn `SMTP` and `POP3` services `On`.
4.  Set a domain name (e.g., `example.com`).
5.  Create user accounts with usernames and passwords.

#### Web Server (HTTP)
1.  Go to the server's `Services` tab.
2.  Select `HTTP`.
3.  Ensure `HTTP` and `HTTPS` are `On`.
4.  You can edit the `index.html` file to customize the web page.

#### FTP Server
1.  Go to the server's `Services` tab.
2.  Select `FTP`.
3.  Turn the service `On`.
4.  Create user accounts with specific permissions (Write, Read, Delete, Rename, List).

##### FTP Client Commands (from a PC's Command Prompt)
```sh
# Connect to the FTP server
ftp <server_ip>

# View files on the server
dir

# Upload a file to the server
put <filename>

# Download a file from the server
get <filename>

# Disconnect from the server
quit
```

## HSRP (Hot Standby Router Protocol)

HSRP is a Cisco proprietary redundancy protocol for establishing a fault-tolerant default gateway.

### Basic Configuration

#### Example 1: Higher Priority Router (Active)

```sh
enable
configure terminal
    interface Fa0/0
        standby 10 ip 192.168.1.100 
        standby 10 priority 200
        standby 10 preempt
    exit
exit
```

#### Example 2: Lower Priority Router (Standby)

```sh
enable
configure terminal
    interface Fa0/0
        standby 10 ip 192.168.1.100 
        standby 10 priority 100
    exit
exit
```

### Verification

```sh
show standby
```

## ACLs

### Show ACLs

From 1 to 99 (standard) and from 1300 to 1999 (expanded standard)

```sh
show access-lists
```

### Standard ACLs

```sh
enable
conf t
    access-list <num> permit/deny <ip_segment> <wildcard>
    access-list <num> permit/deny host <ip>
    access-list <num> permit/deny any
exit

conf t
    interface <interface_name>
    ip access-group <num> IN/OUT
exit
```

### Extended ACLs

```sh
enable
conf t
    access-list <num> permit/deny <protocol> <origin_ip_segment> <origin_wildcard> <destiny_ip_segment> <destiny_wildcard> eq <port>
    access-list <num> permit/deny <protocol> host <origin_ip> host <destiny_ip> eq <port>
    access-list <num> permit/deny <protocol> any any
exit

conf t
    interface <interface_name>
    ip access-group <num> IN/OUT
exit
```

> Note: apply the ACL to the relevant interface with `ip access-group <num> in` or `ip access-group <num> out` depending on whether you want to filter ingress or egress traffic.

## NAT

### Show NAT translations

```sh
show ip nat translations
```

### Example: PAT (overload) using an ACL to match inside hosts

```sh
# Permit a specific host (or use a standard ACL that matches a network)
access-list <n> permit host <host_ip>

# Translate source addresses matched by ACL <n> to the IP of the external interface (overload/PAT)
ip nat inside source list <ACL_num> interface <interface_to_translate> overload
```

### Interface roles

```sh
# The interface towards the internet (public/WAN)
interface <interface_name>
  ip nat outside

# The interface towards the internal network (LAN)
interface <interface_name>
  ip nat inside
```

> Note: replace `<ACL_num>`/`<n>` with the ACL number or name you create. Use `show ip nat statistics` and `show ip nat translations` to verify operation.
