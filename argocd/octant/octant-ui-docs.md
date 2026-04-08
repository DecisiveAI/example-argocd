# Run octant-ui Locally with Argo CD

This guide deploys `octant-ui` from the hosted Helm chart in GHCR using Argo CD.

## Prereqs

## 1. Create Cluster, install Argo (Skip if have cluster w/ Argo)

```bash
kind create cluster --name mdai

helm repo add argo https://argoproj.github.io/argo-helm
helm repo update

helm upgrade --install argo-cd argo/argo-cd \
  --version 9.1.5 \
  --namespace argocd \
  --create-namespace
```

## Apply the mdai and octant-ui Argo apps

```bash
kubectl apply -f argocd/apps/octant-ui.yaml
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
