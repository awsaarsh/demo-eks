terraform {
  backend "s3" {
    bucket  = "aarsh-testeks"
    key     = "eks-cluster/terraform.tfstate"
    region  = "us-east-1"
    encrypt = true
  }
}
