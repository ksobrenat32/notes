#! /usr/bin/env bash
# This script helps generating wireguard config

set -euo pipefail

read -e -p "What is the endpoint (1.2.3.4 or example.com): " endpoint
wg genkey | tee server_privatekey | wg pubkey > server_publickey
wg_server_priv=$(cat server_privatekey)
wg_server_pub=$(cat server_publickey)
wg genkey | tee client_privatekey | wg pubkey > client_publickey
wg_client_priv=$(cat client_privatekey)
wg_client_pub=$(cat client_publickey)
wg_psk=$(wg genpsk)
cat <<EOF | tee server_wg0.conf
# Server
[Interface]
Address    = 172.16.12.1/24
PrivateKey = ${wg_server_priv}
ListenPort = 51820
PostUp     = firewall-cmd --add-port 51820/udp && firewall-cmd --add-rich-rule='rule family=ipv4 source address=172.16.12.0/24 masquerade'
PostDown   = firewall-cmd --remove-port 51820/udp && firewall-cmd --remove-rich-rule='rule family=ipv4 source address=172.16.12.0/24 masquerade'
# Client
[Peer]
PublicKey    = ${wg_client_pub}
PresharedKey = ${wg_psk}
AllowedIPs   = 172.16.12.2/32
EOF
cat <<EOF | tee client_wg0.conf
# Client
[Interface]
Address    = 172.16.12.2/32
PrivateKey = ${wg_client_priv}
# Server
[Peer]
PublicKey    = ${wg_server_pub}
PresharedKey = ${wg_psk}
AllowedIPs   = 172.16.12.0/24
Endpoint     = ${endpoint}:51820
PersistentKeepalive = 20
EOF
