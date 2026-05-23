#!/usr/bin/env bash
set -uo pipefail

NS="devops-portfolio"
ERRORS=0

ok() {
  printf '  [OK]   %s\n' "$1"
}

fail() {
  printf '  [FAIL] %s\n' "$1"
  ERRORS=$((ERRORS + 1))
}

echo "=== Verificacion Kubernetes - TP09 ==="
echo

echo "--- Nodos ---"
while read -r name status _; do
  [ "$status" = "Ready" ] && ok "Nodo $name Ready" || fail "Nodo $name $status"
done < <(kubectl get nodes --no-headers)

echo
echo "--- Pods ---"
while read -r name ready status _; do
  [ "$status" = "Running" ] && ok "$name $status ($ready)" || fail "$name $status"
done < <(kubectl get pods -n "$NS" --no-headers)

echo
echo "--- Deployments ---"
while read -r name ready up_to_date available _; do
  desired="${ready#*/}"
  [ "$ready" = "$desired/$desired" ] && ok "$name $ready replicas" || fail "$name $ready replicas"
done < <(kubectl get deployments -n "$NS" --no-headers)

echo
echo "--- Services ---"
while read -r name type cluster_ip external_ip ports _; do
  ok "$name $type $ports"
done < <(kubectl get svc -n "$NS" --no-headers)

echo
echo "--- PVC ---"
while read -r name status volume capacity _; do
  [ "$status" = "Bound" ] && ok "$name Bound ($capacity)" || fail "$name $status"
done < <(kubectl get pvc -n "$NS" --no-headers)

echo
echo "--- Healthcheck interno ---"
if kubectl run tp09-curl --rm -i --restart=Never --image=curlimages/curl:8.10.1 -n "$NS" \
  --command -- curl -fsS http://frontend-service/health >/tmp/tp09-health.json; then
  ok "frontend-service/health respondio"
  cat /tmp/tp09-health.json
  echo
else
  fail "frontend-service/health no respondio"
fi

echo
if [ "$ERRORS" -eq 0 ]; then
  echo "Cluster OK - todos los checks pasaron"
else
  echo "$ERRORS checks fallaron"
fi

exit "$ERRORS"
