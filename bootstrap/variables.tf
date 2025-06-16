variable "aws_region" {
  description = "AWS region to deploy resources"

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

#name bucket
variable "s3_bucket_name" {
  description = "Base name for the S3 bucket to store Terraform state"
  type        = string
}

# general tag (словарь key = value)
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

variable "create_oidc_provider" {
  description = "Create GitHub OIDC provider?"
  type        = bool
  default     = true
}