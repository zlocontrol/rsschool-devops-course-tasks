variable "vpc_name" {
  description = "VPC Name"
  type        = string
}

variable "vpc_cidr" {
  description = "CIDR блока VPC"
  type        = string
}

variable "azs" {
  description = "List AZ (например, [\"us-east-1a\", \"us-east-1b\"])"
  type        = list(string)
}

variable "public_subnets" {
  description = "CIDR для публичных подсетей"
  type        = list(string)
}

variable "private_subnets" {
  description = "CIDR для приватных подсетей"
  type        = list(string)
}

variable "enable_nat_gateway" {
  description = "Should I enable NAT Gateway?"
  type        = bool
  default     = false
}

variable "single_nat_gateway" {
  description = "One NAT Gateway for all subnets"
  type        = bool
  default     = false
}

variable "tags" {
  description = "Tags for resources"
  type        = map(string)
  default     = {}
}
