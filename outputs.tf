

#  Bastion-NAT VM
output "bastion_nat_vm_id" {
  description = "The ID of the Bastion-NAT EC2 instance."
  value       = module.compute.bastion_nat_vm_id
}

output "bastion_nat_public_dns" {
  description = "Public DNS of the Bastion-NAT instance."
  value       = module.compute.bastion_nat_public_dns
}

output "bastion_nat_public_ip" {
  description = "Public IP address of the Bastion-NAT instance."
  value       = module.compute.bastion_nat_public_ip
}

output "bastion_nat_private_ip" {
  description = "Private IP address of the Bastion-NAT instance."
  value       = module.compute.bastion_nat_private_ip
}

#  Private VMs
output "private_vm_ids" {
  description = "The list of IDs of the private EC2 instances."
  value       = module.compute.private_vm_ids
}

output "private_vm_private_ips" {
  description = "Private IP addresses of the private VMs."
  value       = module.compute.private_vm_private_ips
}

#  Internal Public VM
output "internal_public_vm_id" {
  description = "The ID of the Internal Public EC2 instance."
  value       = module.compute.internal_public_vm_id
}

output "internal_public_vm_public_dns" {
  description = "Public DNS of the Internal Public VM."
  value       = module.compute.internal_public_vm_public_dns
}

output "internal_public_vm_public_ip" {
  description = "Public IP address of the Internal Public VM."
  value       = module.compute.internal_public_vm_public_ip
}

output "internal_public_vm_private_ip" {
  description = "Private IP address of the Internal Public VM."
  value       = module.compute.internal_public_vm_private_ip
}


#  VPC
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