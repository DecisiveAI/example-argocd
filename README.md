# ArgoCD Example Repository
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
kind create cluster --name local-cluster
```

Before running the following command, remember to update [mdai.yaml](./argocd/apps/mdai.yaml) to use `local-values.yaml`:

```
tilt up
```

You'll be able to access the ArgoCD UI via `localhost:1443` and you can follow [Login To ArgoCD UI](#login-to-argocd-ui) to view the page.

### EKS

This repo provides terraform configs to setup an EKS cluster that will allow you to try things out inside EKS.

[An example deployment GitHub workflow](https://github.com/DecisiveAI/example-argocd/actions/workflows/deploy.yaml) is also provided to showcase how to deploy the terraform configs to AWS using GitHub workflow.

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
