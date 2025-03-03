resource "time_sleep" "wait_for_eks" {
  depends_on = [module.eks]
  create_duration = "50s"  # Adjust if needed
}

resource "time_sleep" "wait_for_argocd" {
  depends_on = [helm_release.argocd]
  create_duration = "50s"  # Adjust if needed
}
