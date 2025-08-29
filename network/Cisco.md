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
    username <username> password 7 <password> # Cisco's type 7 password
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

#### Save configuration

```sh
write
# or
copy running-config startup-config
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
    # ...
exit
```
