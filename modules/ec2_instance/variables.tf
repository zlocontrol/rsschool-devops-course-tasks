

# Common variables for EC2 instances
variable "ami_id" {
  description = "The AMI ID for the instances (used for private and internal public VMs)."
  type        = string
}

variable "instance_type" {
  description = "The instance type for the VMs (e.g., t2.micro)."
  type        = string
  default     = "t2.micro"
}

# --- Variables for different VM types---

# Private VMs (VM-1, VM-2)
variable "private_vm_count" {
  description = "Number of private VMs to create."
  type        = number
  default     = 2
}

variable "private_subnet_ids" {
  description = "A list of private subnet IDs for the private VMs."
  type        = list(string)
}

variable "private_vm_sg_id" {
  description = "Security Group ID for the Private VMs."
  type        = string
}

#  Bastion-NAT VM
variable "bastion_nat_ami_id" {
  description = "The AMI ID for the Bastion-NAT instance."
  type        = string
  default     = "ami-0328fd517ab093761"
}

variable "bastion_nat_instance_type" {
  description = "The instance type for the Bastion-NAT instance."
  type        = string
  default     = "t2.micro"
}

variable "bastion_nat_subnet_id" {
  description = "The ID of the public subnet for the Bastion-NAT instance."
  type        = string
}

variable "bastion_nat_sg_id" {
  description = "Security Group ID for the Bastion-NAT Instance."
  type        = string
}

variable "bastion_nat_key_name" {
  description = "The SSH key pair name for the Bastion-NAT instance."
  type        = string
}




#  Internal Public VM (VM-PUBLIC)
variable "internal_public_vm_subnet_id" {
  description = "The ID of the public subnet for the Internal Public VM."
  type        = string
}

variable "internal_public_vm_sg_id" {
  description = "Security Group ID for the Internal Public VM."
  type        = string
}

# Common key for private and internal public VMs
variable "vm_key_name" {
  description = "The SSH key pair name for the Private and Internal Public VMs."
  type        = string
}


# ---Common variables for all instances ---
variable "name_prefix" {
  description = "Prefix for instance names."
  type        = string
}

variable "tags" {
  description = "A map of tags to assign to the instances."
  type        = map(string)
  default     = {}
}


variable "private_route_table_ids" {
  description = "A list of private route table IDs to associate with NAT instance route."
  type        = list(string)
}



