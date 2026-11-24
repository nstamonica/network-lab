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
- Inside each site: OSPF (area 0) between the edge router and the switch
- Between sites: eBGP, each site has its own private ASN (HQ 65001, Branch A 65002, Branch B 65003)
- Why: OSPF finds paths quickly and automatically inside one site; BGP lets each site control and filter exactly what it shares with the others

## More Phase 1 decisions
- **Hub and spoke (HQ in the middle):** common for small companies; a broken HQ↔branch link has a clear, testable effect.
- **Inside-site addresses follow the same pattern:** 10.<site>.254.0/30 for the router↔switch link, 10.<site>.255.x/32 for loopbacks.
- **eBGP route filters (prefix-list + route-maps):** only site summaries (/16) can cross the WAN, so a mistake at one site can't leak junk routes to the others. FRR also refuses to send eBGP routes without a policy.
- **Blackhole route for the site /16 on the edge router:** BGP only advertises a route that exists; the blackhole is that route, and real traffic still uses the more specific OSPF routes.
- **Redistribute BGP into OSPF:** the switches learn the other sites' routes. Fine at 3 sites; at large scale I'd send a default or summary route instead.
- **OSPF point-to-point on router↔switch links:** skips the DR/BDR election, so neighbours come up faster.
- **Passive OSPF on VLAN gateways:** advertises the VLAN subnets without sending OSPF hellos to end devices.
- **Layer-3 switch per site (VLAN-aware Linux bridge + SVIs):** matches a real branch setup, where the switch is the gateway for each VLAN.
- **Guest VLAN is built now, locked down later:** the "internet only" rule comes with the firewall phase.
- **Loopbacks as router IDs:** a loopback never goes down with a cable, so the ID stays stable.
- **Lab management network (172.30.30.0/24):** Containerlab gives every device a separate out-of-band connection; monitoring and automation use it, so they still work when the main network is broken. VLAN 99 is the in-band management VLAN.
- **Demo app goes in the Servers VLAN (10.1.20.0/24) at HQ:** it's an internal service, which is what VLAN 20 is for.
- **All configs in Git:** Phase 6 restores a router by pushing its known-good config from here.
