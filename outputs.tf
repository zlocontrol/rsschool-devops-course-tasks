

# --- Outputs from Bastion-NAT VM (via compute module) ---
output "bastion_nat_vm_id" {
  description = "The ID of the Bastion-NAT EC2 instance."
  value       = module.compute.bastion_nat_vm_id # <-- Правильная ссылка на выход модуля
}

output "bastion_nat_public_dns" {
  description = "Public DNS of the Bastion-NAT instance."
  value       = module.compute.bastion_nat_public_dns # <-- Правильная ссылка на выход модуля
}

output "bastion_nat_public_ip" {
  description = "Public IP address of the Bastion-NAT instance."
  value       = module.compute.bastion_nat_public_ip # <-- Правильная ссылка на выход модуля
}

output "bastion_nat_private_ip" {
  description = "Private IP address of the Bastion-NAT instance."
  value       = module.compute.bastion_nat_private_ip # <-- Правильная ссылка на выход модуля
}

# --- Outputs from General Purpose Private VMs (via compute module) ---
output "private_vm_ids" {
  description = "The list of IDs of the private EC2 instances."
  value       = module.compute.private_vm_ids # <-- Правильная ссылка на выход модуля
}

output "private_vm_private_ips" {
  description = "Private IP addresses of the private VMs."
  value       = module.compute.private_vm_private_ips # <-- Правильная ссылка на выход модуля
}

# --- Outputs from Internal Public VM (via compute module) ---
output "internal_public_vm_ids" {
  description = "List of IDs for internal public VMs."
  value       = module.compute.internal_public_vm_ids # <-- Правильная ссылка на выход модуля
}

output "internal_public_vm_public_dns_names" {
  description = "List of public DNS names for internal public VMs."
  value       = module.compute.internal_public_vm_public_dns_names # <-- Правильная ссылка на выход модуля
}

output "internal_public_vm_public_ips" {
  description = "List of public IP addresses for internal public VMs."
  value       = module.compute.internal_public_vm_public_ips # <-- Правильная ссылка на выход модуля
}

output "internal_public_vm_private_ips" {
  description = "List of private IP addresses for internal public VMs."
  value       = module.compute.internal_public_vm_private_ips # <-- Правильная ссылка на выход модуля
}


# --- Outputs for K3s Master Node (via compute module) ---
output "k3s_master_id" {
  description = "The ID of the K3s master node."
  value       = module.compute.k3s_master_id # <-- Правильная ссылка на выход модуля
}

output "k3s_master_private_ip" {
  description = "The private IP address of the K3s master node."
  value       = module.compute.k3s_master_private_ip # <-- Правильная ссылка на выход модуля
}

# --- Outputs for K3s Agent Nodes (via compute module) ---
output "k3s_agent_ids" {
  description = "List of IDs for K3s agent nodes."
  value       = module.compute.k3s_agent_ids # <-- Правильная ссылка на выход модуля
}

output "k3s_agent_private_ips" {
  description = "List of private IP addresses for K3s agent nodes."
  value       = module.compute.k3s_agent_private_ips # <-- Правильная ссылка на выход модуля
}

# --- Existing VPC and Security Group Outputs (remain as is, assuming they are correct) ---
output "vpc_id" {
  description = "The ID of the VPC"
  value       = module.vpc.vpc_id
}

output "public_subnet_ids" {
  description = "The IDs of the public subnets"
  value       = module.vpc.public_subnets
}

output "private_subnet_ids" {
  description = "The IDs of the private subnets"
  value       = module.vpc.private_subnets
}

output "bastion_nat_sg_id" {
  description = "The ID of the Bastion/NAT Security Group."
  value       = module.security_groups.bastion_nat_sg_id
}

output "internal_public_vm_sg_id" {
  description = "The ID of the Internal Public VM Security Group."
  value       = module.security_groups.internal_public_vm_sg_id
}

output "private_vm_sg_id" {
  description = "The ID of the Private VM Security Group."
  value       = module.security_groups.private_vm_sg_id
}

