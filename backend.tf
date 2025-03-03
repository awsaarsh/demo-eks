terraform {
  backend "s3" {
    bucket  = "my-terraform-backend"
    key     = "eks-cluster/terraform.tfstate"
    region  = "us-east-1"
    encrypt = true
  }
}
