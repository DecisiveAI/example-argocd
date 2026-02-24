# Architecture & Mental Model

> **Prerequisite**
>
> This document builds on the repository layout and contracts defined in
> [REPO_STRUCTURE.md](./REPO_STRUCTURE.md).
>
> Helpful visuals:
> - `usage/diagrams/argocd-control-flow.png`
> - `usage/diagrams/promotion-workflow.png`

## Flow of control

| Layer         | Responsibility     | Notes                                                |
| ------------- | ------------------ | ---------------------------------------------------- |
| `catalog/`    | **Definition**     | Reusable, inert components. Never deployed directly. |
| `live/<env>/` | **Activation**     | Environment-specific intent. Only deployable paths.  |
| Argo CD       | **Reconciliation** | Syncs and enforces state from `live/<env>/` only.    |

**Outcome**
Environment changes are explicit, reviewable in Git, and applied deterministically by Argo CD.


## Layers in Argo CD

<!-- Canonical Argo CD layering reference. Do not duplicate elsewhere. -->

| Layer | Application | Definition source | What it does | Source paths |
|------|-------------|------------------|--------------|--------------|
| 1 | **mdai-apps** | `argocd/argocd.yaml` | App-of-apps bootstrap | Dev: `argocd/apps/**`<br>Prod (opt-in): `argocd/apps/prod/**` via `argocd/argocd-prod.yaml` |
| 2 | **mdai** | `argocd/apps/mdai.yaml` | Platform install (Helm) | Installs CRDs and controllers required by MyDecisive |
| 3 | **mdai-global-config-<env>** | Dev: `argocd/apps/mdai-globals.yaml`<br>Prod: `argocd/apps/prod/mdai-globals-prod.yaml` | Global baseline configuration | `argocd/mdai/live/<env>/global` |
| 4 | **mdai-team-<team>-<env>** | Dev: `argocd/apps/teams/*.yaml`<br>Prod: `argocd/apps/prod/*-prod.yaml` | Team-scoped bundle | `argocd/mdai/live/<env>/teams/<team>` |


**Design Principle**

Each layer has a single responsibility and a bounded blast radius, which keeps failures isolated and reviews focused.

## Global vs solution-scoped “global” CRs

[Solution-gated, cluster-scoped resources](./SOLUTION_GATED_CLUSTER_SCOPED_RESOURCES.md)

## How this solution scales

- Adding solutions does not impact teams until enabled
- Team overrides are isolated and data-only
- Reviews are small because `live/<env>/` shows activation explicitly
- Platform and workload concerns remain decoupled
