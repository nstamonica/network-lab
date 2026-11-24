# NetMedic

A 3-site network (HQ, Branch A, Branch B) running in Containerlab with FRRouting.

- **Inside each site:** edge router + layer-3 switch, OSPF, VLANs 10 (users), 20 (servers), 30 (guest), 99 (management)
- **Between sites:** eBGP, HQ is the hub
- **Plan and reasons:** `docs/ip-plan.md`, `docs/design.md`, `diagrams/topology.md`

## Run it

From the Containerlab WSL distro (`wsl -d Containerlab`), in this folder:

```bash
sudo containerlab deploy -t netmedic.clab.yml   # start (first run downloads images)
sleep 30                                        # give OSPF + BGP time to come up
sudo ./scripts/check_phase1.sh                  # Phase 1 test: 30 pings should pass
```

Stop it with `sudo containerlab destroy -t netmedic.clab.yml --cleanup`.

## Poke around

```bash
# Open a router's CLI
sudo docker exec -it clab-netmedic-hq-r1 vtysh

# Handy commands inside vtysh
show ip route
show ip ospf neighbor
show bgp ipv4 unicast summary
show bgp ipv4 unicast

# See the VLANs on a switch
sudo docker exec clab-netmedic-hq-sw1 bridge vlan show

# Ping from one host to another site
sudo docker exec clab-netmedic-bra-pc1 ping -c 3 10.3.20.10
```

## Layout

```
netmedic.clab.yml      the lab: nodes and cables
configs/<device>/      FRR config for each router/switch (known-good copies)
configs/common/        shared files (FRR daemons, VLAN setup script)
scripts/               check scripts (later: chaos script)
docs/                  IP plan and design decisions
diagrams/              topology diagram
```
