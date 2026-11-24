#!/usr/bin/env bash
# Phase 1 "done" check: every user PC and server pings every other one, across all 3 sites.
# Guest hosts are left out on purpose: later they should only reach the internet.
# Run from the network-lab folder:  sudo ./scripts/check_phase1.sh
set -u
LAB=netmedic
HOSTS="hq-pc1:10.1.10.10 hq-srv1:10.1.20.10 bra-pc1:10.2.10.10 bra-srv1:10.2.20.10 brb-pc1:10.3.10.10 brb-srv1:10.3.20.10"

echo "== BGP sessions (want 'Established' / a number under State/PfxRcd) =="
for r in hq-r1 bra-r1 brb-r1; do
  echo "--- $r"
  docker exec clab-$LAB-$r vtysh -c "show bgp ipv4 unicast summary" | sed -n '/Neighbor/,$p'
done

echo
echo "== OSPF neighbours (want 'Full') =="
for r in hq-sw1 bra-sw1 brb-sw1; do
  echo "--- $r"
  docker exec clab-$LAB-$r vtysh -c "show ip ospf neighbor" | tail -n +2
done

echo
echo "== Ping mesh =="
pass=0; fail=0
for src in $HOSTS; do
  s=${src%%:*}
  for dst in $HOSTS; do
    d=${dst%%:*}; ip=${dst#*:}
    [ "$s" = "$d" ] && continue
    if docker exec clab-$LAB-$s ping -c 2 -W 1 "$ip" >/dev/null 2>&1; then
      echo "PASS  $s -> $d ($ip)"; pass=$((pass+1))
    else
      echo "FAIL  $s -> $d ($ip)"; fail=$((fail+1))
    fi
  done
done

echo
echo "Result: $pass passed, $fail failed (want 30 passed, 0 failed)"
[ "$fail" -eq 0 ]
