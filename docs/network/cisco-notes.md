# Cisco Notes

Notes created from CCNA preparation material and personal experience with Cisco devices.

---

## 1. Access & Management

### Physical Connection (Console)
You need a USB-to-serial adapter or a serial cable to connect to the console port of a Cisco device.

**Using screen:**

```sh
screen /dev/ttyUSB0 9600
```

**Using minicom:**

```sh
minicom -D /dev/ttyUSB0 -b 9600
```

**Using Telnet/SSH:**

```sh
telnet <ip_address>
ssh -l <username> <ip_address>
```

**Enable Console Authentication**

```sh
configure terminal
    line console 0
        login local
    exit
exit
```

**Enable VTY (Virtual Terminal) Authentication**

```sh
configure terminal
    line vty 0 15
        login local
        transport input telnet # If login local is not working
        transport input ssh # If login local is not working
    exit
exit
```

**Configure SSH Server**

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

### User & Password Management

**Create/Delete Users**

```sh
configure terminal
    username <username> password <password> # Plain text password
    username <username> secret <password>   # MD5 hashed password
    no username <username>                  # Delete user
exit
```

**Secure Passwords**

```sh
configure terminal
    enable secret <password>    # Set privileged exec password
    service password-encryption # Encrypt all plain text passwords
exit
```

### System Administration

#### Global Setup

```sh
enable
configure terminal
    hostname <new_hostname>     # Set the hostname
    no ip domain-lookup         # Disable DNS lookup to prevent typos acting as domain lookups
exit
```

#### Saving Configuration

```sh
write
# or
copy running-config startup-config
```

#### Clock & NTP

```sh
# Set the clock manually (Privileged EXEC)
clock set HH:MM:SS DAY MONTH YEAR
# Example: clock set 14:30:00 14 November 2025

# Configure NTP
configure terminal
    ntp server <ip>  # Sync time from this server
    ntp master       # Act as authoritative time source
exit

# Verification
show clock
show ntp status
show ntp associations
```

### Syslog Configuration

```sh
configure terminal
    logging host <ip>
    logging trap <message_level> 
    # Levels: 0=emerg, 1=alert, 2=crit, 3=err, 4=warn, 5=notif, 6=info, 7=debug
    
    # Add timestamps with millisecond precision
    service timestamps log datetime msec
exit

show logging
```

## 2. Interface Configuration

### IPv4 Configuration

#### View Interfaces

```sh
show ip interface brief
```

#### Configure Router Interface

```sh
configure terminal
    interface <interface_name>
        description <description>
        ip address <ip_address> <subnet_mask>
        no shutdown
    exit
exit
```

#### Configure Switch Interface (SVI)

```bash
configure terminal
    interface vlan 1
        description <description>
        ip address <ip_address> <subnet_mask>
        ip default-gateway <gateway_ip>
        no shutdown
    exit
exit
```

#### Remove IP Address

```bash
configure terminal
    interface <interface_name>
        no ip address
    exit
```

### IPv6 Configuration

#### Enable IPv6 Routing

```bash
configure terminal
    ipv6 unicast-routing
exit
```

#### Configure Interface

```bash
configure terminal
    interface <interface_name>
        ipv6 address <ipv6_address>/<prefix_length>
        no shutdown
    exit
exit
```

#### Configure Interface (EUI-64)

```bash
configure terminal
    interface <interface_name>
        ipv6 address <ipv6_network>/<prefix_length> eui-64
        no shutdown
    exit
exit
```

## 3. Switching (Layer 2)

### VLANs & Trunking

#### Basic Commands

```bash
show vlan brief
```

#### Create VLANs

```bash
configure terminal
    vlan <vlan_id>
        name <vlan_name>
    exit
```

#### Access Port

```bash
configure terminal
    interface <interface_name>
        switchport mode access
        switchport access vlan <vlan_id>
    exit
```

#### Range of Ports

```bash
configure terminal
    interface range <interface_range>  # e.g., fa0/3-4
        switchport mode access
        switchport access vlan <vlan_id>
    exit
```

#### Trunk Port

```bash
configure terminal
    interface <interface_name>
        switchport mode trunk
        switchport trunk allowed vlan <vlan_list> # Optional e.g., 5,7
    exit

# Verify
show interfaces trunk
```

