#!/usr/bin/env bash
set -euo pipefail

NAMESPACE="devops-portfolio"
ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
MANIFEST_DIR="$ROOT_DIR/manifests"

log() {
  printf '[%s] %s\n' "$(date '+%H:%M:%S')" "$1"
}

log "Aplicando namespace"
kubectl apply -f "$MANIFEST_DIR/base/"

log "Aplicando base de datos"
kubectl apply -f "$MANIFEST_DIR/db/"
kubectl rollout status deployment/postgres -n "$NAMESPACE" --timeout=180s

log "Aplicando backend"
kubectl apply -f "$MANIFEST_DIR/backend/"
kubectl rollout status deployment/backend -n "$NAMESPACE" --timeout=180s

log "Aplicando frontend"
kubectl apply -f "$MANIFEST_DIR/frontend/"
kubectl rollout status deployment/frontend -n "$NAMESPACE" --timeout=120s

log "Estado final"
kubectl get all -n "$NAMESPACE"

log "App expuesta por NodePort 30080"
