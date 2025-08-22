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
        no shutdown
    exit
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
    username <username> secret <password>
exit
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
