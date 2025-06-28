

# --- Outputs for Bastion-NAT VM ---
output "bastion_nat_vm_id" {
  description = "The ID of the Bastion-NAT EC2 instance."
  value       = aws_instance.bastion_nat_vm.id # Исправлено: прямая ссылка на ресурс
}

output "bastion_nat_public_dns" {
  description = "Public DNS of the Bastion-NAT instance."
  value       = aws_instance.bastion_nat_vm.public_dns # Исправлено: прямая ссылка на ресурс
}

output "bastion_nat_public_ip" {
  description = "Public IP address of the Bastion-NAT instance."
  value       = aws_instance.bastion_nat_vm.public_ip # Исправлено: прямая ссылка на ресурс
}

output "bastion_nat_private_ip" {
  description = "Private IP address of the Bastion-NAT instance."
  value       = aws_instance.bastion_nat_vm.private_ip # Исправлено: прямая ссылка на ресурс
}

# --- Outputs for General Purpose Private VMs (using count) ---
output "private_vm_ids" {
  description = "List of IDs for general purpose private VMs."
  value       = aws_instance.private_vm.*.id
}

output "private_vm_private_ips" {
  description = "List of private IP addresses for general purpose private VMs."
  value       = aws_instance.private_vm.*.private_ip
}

# --- Outputs for Internal Public VMs (using count) ---
output "internal_public_vm_ids" {
  description = "List of IDs for internal public VMs."
  value       = aws_instance.internal_public_vm.*.id
}

output "internal_public_vm_public_dns_names" {
  description = "List of public DNS names for internal public VMs."
  value       = aws_instance.internal_public_vm.*.public_dns
}

output "internal_public_vm_public_ips" {
  description = "List of public IP addresses for internal public VMs."
  value       = aws_instance.internal_public_vm.*.public_ip
}

output "internal_public_vm_private_ips" {
  description = "List of private IP addresses for internal public VMs."
  value       = aws_instance.internal_public_vm.*.private_ip
}

# --- Outputs for K3s Master Node (single instance) ---
output "k3s_master_id" {
  description = "The ID of the K3s master node."
  value       = aws_instance.k3s_master.id
}



# --- Outputs for K3s Agent Nodes (using count) ---
output "k3s_agent_ids" {
  description = "List of IDs for K3s agent nodes."
  value       = aws_instance.k3s_agents.*.id
}

output "k3s_agent_private_ips" {
  description = "List of private IP addresses for K3s agent nodes."
  value       = aws_instance.k3s_agents.*.private_ip
}

# --- OUTPUTS (for external access, e.g., bastion IP) ---
output "bastion_public_dns" {
  description = "The public DNS name of the bastion host."
  value       = aws_instance.bastion_nat_vm.public_dns
}

output "k3s_master_private_ip" {
  description = "The private IP address of the K3s master node."
  value       = aws_instance.k3s_master.private_ip
}

###################################################################
