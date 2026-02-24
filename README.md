# ArgoCD Example Repository

## Repo layout

![Repository structure](usage/diagrams/repo-structure.png)

Example repository showcasing managing MDAI using ArgoCD

### Table of Contents

- [Try It Out](#try-it-out)
  - [Locally](#locally)
    - [Prerequisite](#prerequisite)
    - [Run Everything](#run-everything)
  - [EKS](#eks)
  - [Login To ArgoCD UI](#login-to-argocd-ui)

## Try It Out

### Locally

#### Prerequisite

Ensure you have the following installed:
- [helm](https://helm.sh/docs/intro/install/)
- [kind](https://kind.sigs.k8s.io/docs/user/quick-start/)
- [kubectl](https://kubernetes.io/docs/tasks/tools/#kubectl)
- [tilt](https://docs.tilt.dev/index.html)

Alternatively, you can also use the provided [devcontainer](./.devcontainer/devcontainer.json).

#### Run Everything

```
kind create cluster --name mdai-argo-labs
```

Before running the following command, remember to update [mdai.yaml](./argocd/apps/mdai.yaml) to use `local-values.yaml`:

```
tilt up
```

You'll be able to access the ArgoCD UI via `localhost:1443` and you can follow [Login To ArgoCD UI](#login-to-argocd-ui) to view the page.

### EKS

This repo provides terraform configs to setup an EKS cluster that will allow you to try things out inside EKS.

[An example deployment GitHub workflow](https://github.com/MyDecisive/example-argocd/actions/workflows/deploy.yaml) is also provided to showcase how to deploy the terraform configs to AWS using GitHub workflow.

Once this repo is deployed to EKS, run:

```sh
kubectl port-forward svc/argo-cd-argocd-server -n argocd 1443:443
```

To access the ArgoCD UI via `localhost:1443` and follow [Login To ArgoCD UI](#login-to-argocd-ui) to view the page.

### Login To ArgoCD UI

> [!NOTE]
> Depend on the browser, it might warn you about accessing the ArgoCD UI due to certificate issues.
> It is expected and normal, just confirm you want to access the website anyways.

The username will be `admin` and you can grab the password by running:

```sh
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d; echo
```

## Dev vs Prod
By default, this repo enables **dev** Argo CD Applications only (under `argocd/apps`).

To enable production Applications, apply:
```sh
kubectl apply -f argocd/argocd-prod.yaml
```
To disable prod again:
```sh
kubectl -n argocd delete application mdai-apps-prod
```


### Production “safe mode”
When you enable prod via `argocd/argocd-prod.yaml`, the prod Applications are created in **manual sync** mode:
- **No auto-sync**
- **No self-heal**

To deploy prod, sync the prod apps manually in the Argo CD UI, or with the Argo CD CLI:
```sh
argocd app sync mdai-global-config-prod
argocd app sync mdai-team-payments-prod
```

### Enabling auto-sync for prod (explicit opt-in)
If/when you want prod to behave like dev (auto-sync + self-heal), patch an Application to add an `automated` policy:
```sh
kubectl -n argocd patch application mdai-global-config-prod --type merge -p '{"spec":{"syncPolicy":{"automated":{"prune":true,"selfHeal":true}}}}'
kubectl -n argocd patch application mdai-team-payments-prod --type merge -p '{"spec":{"syncPolicy":{"automated":{"prune":true,"selfHeal":true}}}}'
```

To revert back to safe mode (manual sync), remove the automated block:
```sh
kubectl -n argocd patch application mdai-global-config-prod --type json -p='[{"op":"remove","path":"/spec/syncPolicy/automated"}]'
kubectl -n argocd patch application mdai-team-payments-prod --type json -p='[{"op":"remove","path":"/spec/syncPolicy/automated"}]'
```
