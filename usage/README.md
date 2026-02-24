# MyDecisive Argo Example (Operator + Contributor Guide)

This repository manages **collector behavior and governance** for the MyDecisive/OpenTelemetry Smart Hub using Argo CD + GitOps.

>[!INFO]
>
>New here? Start with
>* [HOW_TO_READ_DOCS.md](./HOW_TO_READ_DOCS.md)
>* [REPO_STRUCTURE.md](./REPO_STRUCTURE.md).


## What this repo controls
- Use-case "solutions" (PII redaction, data filtration, routing, etc.)
- Global baselines and shared “contracts” (variable schemas, shared CRs required by a solution)
- Team-specific overrides (regex/templates, parameter values)

## What this repo does NOT control
- Application workloads
- Secrets (store/consume references only)
- One-off manual cluster hotfixes (avoid `kubectl apply`)

## Golden Rule
**Argo CD syncs only from `argocd/mdai/live/**`.**
Everything under `argocd/mdai/catalog/**` is a library and has no effect unless referenced from `live/`.

## Argo CD Applications (what you’ll see in Argo UI)

| Application name               | Type / role               | What it does                                                             | Source path                           |
| ------------------------------ | ------------------------- | ------------------------------------------------------------------------ | ------------------------------------- |
| **`mdai-apps`**                | App-of-apps (bootstrap)   | Discovers and creates child Applications for **dev** by default          | `argocd/apps/**`                  |
| **`mdai`**                     | Platform install          | Installs platform components (Helm charts, operators, controllers, CRDs) | Platform chart source                 |
| **`mdai-global-config-<env>`** | Environment global config | Applies environment-wide configuration and shared resources              | `argocd/mdai/live/<env>/global`       |
| **`mdai-team-<team>-<env>`**   | Team bundle               | Deploys all workloads and overrides for a single team in an environment  | `argocd/mdai/live/<env>/teams/<team>` |

### Notes (optional, but useful)

- Dev Applications are created automatically via `mdai-apps`
- Prod Applications exist only after enabling `mdai-apps-prod` and require manual sync
- Team Applications have a bounded blast radius (team + env only)


### Dev vs Prod

| Aspect                | Dev                                   | Prod                           |
| --------------------- | ------------------------------------- | ------------------------------ |
| Bootstrap Application | `mdai-apps`                           | `mdai-apps-prod`               |
| Discovery path        | `argocd/apps/**`                  | `argocd/apps/prod/**`          |
| Enabled by default    | ✅ Yes                                 | ❌ No (explicitly enabled)      |
| Sync mode             | **Automated** (auto-sync + self-heal) | **Manual only**                |
| Self-healing          | Enabled                               | Disabled                       |
| Change activation     | Immediate on merge                    | Requires human approval + sync |
| Primary goal          | Speed & feedback                      | Safety & control               |
| Typical usage         | Continuous development                | Scheduled releases / incidents |


---


Start at [DOCS_INDEX.md](DOCS_INDEX.md) for the full map.
