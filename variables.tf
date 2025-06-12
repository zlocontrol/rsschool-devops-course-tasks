variable "aws_region" {
  description = "AWS region to deploy resources"

}

variable "iam_user_name" {
  description = "Name IAM User"
  type        = string
}


variable "group_name" {
  description = "Name IAM group"
  type        = string
}

variable "role_name" {
  description = "Role IAM"
  type        = string
}









variable "github_repo_owner" {
  description = "Owner (organization or user) GitHub-репозитория для OIDC."
  type        = string
  default     = "zlocontrol"
}

variable "github_repo_name" {
  description = "The name of the GitHub repository for OIDC."
  type        = string
  default     = "rsschool-devops-course-tasks" #
}





variable "project_name" {
  description = "Project name (for tags)"
  type        = string
  default     = "project*"
}

# Название бакета (без уникального суффикса)
variable "s3_bucket_name" {
  description = "Base name for the S3 bucket to store Terraform state"
  type        = string
}

# Название DynamoDB таблицы для блокировки стейта
variable "dynamodb_table_name" {
  description = "Name of the DynamoDB table used for Terraform state locking"
  type        = string
}

# Общие теги (словарь key = value)
variable "common_tags" {
  description = "A map of tags to apply to resources"
  type        = map(string)
  default = {
    Owner     = "your-name"
    ManagedBy = "Terraform"
    Project   = "DevOps Course"
  }
}

variable "environment" {
  description = "Environment (eg dev, prod)"
  type        = string
  default     = "dev"
}





variable "owner" {
  description = "Owner of the infrastructure"
  type        = string
  default     = "devops-team"
}