terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}

# Configure the AWS Provider
provider "aws" {
  region = "us-east-1"
}

module "forensics_lab" {
  source     = "./modules/forensics_lab"
  for_each   = data.aws_regions.avail_regions.names
  aws_region = each.value
  depends_on = [
    data.aws_regions.avail_regions,
    aws_iam_role_policy_attachment.session_manager_core,
  ]
}
