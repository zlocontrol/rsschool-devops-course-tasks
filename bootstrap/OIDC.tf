# Get the ID of the current AWS account
data "aws_caller_identity" "current" {}


# We are trying to create an OIDC provider (if it does not exist yet)
resource "aws_iam_openid_connect_provider" "github" {
  count           = var.create_oidc_provider ? 1 : 0
  url             = "https://token.actions.githubusercontent.com"
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = ["6938fd4d98bab03faadb97b34396831e3780fa86"] # ВОЗВРАЩЕНО: thumbprint_list обязателен!
}

# Get the ARN of an existing OIDC provider if it is NOT created by this code.
#
data "aws_iam_openid_connect_provider" "github_existing" {
  count = var.create_oidc_provider ? 0 : 1 # Загружаем только если create_oidc_provider = false
  url   = "https://token.actions.githubusercontent.com"
}

# General local values
locals {
  oidc_provider_arn = var.create_oidc_provider ? (
    aws_iam_openid_connect_provider.github[0].arn
    ) : (
    data.aws_iam_openid_connect_provider.github_existing[0].arn
  )

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

# IAM роль
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

# Прикрепляем IAM политики
resource "aws_iam_role_policy_attachment" "github_actions_role_policy_attachments" {
  for_each   = toset(local.policies)
  policy_arn = each.value
  role       = aws_iam_role.github_actions_role.name
}