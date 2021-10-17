#!/usr/bin/env bash

set -e

ADDRESS=$1
PORT=$2
PEER_KEY=$3
PEER_ENDPOINT=$4

if [ -z "$ADDRESS" ]; then
    default_address=10.0.0.2/24
    echo "Address is empty, defaulting to $default_address"
    ADDRESS=$default_address
fi

if [ -z "$PORT" ]; then
    default_port=51820
    echo "Port is empty, defaulting to $default_port"
    PORT=$default_port
fi

WGFILE=/config/wg0.conf

append_wg() {
    echo "$1" >> $WGFILE
}

# Generate the private and public key
if [ ! -f privatekey ]; then
    echo "Generating WireGuard private & public key..."
    (umask 077 && wg genkey | tee privatekey | wg pubkey > publickey)
    echo "Done"
else
    echo "WireGuard private & public key already exists"
    echo "Public key:"
    cat publickey
fi

echo "Generating WireGuard client config"
# We do > instead of >> to reset the file.
echo '[Interface]' > $WGFILE

append_wg "Address = $ADDRESS"
privatekey=$(cat privatekey)
append_wg "PrivateKey = $privatekey"
append_wg "ListenPort = $PORT"
append_wg ""
append_wg "[Peer]"
append_wg "PublicKey = $PEER_KEY"
append_wg "Endpoint = $PEER_ENDPOINT"
append_wg "AllowedIPs = 0.0.0.0/0"
append_wg ""
# This is for if you're behind a NAT and
# want the connection to be kept alive.
append_wg "PersistentKeepalive = 25"
echo "Done"
