provider "helm" {
  kubernetes {
    # config_path = "~/.kube/config"
    host = module.eks.cluster_endpoint
    token = data.aws_eks_cluster_auth.cluster.token
    cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)
  }
}

# data "aws_eks_cluster" "eks" {
#   name = module.eks.cluster_id
# }

data "aws_eks_cluster_auth" "eks_auth" {
  name = module.eks.cluster_name
}

resource "helm_release" "argocd" {
  name       = "argocd"
  chart      = "argo-cd"
  repository = "https://argoproj.github.io/argo-helm"
  namespace  = "argocd"
  version    = "5.45.2"

  create_namespace = true
  set {
    name  = "serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
    value = aws_iam_role.argocd_irsa_role.arn
  }

  values = [
    file("argocd-values.yaml") # Optional for custom values
  ]
  depends_on = [
    module.eks,
    time_sleep.wait_for_eks,     # Ensures EKS is fully created
    # data.aws_eks_cluster.eks,      # Ensures Terraform fetches EKS cluster details
    data.aws_eks_cluster_auth.eks_auth # Ensures authentication is ready
  ]
}
