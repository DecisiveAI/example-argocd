# Onboarding – Managing MyDecisive GitOps (Day 1 → Day N)

## Day 1 (Understand)
1) Read:
- [DOCS_INDEX.md](./DOCS_INDEX.md)
- [ARCHITECTURE.md](./ARCHITECTURE.md)
2) Build locally:
```bash
kustomize build argocd/mdai/live/<env>/global
kustomize build argocd/mdai/live/<env>/teams/team-payments
```
3) Learn the Argo apps:
- mdai-apps (bootstrap)
- mdai (platform)
- mdai-global-config-<env> (global behavior)
- mdai-team-<team> (team behavior)

## Day 2 (Make a safe change)
- Change a team override value (regex/template) under:
  `argocd/mdai/live/<env>/teams/<team>/patches/`
- Preview with `kustomize build`
- Open a PR using `PULL_REQUEST_TEMPLATE.md`

## Day 7 (Add a team)
1) Copy team overlay + live bundle
2) Set `HUB_NAME` and `HUB_VARS_CM` in the team params ConfigMap
3) Add an Argo Application under `argocd/apps/teams/` (dev is enabled by default)

> If/when you later enable production (see root README), add a corresponding prod Application under `argocd/apps/prod/`.
4) Preview + PR

## Day N (Add a solution)
- Create `argocd/mdai/catalog/solutions/<use-case>/v1`
- Keep it reusable and parameterized
- If the solution requires “global” CRs, place them under the solution’s `contracts/` folder
- Enable it for one team first
