

# --- AMI and Instance Type for Bastion-NAT VM ---
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

# --- AMI and Instance Type for General Purpose Private VMs ---
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

# --- AMI, Instance Type, and Count for Internal Public VM (VM-PUBLIC) ---
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
  default     = 0 # Changed default to 0 for optional creation
}

# --- AMI and Instance Type for K3s Master Node ---
variable "k3s_master_ami_id" {
  description = "The AMI ID for the K3s Master node."
  type        = string
}

variable "k3s_master_instance_type" {
  description = "The instance type for the K3s Master node."
  type        = string
  default     = "t2.medium" # K3s master often benefits from more resources
}

# --- AMI and Instance Type for K3s Agent Nodes ---
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

# --- Other existing variables (subnets, SGs, keys, etc.) ---

variable "private_subnet_ids" {
  description = "A list of private subnet IDs for the private VMs (including K3s nodes)."
  type        = list(string)
}

variable "private_vm_sg_id" {
  description = "Security Group ID for the Private VMs (including K3s nodes)."
  type        = string
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

variable "internal_public_vm_subnet_id" {
  description = "The ID of the public subnet for the Internal Public VM."
  type        = string
}

variable "internal_public_vm_sg_id" {
  description = "Security Group ID for the Internal Public VM."
  type        = string
}

variable "vm_key_name" {
  description = "The SSH key pair name for general Private, Internal Public, and K3s VMs."
  type        = string
}

# --- Variables for SSM and IAM for K3s ---
variable "k3s_ec2_profile_name" {
  description = "The name of the IAM Instance Profile to attach to k3s nodes for SSM access."
  type        = string
}

variable "k3s_token_ssm_path" {
  description = "The SSM Parameter Store path where the k3s token is stored."
  type        = string
}

# --- Common naming and tags ---
variable "name_prefix" {
  description = "Prefix for instance names and SSM parameters."
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

# --- AWS Region for user_data scripts ---
variable "aws_region" {
  description = "The AWS region where resources will be deployed."
  type        = string
}



variable "private_subnet_attributes" {
  description = "Map of private subnet attributes by availability zone, used for route table configuration."
  type = map(object({
    id             = string
    cidr_block     = string
    route_table_id = string # ID таблицы маршрутизации для этой подсети
  }))
}
variable "k3s_token" {
  type = string
}

# 6. GitHub Actions Self-hosted Runner Node
variable "gha_runner_ami_id" {
  description = "AMI ID для GitHub Actions Runner EC2"
}

variable "gha_runner_instance_type" {
  description = "EC2 instance type для Runner"
  default     = "t2.micro"
}

# variable "gha_runner_sg_id" {
#   description = "Security Group ID для Runner"
# }

variable "github_url" {
  description = "GitHub URL (exemple https://github.com/zlocontrol)"
}



variable "runner_token" {
  description = "GitHub Runner registration token (taken from Settings → Actions → Runners)"
}

variable "repo_owner" {
  description = "GitHub repo owner"
  type        = string
}

variable "repo_name" {
  description = "GitHub repo name (without owner)"
  type        = string
}