#### MAC Address Table

```bash
show mac address-table
clear mac address-table dynamic
```

#### Spanning Tree Protocol (STP)

##### Verification

```bash
show spanning-tree
show spanning-tree vlan <vlan_id>
```

##### Root Bridge Configuration

```bash
configure terminal
    # Primary Root (Subtracts 2 × 4096 from default priority)
    spanning-tree vlan <vlan_id> root primary
    
    # Secondary Root (Subtracts 1 × 4096 from default priority)
    spanning-tree vlan <vlan_id> root secondary

    # Manual Priority (Must be multiple of 4096)
    spanning-tree vlan <vlan_id> priority <priority_value>
exit
```

##### PortFast & BPDU Guard

```bash
configure terminal
    interface fa0/10
        spanning-tree portfast
        spanning-tree bpduguard enable
    exit
exit
```

#### EtherChannel (Port-Channel)

##### Configuration Modes
PAgP (Cisco): desirable (active) / auto (passive)

LACP (Open): active / passive

```bash
configure terminal
    interface range fa0/1-3
        channel-group 1 mode <desirable/auto/active/passive>
    exit

    interface port-channel 1
        switchport mode trunk
    exit
exit

# Verify
show interface port-channel 1
show etherchannel summary
```

#### Port Security

```bash
configure terminal
    interface <interface_name>
        switchport mode access
        switchport port-security
        
        # Max MACs (default 1)
        switchport port-security maximum <number>
        
        # Violation mode (shutdown, protect, restrict)
        switchport port-security violation shutdown
        
        # Learn MACs dynamically (sticky)
        switchport port-security mac-address sticky
    exit
exit

# Verify
show port-security interface <interface_name>

# Reset interface after violation
configure terminal
    interface <interface_name>
        shutdown
        no shutdown
    exit
```

## 4. Routing (Layer 3)

### Basic Routing Commands

```bash
show ip route
```

### Static Routing

#### Static Route

```bash
configure terminal
    ip route <network> <mask> <next_hop_ip_or_interface> [AD]
    # Example: ip route 192.168.1.0 255.255.255.0 192.168.30.1
```

#### Default Static Route

```bash
configure terminal
    ip route 0.0.0.0 0.0.0.0 <next_hop_ip>
```

### Inter-VLAN Routing

#### Router-on-a-Stick (ROAS)

```bash
configure terminal
    interface <interface_name>.<vlan_id>
        encapsulation dot1q <vlan_id>
        ip address <ip_address> <subnet_mask>
    exit
    
    # Don't forget to enable physical interface
    interface <interface_name>
        no shutdown
    exit
exit
```

#### Layer 3 Switch

```bash
configure terminal
    ip routing  # Enable routing globally
    
    # Routed Port (Physical L3 interface)
    interface <interface_name>
        no switchport
        ip address <ip_address> <subnet_mask>
    exit

    # SVI (Virtual L3 interface for VLAN)
    interface vlan <vlan_id>
        ip address <ip_address> <subnet_mask>
    exit

    # Trunk on switch side
    interface <interface_name>
        switchport trunk encapsulation dot1q
        switchport mode trunk
    exit
exit
```

### RIPv2

```bash
configure terminal
    router rip
        version 2
        network <network_address>
        default-information originate # Propagate default route
    exit
exit
```

### OSPF

#### Basic Configuration

```bash
configure terminal
    router ospf 1
        # Explicit ID (recommended)
        router-id 1.1.1.1
        
        # Network advertisements
        network 192.168.1.0 0.0.0.255 area 0
        network 192.168.2.0 0.0.0.255 area 1
    exit
    
    # Loopback for stability
    interface loopback 1
        ip address 192.168.3.1 255.255.255.255
    exit
exit

# Verify
show ip ospf neighbor
show ip ospf database
```

#### Scenario: Multi-Router RIP Config (R1-R2-R3)
Example corrected configs for a 3-router chain.

##### R1 (Edge 1)

```bash
interface Fa0/0
    ip address 192.168.1.254 255.255.255.0
interface Se0/0/0
    ip address 192.168.2.1 255.255.255.0
router rip
    version 2
    network 192.168.1.0
    network 192.168.2.0
```

##### R2 (Middle)

