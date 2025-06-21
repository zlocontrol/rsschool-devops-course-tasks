

variable "vpc_id" {
  description = "The ID of the VPC where security groups will be created"
  type        = string
}

variable "vpc_cidr" {
  description = "The CIDR block of the VPC (used for ingress/egress rules)"
  type        = string
}

variable "common_tags" {
  description = "Common tags to apply to Security Group resources"
  type        = map(string)
}