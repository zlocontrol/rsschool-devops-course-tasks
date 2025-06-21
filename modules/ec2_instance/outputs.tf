

# Output  Bastion-NAT VM
output "bastion_nat_vm_id" {
  description = "The ID of the Bastion-NAT EC2 instance."
  value       = aws_instance.bastion_nat_vm.id
}

output "bastion_nat_public_dns" {
  description = "Public DNS of the Bastion-NAT instance."
  value       = aws_instance.bastion_nat_vm.public_dns
}

output "bastion_nat_public_ip" {
  description = "Public IP address of the Bastion-NAT instance."
  value       = aws_instance.bastion_nat_vm.public_ip
}

output "bastion_nat_private_ip" {
  description = "Private IP address of the Bastion-NAT instance."
  value       = aws_instance.bastion_nat_vm.private_ip
}

# Output  Private VMs
output "private_vm_ids" {
  description = "The list of IDs of the private EC2 instances."
  value       = aws_instance.private_vm.*.id
}

output "private_vm_private_ips" {
  description = "Private IP addresses of the private VMs."
  value       = aws_instance.private_vm.*.private_ip
}

# Output  Internal Public VM
output "internal_public_vm_id" {
  description = "The ID of the Internal Public EC2 instance."
  value       = aws_instance.internal_public_vm.id
}

output "internal_public_vm_public_dns" {
  description = "Public DNS of the Internal Public VM."
  value       = aws_instance.internal_public_vm.public_dns
}

output "internal_public_vm_public_ip" {
  description = "Public IP address of the Internal Public VM."
  value       = aws_instance.internal_public_vm.public_ip
}

output "internal_public_vm_private_ip" {
  description = "Private IP address of the Internal Public VM."
  value       = aws_instance.internal_public_vm.private_ip
}