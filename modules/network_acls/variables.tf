

variable "vpc_id" {
  description = "The ID of the VPC."
  type        = string
}

variable "public_subnet_ids" {
  description = "A list of public subnet IDs to associate with the public NACL."
  type        = list(string)
}

variable "private_subnet_ids" {
  description = "A list of private subnet IDs to associate with the private NACL."
  type        = list(string)
}

variable "vpc_cidr" {
  description = "The CIDR block of the VPC."
  type        = string
}

variable "name_prefix" {
  description = "A prefix for naming resources."
  type        = string
}

variable "common_tags" {
  description = "Common tags to apply to all resources."
  type        = map(string)
  default     = {}
}