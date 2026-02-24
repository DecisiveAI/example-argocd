# Handoff Guide – Operating the MyDecisive GitOps Repo

> Assumes you’ve read [REPO_STRUCTURE.md](./REPO_STRUCTURE.md) for directory intent and invariants.


## What you’re operating
This repo manages **collector behavior** (solutions + overrides) and drives Argo CD to apply it.

## Argo CD Applications (layers)

Review [Layers](./ARCHITECTURE.md#layers-in-argo-cd)

## Golden rule
**Argo CD syncs only from `argocd/mdai/live/**`.**

`catalog/` is a library and does nothing until referenced from `live/`.

## Repo layout (what goes where)

| Path                                          | Purpose                               | Notes / guidance                                                                                                                              |
| --------------------------------------------- | ------------------------------------- | --------------------------------------------------------------------------------------------------------------------------------------------- |
| `argocd/mdai/catalog/globals/base`            | **Always-on global baseline**         | Keep this minimal (e.g., hub + collector). Only true platform prerequisites belong here.                                                      |
| `argocd/mdai/catalog/globals/contracts/*`     | **Shared contracts**                  | Variable keys/types and shared CRs required by solutions. Not environment-specific.                                                           |
| `argocd/mdai/catalog/solutions/<use-case>/vN` | **Reusable solution bundles**         | Parameterized and versioned. If a solution needs “global” CRs, include them under `contracts/` inside the solution (solution-scoped globals). |
| `argocd/mdai/live/<env>/global`               | **Global enablement per environment** | Defines what is enabled cluster-wide in an environment (baseline + globally-on solutions).                                                    |
| `argocd/mdai/live/<env>/teams/<team>`         | **Team enablement and overrides**     | Team-specific parameters and overlays. Inherits baseline + selected solutions + team patches.                                                 |


## Making changes (safe workflow)
1) Edit the right layer (`catalog/` or `live/`)
2) Preview:
   ```bash
   kustomize build argocd/mdai/live/<env>/global > /tmp/global.yaml
   kustomize build argocd/mdai/live/<env>/teams/<team> > /tmp/team.yaml
   ```
3) Open PR and paste relevant `kustomize build` output/diff
4) After merge, sync the smallest-scope Argo app that matches the change:
   - global change → **mdai-global-config-<env>**
   - team-only change → **mdai-team-<team>-<env>**

## Common issues & troubleshooting

| Symptom                                     | Likely cause                                | What to check                                                                     | Fix                                                     |
| ------------------------------------------- | ------------------------------------------- | --------------------------------------------------------------------------------- | ------------------------------------------------------- |
| Child Applications not appearing in Argo CD | `mdai-apps` bootstrap misconfigured         | `mdai-apps` `source.path` is `argocd/apps` and directory recursion is enabled | Fix path or enable `directory.recurse: true`            |
| Applications on different branches          | `targetRevision` mismatch                   | All Applications should reference the same branch/tag                             | Align `targetRevision` across all Applications          |
| Deployments break after template rename     | Kustomize replacement selectors out of date | Replacement selectors still reference old hub/collector names                     | Update replacement selectors to match renamed templates |

### Quick checklist (optional runbook version)

[ ] Verify mdai-apps points to argocd/apps with directory recursion enabled

[ ] Confirm all Argo CD Applications use the same targetRevision

[ ] If renaming hub/collector templates, update all Kustomize replacement selectors

---
See also: [CHANGE_IMPACT_MATRIX.md](./CHANGE_IMPACT_MATRIX.md) and [ANTI_PATTERNS.md](./ANTI_PATTERNS.md).
