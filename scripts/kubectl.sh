#!/usr/bin/env bash
# Runs kubectl inside the Kubernetes server, so nothing needs installing.
# Usage: sudo ./scripts/kubectl.sh <anything you'd give kubectl>
exec docker exec -i hq-k8s-control-plane kubectl --kubeconfig /etc/kubernetes/admin.conf "$@"