# Design Decisions

Why I made each choice in the network lab. One or two lines each.

## Sites
- 3 sites: HQ, Branch A, Branch B
- Why: HQ and the two additional branches demonstrates the smallest setup that still shows real multi-site routing and allows one site to fail while the others stay up

## VLANs
| VLAN ID | Name       |               Purpose             |
|---------|------------|-----------------------------------|
| 10      | Users      | employee laptops and desktops     |
| 20      | Servers    | internal apps and services        |
| 30      | Guest      | visitor wi-fi, internet only      |
| 99      | Management | logging into routers and switches |

- Why a separate Guest VLAN: Since we can't really trust visitors, we only allow their devices to use internet and not access company servers
- Why a separate Management VLAN: Only allows admins to log into network devices

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

- Why /24s for VLANs: Easy to read and troubleshoot and 254 usable addresses is plenty for a small office
- Why small subnets for links: Link only contains two routers and a /30 gives exactly two usable addresses and doesn't waste space

## Routing
- Inside each site:
- Between sites:
- Why:
