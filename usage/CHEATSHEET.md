# One-Page Cheat Sheet

## The Golden Rule
**Argo CD syncs only from `argocd/mdai/live/<env>/**` (never from `catalog/`).**

See: [REPO_STRUCTURE.md](./REPO_STRUCTURE.md) for the directory contract.


## Which Argo app do I sync?
- Platform broken / CRDs missing → **mdai**
- Global baseline change → **mdai-global-config-<env>**
- One team change → **mdai-team-<team>-<env>**
- Argo not creating child apps → **mdai-apps**

## Where do I edit?
| Task | File/Folder |
|---|---|
| Change platform install (Helm values) | `argocd/apps/mdai.yaml` + `argocd/mdai/chart/` |
| Change global baseline | `argocd/mdai/live/<env>/global/` (references catalog) |
| Enable/disable solution for a team | `argocd/mdai/live/<env>/teams/<team>/kustomization.yaml` |
| Change solution behavior | `argocd/mdai/catalog/solutions/<use-case>/vN/` |
| Change shared contract (e.g., variables schema) | `argocd/mdai/catalog/globals/contracts/<name>/` |
| Team override (regex/template) | `argocd/mdai/live/<env>/teams/<team>/patches/` |
| Add a new team app (dev) | `argocd/apps/teams/<team>.yaml` |
| Add a new team app (prod, when enabled) | `argocd/apps/prod/team-<team>-prod.yaml` |

## Preview what Argo will apply
```bash
kustomize build argocd/mdai/live/<env>/global
kustomize build argocd/mdai/live/<env>/teams/<team>
```

## Add a new team (fast)
1) Copy a team overlay + live bundle:
```bash
cp -r argocd/mdai/live/<env>/teams/team-example argocd/mdai/live/<env>/teams/team-new
```
2) Set `HUB_NAME` + `HUB_VARS_CM` in the team params ConfigMap.
3) Add the team Argo Application:
   - dev: `argocd/apps/teams/team-new.yaml`
   - prod: `argocd/apps/prod/team-new-prod.yaml` (only needed once you decide to enable prod)

## Common gotcha
All apps should point at the **same `targetRevision`** (same branch/tag) so Argo sees the same repo state.
