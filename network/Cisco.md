# Cisco notes

Notes for configuration and management of Cisco devices.

## Commands

### Connect

#### Using screen

```sh
screen /dev/ttyUSB0 9600
```

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
