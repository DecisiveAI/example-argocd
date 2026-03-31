# Run octant-ui Locally with Argo CD

This guide deploys `octant-ui` from the hosted Helm chart in GHCR using Argo CD.

## Prereqs

- Follow local cluster setup in [README](../../README.md)

## 1. Apply the octant-ui Argo app

```bash
kubectl apply -f argocd/apps/octant-ui.yaml
kubectl get application -n argocd
```

If using Argo CLI:

```bash
argocd app get octant-ui
```

Expected:

- `Sync Status: Synced`
- `Health Status: Healthy`

## 2. Verify Kubernetes resources

`octant-ui` is deployed to namespace `mdai`:

```bash
kubectl get all -n mdai
```

## 3. Open the UI locally

Port-forward to your machine

```bash
kubectl port-forward svc/octant-ui -n mdai 8080:8080
```

Open: `http://localhost:8080`

For local UI development, switch [octant-ui.yaml](../apps/octant-ui.yaml) to use `$values/argocd/octant/local-values.yaml`, then build and load your image into `kind`:

```bash
kind load docker-image octant-ui:0.1.0 -n local-cluster
```