```bash
interface Se0/0/0
    ip address 192.168.2.2 255.255.255.0
interface Se0/0/1
    ip address 192.168.3.1 255.255.255.0
router rip
    version 2
    network 192.168.2.0
    network 192.168.3.0
```

##### R3 (Edge 2)

```bash
interface Fa0/0
    ip address 192.168.4.254 255.255.255.0
interface Se0/0/1
    ip address 192.168.3.2 255.255.255.0
router rip
    version 2
    network 192.168.3.0
    network 192.168.4.0
```

## 5. Network Services

### DHCP (Dynamic Host Configuration Protocol)

#### DHCP Server (Pool)

```bash
configure terminal
    # Exclude addresses first
    ip dhcp excluded-address 192.168.1.1 192.168.1.10
    
    ip dhcp pool <name>
        network <network_address> <subnet_mask>
        default-router <gateway_ip>
        dns-server <dns_server_ip>
    exit
exit
```

#### DHCP Client

Used when the router interface needs to get an IP from an ISP/WAN.

```bash
configure terminal
    interface Fa0/0
        ip address dhcp
        no shutdown
    exit
exit
```

#### DHCP Helper (Relay)

Forward DHCP broadcasts from LAN to a server on a different subnet.

```bash
configure terminal
    interface Fa0/0
        ip helper-address <dhcp_server_ip>
    exit
exit
```

#### DHCP Verification

```bash
show ip dhcp binding
clear ip dhcp binding <ip_address>
```

#### DHCP Snooping (Security)

Prevents rogue DHCP servers. Trusted ports = Uplinks/Servers. Untrusted = Clients.

```bash
configure terminal
    ip dhcp snooping
    ip dhcp snooping vlan 1
    
    # Trust uplink to legitimate DHCP server
    interface Fa0/0
        ip dhcp snooping trust
    exit
    
    # Optional: Database for binding persistence
    # ip dhcp snooping database flash:dhcp_snoop.db
exit

# Verify
show ip dhcp snooping
show ip dhcp snooping binding
```

### NAT (Network Address Translation)

#### Interface Roles

```bash
interface <wan_interface>
  ip nat outside
interface <lan_interface>
  ip nat inside
```

#### PAT (Overload)

```bash
# 1. Create ACL matching traffic to translate
access-list 1 permit 192.168.1.0 0.0.0.255

# 2. Apply NAT Overload
ip nat inside source list 1 interface <wan_interface> overload
```

#### Verify NAT

```bash
show ip nat translations
show ip nat statistics
```

### ACLs (Access Control Lists)

#### Standard ACL (1-99)

Filters based on Source IP only.

```bash
access-list 10 permit 192.168.1.0 0.0.0.255
access-list 10 deny host 10.1.1.1
```

#### Extended ACL (100-199)

Filters based on Protocol, Source, Destination, and Port.

```bash
access-list 100 permit tcp 192.168.1.0 0.0.0.255 host 10.1.1.5 eq 80
access-list 100 deny ip any any
```

#### Apply to Interface

```bash
interface <interface_name>
    ip access-group <acl_number> <in/out>
```

#### Verify ACLs

```bash
show access-lists
```

### HSRP (Redundancy)

#### Active Router (Higher Priority)

```bash
interface Fa0/0
    standby 10 ip 192.168.1.100 
    standby 10 priority 200
    standby 10 preempt
```

#### Standby Router

```bash
interface Fa0/0
    standby 10 ip 192.168.1.100 
    standby 10 priority 100
```

Verify: `show standby`

## 6. Miscellaneous & Lab Tools

### Simple Python HTTP Server

Serves files from the current directory.

```bash
sudo python3 -m http.server 80
```

### Dnsmasq (Simple DNS Server)

```
no-resolv
no-poll
listen-address=127.0.0.1
listen-address=192.168.50.100
address=/cisco.com/192.168.50.225
```

### Cisco Packet Tracer Servers

#### Service Setup
DNS: Create A records (IPs) and MX records (Email).

Email: Enable SMTP/POP3, set domain, create users.

HTTP: Edit index.html.

FTP: Create users with permissions (R/W/D/L).

#### FTP Client Commands (PC)

```bash
ftp <server_ip>
dir            # List files
put <filename> # Upload
get <filename> # Download
quit
```