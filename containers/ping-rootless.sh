#! /bin/bash

echo 'This script allows rootless podman containers to use ping, if you have more than one user you should change the last value with the last gid your user can use, you can locate the number in /etc/subgid '

sudo echo 'net.ipv4.ping_group_range=0 165535' >> /etc/sysctl.d/podman-ping.conf
