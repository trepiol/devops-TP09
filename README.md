# TP09 - Kubernetes: pods, deployments y servicios

Deploy de la app de notas del TP06 en Kubernetes.

## Arquitectura

```text
Namespace: devops-portfolio

frontend-service  NodePort :30080
  -> frontend Deployment, 2 replicas, nginx:alpine + ConfigMap
  -> backend-service ClusterIP :5000
  -> backend Deployment, 2 replicas, tr3piol/devops-portfolio:latest
  -> postgres-service ClusterIP :5432
  -> postgres Deployment, Secret y PVC 1Gi
```

## Recursos usados

- Namespace para aislar el proyecto.
- Secret para credenciales de Postgres.
- ConfigMap para variables no sensibles y frontend Nginx.
- PersistentVolumeClaim para persistencia de la base.
- Deployments para Postgres, backend y frontend.
- Services `ClusterIP` para comunicacion interna.
- Service `NodePort` para exponer el frontend.
- Probes y limites de recursos en los pods.

## Deploy

```bash
bash scripts/deploy.sh
```

## Verificacion

```bash
bash scripts/verificar.sh
kubectl get all -n devops-portfolio
```

## Imagen del backend

```text
tr3piol/devops-portfolio:latest
```
