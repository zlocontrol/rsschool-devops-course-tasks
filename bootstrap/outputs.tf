output "s3_bucket_name" {
  value = aws_s3_bucket.terraform_state.id
  sensitive = true
}


output "github_role_arn" {
  description = "ARN of the GitHub OIDC IAM role"
  value       = aws_iam_role.github_actions_role.arn
  sensitive = true
}
