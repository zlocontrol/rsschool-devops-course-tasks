data "aws_caller_identity" "current" {}

# Trying to find an existing OIDC provider - do not use directly!
data "aws_iam_openid_connect_provider" "existing" {
  url = "https://token.actions.githubusercontent.com"
}

# Create OIDC provider only if not found
resource "aws_iam_openid_connect_provider" "github" {
  count = try(data.aws_iam_openid_connect_provider.existing.arn, null) != null ? 0 : 1

  url             = "https://token.actions.githubusercontent.com"
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = ["6938fd4d98bab03faadb97b34396831e3780fa86"]
}

# Use local variable with ARN
locals {
  maybe_existing     = try(data.aws_iam_openid_connect_provider.existing.arn, null)
  oidc_provider_arn  = local.maybe_existing != null ? local.maybe_existing : aws_iam_openid_connect_provider.github[0].arn

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


# # 2. Create an IAM role that GitHub Actions will assume
# # This role will be used by GitHub Actions to obtain temporary AWS credentials.
resource "aws_iam_role" "github_actions_role" {
  name = "${var.role_name}-${var.environment}"


  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Federated = local.oidc_provider_arn
        },
        Action = "sts:AssumeRoleWithWebIdentity",
        Condition = {
          StringEquals = {
            "token.actions.githubusercontent.com:aud" : "sts.amazonaws.com"
          },
          StringLike = {
            "token.actions.githubusercontent.com:sub" : "repo:${var.github_repo_owner}/${var.github_repo_name}:*"
          }
        }
      }
    ]
  })
}
