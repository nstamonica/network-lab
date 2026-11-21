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
| Site     | Block        | Users | Servers | Guest | Mgmt |
|----------|--------------|-------|---------|-------|------|
| HQ       | 10.1.0.0/16  |       |         |       |      |
| Branch A | 10.2.0.0/16  |       |         |       |      |
| Branch B | 10.3.0.0/16  |       |         |       |      |

### Links between sites
| Link            | Subnet |
|-----------------|--------|
| HQ – Branch A   |        |
| HQ – Branch B   |        |

- Why /24s for VLANs:
- Why small subnets for links:

## Routing
- Inside each site:
- Between sites:
- Why:
