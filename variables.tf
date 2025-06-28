# In ./variables.tf

variable "aws_region" {
  description = "AWS region to deploy resources"
  type        = string
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
  description = "Enable AWS-managed NAT Gateway. Set to false if using EC2 instance as NAT."
  type        = bool
}

variable "single_nat_gateway" {
  description = "Use a single AWS-managed NAT Gateway for all AZs. Only applicable if enable_nat_gateway is true."
  type        = bool
}

# --- Granular EC2 variables for AMI, Type, and Count ---

# Bastion-NAT VM
variable "bastion_nat_ami_id" {
  description = "The AMI ID for the Bastion-NAT instance."
  type        = string
  default     = "ami-0328fd517ab093761" # Example default for Amazon Linux 2 (us-east-1) - ADJUST FOR YOUR REGION!
}

variable "bastion_nat_instance_type" {
  description = "The instance type for the Bastion-NAT instance."
  type        = string
  default     = "t2.micro"
}

# General Purpose Private VMs
variable "private_vm_ami_id" {
  description = "The AMI ID for general purpose private VMs."
  type        = string
}

variable "private_vm_instance_type" {
  description = "The instance type for general purpose private VMs."
  type        = string
  default     = "t2.micro"
}

variable "private_vm_count" {
  description = "Number of general purpose private VMs to create (excluding K3s nodes)."
  type        = number
  default     = 0
}

# Internal Public VM (VM-PUBLIC)
variable "internal_public_vm_ami_id" {
  description = "The AMI ID for the Internal Public VM."
  type        = string
}

variable "internal_public_vm_instance_type" {
  description = "The instance type for the Internal Public VM."
  type        = string
  default     = "t2.micro"
}

variable "internal_public_vm_count" {
  description = "Number of Internal Public VMs to create."
  type        = number
  default     = 0
}

# K3s Master Node
variable "k3s_master_ami_id" {
  description = "The AMI ID for the K3s Master node."
  type        = string
}

variable "k3s_master_instance_type" {
  description = "The instance type for the K3s Master node."
  type        = string
  default     = "t2.medium" # K3s master often benefits from more resources
}

# K3s Agent Nodes
variable "k3s_agent_ami_id" {
  description = "The AMI ID for K3s Agent nodes."
  type        = string
}

variable "k3s_agent_instance_type" {
  description = "The instance type for K3s Agent nodes."
  type        = string
  default     = "t2.micro"
}

variable "agent_count" {
  description = "The number of k3s agent nodes to deploy."
  type        = number
  default     = 1
}

# --- SSH Key Names (already existing in AWS) ---
variable "vm_key_name" {
  description = "The SSH key pair name for general Private, Internal Public, and K3s VMs."
  type        = string
}

variable "bastion_key_name" {
  description = "The SSH key pair name for the Bastion-NAT instance."
  type        = string
}

# --- Common naming and tags ---
variable "name_prefix" {
  description = "Prefix for all resource names (e.g., EC2 instances, SSM parameters)."
  type        = string
}

variable "tags" {
  description = "A map of tags to assign to the instances."
  type        = map(string)
  default     = {}
}

# --- Variables for routing ---
variable "private_route_table_ids" {
  description = "A list of private route table IDs to associate with NAT instance route."
  type        = list(string)
  default     = []
}

