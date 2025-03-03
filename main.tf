# provider "aws" {
#   region = "us-east-1"  # Set to your preferred region
# }

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "4.0.0"  # Adjust the version as needed

  name            = "example-vpc"
  cidr            = "10.0.0.0/16"
  azs             = ["us-east-1a", "us-east-1b", "us-east-1c"]  # Use supported AZs
  private_subnets = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  public_subnets  = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]

  enable_nat_gateway = true
  single_nat_gateway = true
  enable_dns_hostnames = true
  enable_dns_support = true

  tags = {
    Terraform   = "true"
    Environment = "dev"
  }
}

module "eks" {
  source          = "terraform-aws-modules/eks/aws"
  version         = "19.13.0"  # Use your module version

  cluster_name    = "eks-cluster"
  cluster_version = "1.26"

  vpc_id          = module.vpc.vpc_id
  subnet_ids      = module.vpc.private_subnets  # Replace with your subnet IDs
  cluster_endpoint_public_access  = true  # Enables public access
  cluster_endpoint_private_access = false  # Enables private access
  enable_irsa = true
  # Optional: Specify a custom domain for the EKS cluster
#   domain          = "example.com"

  eks_managed_node_groups = {
    ascode-cluster-wg = {
      min_size     = 1
      max_size     = 1
      desired_size = 1

      instance_types = ["t3.medium"]
      additional_security_group_ids = [
        aws_security_group.custom_sg.id
      ]
    #   capacity_type  = "SPOT"

      tags = {
        ExtraTag = "helloworld"
      }
    }
  }

}

resource "aws_security_group" "custom_sg" {
  name        = "custom-worker-sg"
  description = "Custom security group for EKS worker nodes"
  vpc_id      = module.vpc.vpc_id

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Replace with your CIDR range
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_s3_bucket" "aarsh-testeks" {
  bucket = "aarsh-testeks"
}

resource "aws_s3_bucket_versioning" "terraform_state" {
  bucket = aws_s3_bucket.aarsh-testeks.id
  versioning_configuration {
    status = "Enabled"
  }
}

# resource "aws_s3_bucket_policy" "terraform_state_policy" {
#   bucket = aws_s3_bucket.terraform_state.id
#   policy = jsonencode({
#     Version = "2012-10-17",
#     Statement = [
#       {
#         Effect = "Allow",
#         Principal = "*",
#         Action = [
#           "s3:ListBucket",
#           "s3:GetObject",
#           "s3:PutObject",
#           "s3:DeleteObject"
#         ],
#         Resource = [
#            "arn:aws:s3:::my-terraform-backend",
#            "arn:aws:s3:::my-terraform-backend/*"
#         ]
#       }
#     ]
#   })
# }