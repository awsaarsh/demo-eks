resource "aws_iam_role" "argocd_irsa_role" {
  name = "argocd-irsa-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Federated = module.eks.oidc_provider_arn
        }
        Action = "sts:AssumeRoleWithWebIdentity"
        Condition = {
          StringEquals = {
            "${module.eks.oidc_provider}:sub" = "system:serviceaccount:argocd:argocd-server"
          }
        }
      }
    ]
  })
}

resource "aws_iam_policy" "argocd_policy" {
  name        = "argocd-policy"
  description = "Policy for ArgoCD to access EKS cluster"
  policy      = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = ["eks:DescribeCluster"]
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "argocd_attach" {
  role       = aws_iam_role.argocd_irsa_role.name
  policy_arn = aws_iam_policy.argocd_policy.arn
}
