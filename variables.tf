variable "aws_region" {
  description = "AWS region to deploy resources"
}

# IAM user and group variables (task 1)
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

# OIDC GitHub integration (task 1 or bootstrap)
variable "github_repo_owner" {
  description = "Owner (organization or user) GitHub-репозитория для OIDC."
  type        = string
  default     = "zlocontrol"
}

variable "github_repo_name" {
  description = "The name of the GitHub repository for OIDC."
  type        = string
  default     = "rsschool-devops-course-tasks"
}

# Project info and tags
variable "project_name" {
  description = "Project name (for tags)"
  type        = string
  default     = "project*"
}

variable "owner" {
  description = "Owner of the infrastructure"
  type        = string
  default     = "devops-team"
}

variable "environment" {
  description = "Environment (e.g., dev, prod)"
  type        = string
  default     = "dev"
}

variable "common_tags" {
  description = "A map of tags to apply to resources"
  type        = map(string)
  default = {
    Owner     = "your-name"
    ManagedBy = "Terraform"
    Project   = "DevOps Course"
  }
}

# Remote backend
variable "s3_bucket_name" {
  description = "Base name for the S3 bucket to store Terraform state"
  type        = string
}

# VPC module input
variable "vpc_name" {
  description = "Name of the VPC"
  type        = string
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
}

variable "azs" {
  description = "List of availability zones"
  type        = list(string)
}

variable "public_subnets" {
  description = "List of CIDRs for public subnets"
  type        = list(string)
}

variable "private_subnets" {
  description = "List of CIDRs for private subnets"
  type        = list(string)
}

variable "enable_nat_gateway" {
  description = "Enable NAT Gateway"
  type        = bool
}

variable "single_nat_gateway" {
  description = "Use a single NAT Gateway for all AZs"
  type        = bool
}

# EC2 instances and NAT instance (task 3)
variable "ami_id" {
  description = "AMI ID for EC2 instances"
}

variable "instance_type" {
  description = "Instance type"
  default     = "t2.micro"
}

variable "instance_count" {
  description = "How many EC2 VMs to create"
  default     = 2
}

variable "security_group_id" {
  description = "Security group ID for VM access"
  type        = string
}

variable "assign_public_ip" {
  description = "Assign public IP to EC2"
  type        = bool
  default     = false
}

variable "create_nat_instance" {
  description = "Enable NAT instance"
  type        = bool
  default     = false
}

variable "nat_ami_id" {
  description = "AMI ID for NAT instance"
  default     = "ami-0328fd517ab093761"
}

variable "nat_instance_type" {
  description = "Instance type for NAT"
  default     = "t2.micro"
}

variable "name_prefix" {
  description = "Prefix for EC2 instance names"
  type        = string
}

variable "tags" {
  description = "Extra tags for EC2 instances"
  type        = map(string)
  default     = {}
}

variable "vm_key_name" {
  description = "SSH key name for virtual machines"
  type        = string
}

variable "bastion_key_name" {
  description = "SSH key name for NAT instance"
  type        = string
}