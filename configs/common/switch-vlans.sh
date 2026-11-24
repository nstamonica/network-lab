#!/bin/sh
# Turns this node into a layer-3 switch:
#   eth1 = routed uplink to the edge router
#   eth2 = access port, VLAN 10 (USERS)
#   eth3 = access port, VLAN 20 (SERVERS)
#   eth4 = access port, VLAN 30 (GUEST)
#   VLAN 99 (MANAGEMENT) has a gateway but no ports yet.
# vlan10/20/30/99 are the gateway interfaces (SVIs). Their IPs are in frr.conf.
set -e

ip link add br0 type bridge vlan_filtering 1
ip link set eth2 master br0
ip link set eth3 master br0
ip link set eth4 master br0

# Access ports: untagged traffic on eth2 is VLAN 10, on eth3 is VLAN 20.
bridge vlan del dev eth2 vid 1
bridge vlan del dev eth3 vid 1
bridge vlan del dev eth4 vid 1
bridge vlan add dev eth2 vid 10 pvid untagged
bridge vlan add dev eth3 vid 20 pvid untagged
bridge vlan add dev eth4 vid 30 pvid untagged

# Let the switch itself (the SVIs) take part in each VLAN.
ip link set br0 up
for vid in 10 20 30 99; do
  bridge vlan add dev br0 vid $vid self
  ip link add link br0 name vlan$vid type vlan id $vid
  ip link set vlan$vid up
done
