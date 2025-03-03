resource "kubectl_manifest" "app_of_apps" {
  yaml_body = file("${path.module}/monitoring-app.yaml")
  depends_on = [time_sleep.wait_for_argocd]
}
