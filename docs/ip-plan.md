# NetMedic IP Plan

## Rule of thumb

Every site gets one `/16`. The second number is the site ID.

| Site | ID | Block | BGP ASN |
|---|---|---|---|
| HQ | 1 | 10.1.0.0/16 | 65001 |
| Branch A (bra) | 2 | 10.2.0.0/16 | 65002 |
| Branch B (brb) | 3 | 10.3.0.0/16 | 65003 |

Inside each site, the third number says what the subnet is for:

| Third number | Use | Example (HQ) |
|---|---|---|
| 10 | VLAN 10 Users | 10.1.10.0/24 |
| 20 | VLAN 20 Servers (demo app goes here in Phase 2) | 10.1.20.0/24 |
| 30 | VLAN 30 Guest | 10.1.30.0/24 |
| 99 | VLAN 99 Management | 10.1.99.0/24 |
| 254 | Router-to-switch link (/30) | 10.1.254.0/30 |
| 255 | Loopbacks (/32, also the router IDs) | 10.1.255.1 |

Gateway for every VLAN is `.1`. Test hosts are `.10`.

## Every address

Same layout at every site; swap the second number (1 = HQ, 2 = Branch A, 3 = Branch B).

| Device | Interface | IP (HQ) | Branch A | Branch B | Notes |
|---|---|---|---|---|---|
| `<site>-r1` | lo | 10.1.255.1/32 | 10.2.255.1 | 10.3.255.1 | Router ID |
| `<site>-r1` | eth1 | 10.1.254.1/30 | 10.2.254.1 | 10.3.254.1 | To switch |
| `<site>-sw1` | lo | 10.1.255.2/32 | 10.2.255.2 | 10.3.255.2 | Router ID |
| `<site>-sw1` | eth1 | 10.1.254.2/30 | 10.2.254.2 | 10.3.254.2 | To router |
| `<site>-sw1` | vlan10 | 10.1.10.1/24 | 10.2.10.1 | 10.3.10.1 | Users gateway |
| `<site>-sw1` | vlan20 | 10.1.20.1/24 | 10.2.20.1 | 10.3.20.1 | Servers gateway |
| `<site>-sw1` | vlan30 | 10.1.30.1/24 | 10.2.30.1 | 10.3.30.1 | Guest gateway |
| `<site>-sw1` | vlan99 | 10.1.99.1/24 | 10.2.99.1 | 10.3.99.1 | Management gateway |
| `<site>-pc1` | eth1 | 10.1.10.10/24 | 10.2.10.10 | 10.3.10.10 | Switch port eth2 |
| `<site>-srv1` | eth1 | 10.1.20.10/24 | 10.2.20.10 | 10.3.20.10 | Switch port eth3 |
| `<site>-guest1` | eth1 | 10.1.30.10/24 | 10.2.30.10 | 10.3.30.10 | Switch port eth4 |

## WAN links (10.255.0.0/16)

| Link | Subnet | IPs |
|---|---|---|
| HQ ↔ Branch A | 10.255.0.0/30 | hq-r1 eth2 .1, bra-r1 eth2 .2 |
| HQ ↔ Branch B | 10.255.0.4/30 | hq-r1 eth3 .5, brb-r1 eth2 .6 |

## Lab management network (172.30.30.0/24)

Containerlab's out-of-band network, used by Prometheus, Netmiko and Ansible. Pattern: site × 10 + device number.

| Device | IP | Device | IP | Device | IP |
|---|---|---|---|---|---|
| hq-r1 | .11 | bra-r1 | .21 | brb-r1 | .31 |
| hq-sw1 | .12 | bra-sw1 | .22 | brb-sw1 | .32 |
| hq-pc1 | .13 | bra-pc1 | .23 | brb-pc1 | .33 |
| hq-srv1 | .14 | bra-srv1 | .24 | brb-srv1 | .34 |
| hq-guest1 | .15 | bra-guest1 | .25 | brb-guest1 | .35 |


The kind node isn't on this network. It sits on Docker's own `kind` network (that's how it downloads images); monitoring will reach it through 10.1.20.20.

## HQ demo app (Phase 2)

| Device | Interface | IP | Notes |
|---|---|---|---|
| hq-k8s-control-plane | eth1 | 10.1.20.20/24 | kind node, HQ Servers VLAN, plugged into hq-sw1 eth5 |
| App URL | | http://10.1.20.20:30080 | web service (NodePort 30080) |

Servers in VLAN 20 count up from .10 (.10 = srv1, .20 = the cluster).

Kubernetes' own ranges stay inside the cluster and are never routed on the lab network:

| Range | Use |
|---|---|
| 10.244.0.0/16 | Pod IPs |
| 10.96.0.0/16 | Service IPs |

The cluster node routes only the 3 site blocks (10.1.0.0/16, 10.2.0.0/16, 10.3.0.0/16) via 10.1.20.1, not all of 10.0.0.0/8. WSL's DNS server is at 10.255.255.254, and a 10.0.0.0/8 route would send DNS lookups into the lab.
