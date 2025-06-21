provider "aws" {
  region = var.aws_region # use chosen region
}

module "label" {
  source  = "cloudposse/label/null"
  version = "0.25.0"
}



