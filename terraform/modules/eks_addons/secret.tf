resource "kubernetes_secret" "argocd_github_cred" {
  depends_on = [module.eks_blueprints_addons.argocd]
  metadata {
    name      = var.argocd_gh_cred
    namespace = var.argocd_namespace
    labels = {
      "argocd.argoproj.io/secret-type" : "repo-creds"
    }
  }

  type = "Opaque"

  data = {
    url                     = var.argocd_repo_url
    type                    = "git"
    githubAppID             = var.argocd_gh_app_id
    githubAppInstallationID = var.argocd_gh_app_installation_id
    githubAppPrivateKey     = var.argocd_gh_app_private_key
  }
}
