# Phase 1 Topology

```mermaid
flowchart TB
    subgraph HQ["HQ · 10.1.0.0/16 · AS 65001"]
        hqr1["hq-r1<br/>edge router"]
        hqsw1["hq-sw1<br/>L3 switch"]
        hqpc1["hq-pc1<br/>VLAN 10 · 10.1.10.10"]
        hqsrv1["hq-srv1<br/>VLAN 20 · 10.1.20.10"]
        hqg1["hq-guest1<br/>VLAN 30 · 10.1.30.10"]
        hqr1 ---|"OSPF · 10.1.254.0/30"| hqsw1
        hqsw1 --- hqpc1
        hqsw1 --- hqsrv1
        hqsw1 --- hqg1
    end

    subgraph BRA["Branch A · 10.2.0.0/16 · AS 65002"]
        brar1["bra-r1<br/>edge router"]
        brasw1["bra-sw1<br/>L3 switch"]
        brapc1["bra-pc1<br/>VLAN 10 · 10.2.10.10"]
        brasrv1["bra-srv1<br/>VLAN 20 · 10.2.20.10"]
        brag1["bra-guest1<br/>VLAN 30 · 10.2.30.10"]
        brar1 ---|"OSPF · 10.2.254.0/30"| brasw1
        brasw1 --- brapc1
        brasw1 --- brasrv1
        brasw1 --- brag1
    end

    subgraph BRB["Branch B · 10.3.0.0/16 · AS 65003"]
        brbr1["brb-r1<br/>edge router"]
        brbsw1["brb-sw1<br/>L3 switch"]
        brbpc1["brb-pc1<br/>VLAN 10 · 10.3.10.10"]
        brbsrv1["brb-srv1<br/>VLAN 20 · 10.3.20.10"]
        brbg1["brb-guest1<br/>VLAN 30 · 10.3.30.10"]
        brbr1 ---|"OSPF · 10.3.254.0/30"| brbsw1
        brbsw1 --- brbpc1
        brbsw1 --- brbsrv1
        brbsw1 --- brbg1
    end

    hqr1 ===|"eBGP · 10.255.0.0/30"| brar1
    hqr1 ===|"eBGP · 10.255.0.4/30"| brbr1
```

Ports: edge routers use `eth1` for the LAN; HQ uses `eth2` (Branch A) and `eth3` (Branch B) for the WAN, branches use `eth2`. Switches use `eth1` uplink, `eth2` = VLAN 10, `eth3` = VLAN 20, `eth4` = VLAN 30. VLAN 99 has a gateway on each switch but no ports yet.
