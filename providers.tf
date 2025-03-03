# provider "aws"{
#     region = "us-east-1"
# }

# provider "kubernetes"  {
#     config_path = "~/.kube/config"
#     # token = data.aws_eks_cluster_auth.cluster.token
#     host = module.eks.cluster_endpoint
#     token = data.aws_eks_cluster_auth.cluster.token
#     cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)
#   }

# data "aws_eks_cluster_auth" "cluster" {
#   name = module.eks.cluster_name
# }

####


# --- AWS Provider ---
provider "aws" {
  region = "us-east-1"  # Change to your preferred region
}

# --- EKS Cluster Authentication Data Source ---
data "aws_eks_cluster_auth" "cluster" {
  name = module.eks.cluster_name
}

# --- Kubernetes Provider ---
provider "kubectl" {
  host                   = module.eks.cluster_endpoint
  token                  = data.aws_eks_cluster_auth.cluster.token
  cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)
}

terraform {
  required_providers {
    kubectl = {
      source  = "gavinbunney/kubectl"
      version = "~> 1.14.0" # Use the latest compatible version
    }
  }
}