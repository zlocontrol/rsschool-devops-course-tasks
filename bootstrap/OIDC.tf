# Получаем текущий AWS аккаунт (используется для построения ARN вручную)
data "aws_caller_identity" "current" {}

# Local values
locals {
  oidc_url        = "https://token.actions.githubusercontent.com"
  oidc_thumbprint = "6938fd4d98bab03faadb97b34396831e3780fa86"
  oidc_provider_arn_manual = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:oidc-provider/token.actions.githubusercontent.com"

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

# Create an OIDC provider - let it always be idempotent
resource "aws_iam_openid_connect_provider" "github" {
  url             = local.oidc_url
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = [local.oidc_thumbprint]
}

# The role that GitHub will use
resource "aws_iam_role" "github_actions_role" {
  name = "${var.role_name}-${var.environment}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Federated = aws_iam_openid_connect_provider.github.arn
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

# Назначаем политики роли
resource "aws_iam_role_policy_attachment" "github_actions_role_policy_attachments" {
  for_each   = toset(local.policies)
  policy_arn = each.value
  role       = aws_iam_role.github_actions_role.name
}
