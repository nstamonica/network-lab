#!/bin/sh
# Puts one switch socket into a VLAN.
# Usage: sh /add-access-port.sh <socket> <vlan>
port=$1
vid=$2

# Wait up to 60 seconds for the socket to appear
i=0
while [ ! -e /sys/class/net/$port ]; do
  i=$((i + 1)); [ $i -gt 60 ] && echo "$port never appeared" && exit 1
  sleep 1
done

# Set the socket up (same 3 lines as eth3 in switch-vlans.sh)
ip link set $port master br0
bridge vlan del dev $port vid 1
bridge vlan add dev $port vid $vid pvid untagged
ip link set $port up
echo "$port is now in VLAN $vid"