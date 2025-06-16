# Get the current AWS account
data "aws_caller_identity" "current" {}

# Trying to find an existing GitHub OIDC provider
data "aws_iam_openid_connect_provider" "existing" {
  url = "https://token.actions.githubusercontent.com"
}

# Create only if not found
resource "aws_iam_openid_connect_provider" "github" {
  count = can(data.aws_iam_openid_connect_provider.existing.arn) ? 0 : 1

  url             = "https://token.actions.githubusercontent.com"
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = ["6938fd4d98bab03faadb97b34396831e3780fa86"]
}

# Local variable with ARN
locals {
  oidc_provider_arn = can(data.aws_iam_openid_connect_provider.existing.arn) ?
    data.aws_iam_openid_connect_provider.existing.arn :
    aws_iam_openid_connect_provider.github[0].arn

  policies = [
    "arn:aws:iam::aws:policy/AmazonEC2FullAccess",
    "arn:aws:iam::aws:policy/AmazonRoute53FullAccess",
    "arn:aws:iam::aws:policy/AmazonS3FullAccess",
    "arn:aws:iam::aws:policy/IAMFullAccess",
    "arn:aws:iam::aws:policy/AmazonVPCFullAccess",
    "arn:aws:iam::aws:policy/AmazonSQSFullAccess",
    "arn:aws:iam::aws:policy/AmazonEventBridgeFullAccess",
  ]
}
