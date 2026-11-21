# Design Decisions

Why I made each choice in the network lab. One or two lines each.

## Sites
- 3 sites: HQ, Branch A, Branch B
- Why:

## VLANs
| VLAN ID | Name       | Purpose |
|---------|------------|---------|
| 10      | Users      |         |
| 20      | Servers    |         |
| 30      | Guest      |         |
| 99      | Management |         |

- Why a separate Guest VLAN:
- Why a separate Management VLAN:

## IP Plan
| Site     | Block        | Users         | Servers       | Guest         | Mgmt          |
|----------|--------------|---------------|---------------|---------------|---------------|
| HQ       | 10.1.0.0/16  | 10.1.10.0/24  | 10.1.20.0/24  | 10.1.30.0/24  | 10.1.99.0/24  |
| Branch A | 10.2.0.0/16  | 10.2.10.0/24  | 10.2.20.0/24  | 10.2.30.0/24  | 10.2.99.0/24  |
| Branch B | 10.3.0.0/16  | 10.3.10.0/24  | 10.3.20.0/24  | 10.3.30.0/24  | 10.3.99.0/24  |

- Gateway for each VLAN is the .1 address (e.g. 10.1.10.1)

### Links between sites
| Link            | Subnet         | Router IPs                |
|-----------------|----------------|---------------------------|
| HQ – Branch A   | 10.255.0.0/30  | HQ .1, Branch A .2        |
| HQ – Branch B   | 10.255.0.4/30  | HQ .5, Branch B .6        |

- Why /24s for VLANs:
- Why small subnets for links:

## Routing
- Inside each site:
- Between sites:
- Why:
