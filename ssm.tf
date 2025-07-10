


resource "random_password" "k3s_token_generator" {
  length  = 32
  special = false
}


resource "aws_ssm_parameter" "k3s_token_parameter" {
  name        = "/${var.name_prefix}/k3s_token"
  type        = "SecureString"
  value       = random_password.k3s_token_generator.result
  description = "K3s cluster token for ${module.label.id}"
  overwrite   = true
  tags        = local.common_tags
}
