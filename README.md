# NetMedic

A 3-site network (HQ, Branch A, Branch B) running in Containerlab with FRRouting.

- **Inside each site:** edge router + layer-3 switch, OSPF, VLANs 10 (users), 20 (servers), 30 (guest), 99 (management)
- **Between sites:** eBGP, HQ is the hub
- **Demo app:** web (nginx) + api (Python) on Kubernetes (kind) at HQ, 10.1.20.20
- **Plan and reasons:** `docs/ip-plan.md`, `docs/design.md`, `diagrams/topology.md`

## Run it

From the Containerlab WSL distro (`wsl -d Containerlab`), in this folder:

```bash
sudo containerlab deploy -t netmedic.clab.yml   # start (first run downloads images)
sleep 30                                        # give OSPF + BGP time to come up
sudo ./scripts/check_phase1.sh                  # Phase 1 test: 30 pings should pass
```

Stop it with `sudo containerlab destroy -t netmedic.clab.yml --cleanup`.

## Demo app

A small app runs on Kubernetes (kind) at HQ, so later phases can break the app and not just the network. `web` (nginx) passes `/api/` requests to `api` (Python, 2 replicas). Namespace: `netmedic`. Files: `app/`.

The cluster node (`hq-k8s-control-plane`) is plugged into `hq-sw1` eth5, VLAN 20, at 10.1.20.20.

The app is **not** redeployed automatically. After every `containerlab deploy`, run:

~~~bash
sudo docker exec hq-k8s-control-plane rm -rf /netmedic-app
sudo docker cp app hq-k8s-control-plane:/netmedic-app
sudo ./scripts/kubectl.sh apply -k /netmedic-app
sudo ./scripts/kubectl.sh -n netmedic get pods   # wait until all are Running
~~~

Test it from a branch PC:

~~~bash
sudo docker exec clab-netmedic-bra-pc1 curl -s http://10.1.20.20:30080/api/status
# expected: {"app": "netmedic-demo", "pod": "api-...", "client": "10.2.10.10"}
~~~

`client` should be the branch PC's real IP. That works because of `externalTrafficPolicy: Local`.

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
app/                   demo app: Kubernetes files and api code
```
