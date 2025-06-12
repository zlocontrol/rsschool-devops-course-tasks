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
  description = "Владелец (организация или пользователь) GitHub-репозитория для OIDC."
  type        = string
  default     = "zlocontrol" # <--- Установите владельца по умолчанию
}

variable "github_repo_name" {
  description = "Имя GitHub-репозитория для OIDC."
  type        = string
  default     = "rsschool-devops-course-tasks" # <--- Установите имя репозитория по умолчанию
}



