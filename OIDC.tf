# Получаем ID текущего AWS аккаунта. Это удобно для формирования ARNs.
data "aws_caller_identity" "current" {}

# 1. Создание OIDC-провайдера для GitHub Actions
# Этот ресурс AWS IAM OIDC Provider говорит AWS доверять JWT-токенам,
# выпущенным GitHub Actions по указанному URL.
resource "aws_iam_openid_connect_provider" "github" {
  url = "https://token.actions.githubusercontent.com"
  client_id_list = [
    "sts.amazonaws.com", # Это Client ID (или Audience), который AWS STS ожидает в токене
  ]
  # thumbprint - это отпечаток корневого сертификата GitHub. Он стабилен, но может быть обновлен.
  # Актуальный всегда можно найти в документации GitHub или AWS, или получить с помощью OpenSSL.
  thumbprint_list = ["6938fd4d98bab03faadb97b34396831e3780fa86"]
}




# 3. Прикрепление политик к IAM-роли GithubActionsRole
# Используем ваш ранее определенный локальный список политик 'policies'.
resource "aws_iam_role_policy_attachment" "github_actions_role_policy_attachments" {
  for_each   = toset(local.policies) # Итерируем по всем политикам в locals.policies
  policy_arn = each.value            # ARN текущей политики из списка
  role       = aws_iam_role.github_actions_role.name # Имя созданной IAM-роли
}



# # 2. Создание IAM-роли, которую будут принимать GitHub Actions
# # Эта роль будет использоваться GitHub Actions для получения временных учетных данных AWS.
resource "aws_iam_role" "github_actions_role" {
  name = "GithubActionsRole"

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
            # Этот ключ указывает, что токен должен быть предназначен для AWS STS.
            "token.actions.githubusercontent.com:aud": "sts.amazonaws.com"
          },
          StringLike = {
            # Этот ключ указывает на конкретный репозиторий GitHub, который может принимать роль.
            # Формат: "repo:<Организация_GitHub>/<Имя_Репозитория>:*"
            # '*' означает любую ветку/тег в этом репозитории.
            # ОБЯЗАТЕЛЬНО УБЕДИТЕСЬ, что имя организации и репозитория указаны ВЕРНО.
            "token.actions.githubusercontent.com:sub": "repo:${var.github_repo_owner}/${var.github_repo_name}:*"
          }
        }
      }
    ]
  })
}

